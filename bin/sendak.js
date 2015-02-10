#!/usr/bin/env node

// sendak.ps
//   the sendak dispatcher, which lives atop plugsuit

'use strict;'

var plugsuit = require( 'plugsuit' )
	, parsed   = require( 'sendak-usage' ).parsedown( {
			'help'       : { 'type' : [ Boolean ] }
		}, process.argv )
	, usage    = parsed[1]
	, args     = parsed[0];

if (args['help']) {
	console.log( 'Usage:' );
	console.log( usage );
	process.exit( 0 );
}

plugsuit.init( 'bin/js' );
plugsuit.dispatch( process.argv )


