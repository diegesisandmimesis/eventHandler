#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the eventHandler library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

versionInfo:    GameID
        name = 'eventHandler Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the eventHandler library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the eventHandler library.
		<.p>
		Consult the README.txt document distributed with the library
		source for a quick summary of how to use the library in your
		own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;

startRoom:      Room 'Void'
        "This is a featureless void."
;
+me: Person;
+pebble: Thing, EventNotifier 'small round pebble' 'pebble'
	"It's a small, round pebble. "
	dobjFor(Examine) {
		action() {
			inherited();
			notifySubscribers('examine');
		}
	}
;
+stone: Thing, EventListener 'generic stone' 'stone'
	"It's a generic stone. "
	eventHandler(obj) {
		"\^<<theName>> received a notification. ";
	}
	initializeThing() {
		inherited();
		pebble.addSubscriber(self, 'examine');
	}
;

gameMain:       GameMainDef initialPlayerChar = me;
