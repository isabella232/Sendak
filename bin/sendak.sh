#!/bin/bash

# * I am not sure this should actually be shell. I would ideally prefer it be
#   node. For now this seems quicker.
#
# * Going by the specification in the root/README.md, this should not live in
#   bin/ by itself, but rather in bin/shell. However, it's the dispatcher so..
#   it seems like it belongs somewhere else.

# Sendak dispatcher. Basically, if you execute:
#
# $ sendak do-a-thing --with-that-argument foo
#
# Sendak will look in bin/{js,python,perl,...} for a file named 'do-a-thing'.
# It will error out if it finds more than one file named do-a-thing regardless
# of extension or parent directory (so please keep your things uniquely named)
# and then execute `bin/py/do-a-thing.py` (or whichever language do-a-thing is
# written in) with the args `--with-that-argument foo`. Which is to say:
#
# $ bin/py/do-a-thing.py --with-that-argument foo
#
# We do this so that certain environment variables can be passed through to
# all of Sendak and that certain assumptions can be made about which things
# are available (for the moment this means basic understanding of what the
# Sendak ORM looks like, which includes AWS IAM data and 18F user/group/policy
# data, among others).

# Bring in the included goodies we carry around as Sendak components in shell
#
. components/common/shell/sendak.sh

# debuggery is not working. so we get all the messages. which is okay with me.
#
export DEBUG=0
# set -x

# This is the global "return" value. If we don't have it, we can't continue.
#
ATOM=""
WANTED_ATOM=$1

# Just tells the user what the general form of commands is
#
function usage () { # {{{
	cat << USAGE

  sendak.sh - The Sendak command dispatcher.

  $ sendak.sh sub-command --sub-command-args

  In this example, 'sub-command.js' is found in bin/js/sub-command.js and
  executed with arguments --sub-comand-args. $0 is not real smart and will
  simply return the first sub-command (internally: "atoms") it finds and
  you will execute that. Please police your bin/ dir. Extensions (".js",
  ".py", and so on) are omitted for prettiness.

  $ sendak.sh --list-atoms

  This should return the list of available commands and which language they
  are written in (which indicates the directory they reside in).

USAGE
	echo
} # }}}

if [[ "x${WANTED_ATOM}" == "x" ]]; then # {{{
	usage
	exit -255
elif [[ "x${WANTED_ATOM}" == "x--list-atoms" ]]; then
	echo
	echo "Available atoms include: "
	find bin -type f | perl -ne 'm!bin/([^/]+)/([^.]+).\S! and print qq/\t* $2 ($1)\n/'
	echo
	exit 0 # because successful.
fi # }}}

# Looks in a directory (first argument) for an "atom" (a sub-command for
# sendak, second argument). For example:
#
# find_atom 'bin/js' 'list-users'
#
function find_atom () { # {{{
	dir=$1
	atom=$2
	# log "dir - $dir, atom - $atom"
	# atom = `echo atom | cut -d'.' -f1`
	found=`find $dir -name ${atom}.* -print`
	ATOM=${found};
} # find_atom }}}

for possible in `find bin/* -type d`; do # {{{
	find_atom $possible $WANTED_ATOM
	if [[ "${ATOM}x" == "x" ]]; then
		# we did not find it
		#
		echo "no ${WANTED_ATOM} in ${possible}"
	else
		# We found it. Let's execute it with the arguments we were given
		#
		# bash "arrays" suck, so we need to clean up $* here
		#
		DISPATCH="`echo $* | perl -ne 'm!\S+\s(.*)! and print $1'`"
		DISPATCH="${ATOM} ${DISPATCH}"
		# This is kind of frightening, but this script should be running as the
		# (unprivileged) user in the shell. Not a web form etc.
		#
		${DISPATCH}
	fi
done # }}}

exit 0

# ps. bash sucks.
# http://www.linuxjournal.com/content/return-values-bash-functions

# jane@cpan.org // vim:tw=80:ts=2:noet
