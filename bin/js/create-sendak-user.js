#!/usr/bin/env node

/*
  This tool goes and grabs the prototype for 'User' from Riak, and inserts
  the values for this user supplied on the commandline.

  If correct flags are specified, this Sendak user will also be given a
  new account in AWS. These flags are (probably):

  --create-iam-user
  --with-vpc
  --username

*/

//   User: '{"name":{"isa":"string","defined":true,"distinct":true},"arn":{"isa":"string","defined":true,"distinct":true,"verified":"RESERVED"},"amznid":{"isa":"string","defined":true,"distinct":true,"verified":"RESERVED"},"hasmany":["Project","Group"]}',


// parse opts
//
var nopt = require('nopt')
	, noptUsage = require('nopt-usage')
	, Stream    = require('stream').Stream
	, path      = require('path')
	, knownOpts = {
			'create-iam-user'   : [ Boolean, null ],
			'with-vpc'          : [ String, null ],
			'username'          : [ String, null ],
			'name'              : [ String, null ],
		}
	, description = {
			'create-iam-user'   : 'Specify that you would like an IAM user created.',
			'with-vpc'          : 'Specify a VPC to which this user should have access.',
			'username'          : 'Specify the username',
			'name'              : 'Specify the person\'s name'
		}
	, defaults = {
			'help' : false
		}
	, shortHands = {
			'h' : [ '--help' ]
		}
	, parsed = nopt(knownOpts, process.argv)
	, usage = noptUsage(knownOpts, shortHands, description, defaults)

if (parsed['help']) {
	// Be halpful
	//
	console.log( 'Usage: ' );
	console.log( usage );
	process.exit(0); // success
}

var rrm = require( 'components/rrm/rrm.js' );

if (parsed['name']) {
	var puser = rrm.new_object( 'User' );

	puser.then( function (user) {
		// Once we have the prototype for a user...
		// { name: '', arn: '', amznid: '' }

		// This is a placeholder for now. The object has to change a bit.
		//
/*
fetch:Sendak jane$ sendak riak --put-tuple --bucket testing --tuple $( echo '{ "foo": "bar" }' | perl bin/pl/en64.pl )
attempted to place { "foo": "bar" }
 in Riak
QpQmL1Cz9nGNsDidr4hv53ZlH3
*/

	// so it's not clear what is not working right in rrm.js, but clearly bin/js/riak.js knows
	// what's up.
	//
		user['name'] = parsed['name'];
		var pserial = rrm.add_object( 'User', user );
		pserial.then( function (serial) {
			console.log( 'Serial seems to be ' + serial );
		} );
	} ); // promise of user
}
else {
	console.log( 'You need to provide a user name.' );
	process.exit( -255 );
}
