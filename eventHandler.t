#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>

// Module ID for the library
eventHandlerModuleID: ModuleID {
        name = 'Event Handler Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Class for events.  Not simply "Event" because of possible name collisions.
class EventHandlerEvent: object
	source = nil	// source of the event
	type = nil	// event type
	data = nil	// optional source-provided data

	construct(s?, t?, d?) {
		source = (s ? s : nil);
		type = (t ? t : nil);
		data = (d ? d : nil);
	}
;

// Class for subscriptions.
class EventSubscription: object
	subscriber = nil	// the object subscribing to the event type
	callback = nil		// method to call on event
	type = nil		// the event type
	source = nil		// the source...it creates the subscription

	construct(s?, cb?, t?, src?) {
		subscriber = (s ? s : nil);
		callback = (cb ? cb : nil);
		type = (t ? t : '*');
		source = (src ? src : nil);
	}

	// Very simple type matching.  Here we just assume event types
	// are something like a string literal.
	matchType(v?) { return((type == '*') || (v == type)); }

	// Fire the event.  Notifies the subscriber that the event source
	// emitted the event.
	fire(v?, d?) {
		local e;

		// Make sure we match.
		if(!matchType(v))
			return(nil);

		// Make sure we have a valid subscriber.
		if((subscriber == nil) || !subscriber.ofKind(EventListener))
			return(nil);

		e = new EventHandlerEvent(source, v, d);
		if(dataType(callback) == TypeNil) {
			// Ping the subscriber's default event handler.
			subscriber._eventHandler(e);
		} else {
			subscriber.(callback)(e);
		}

		return(true);
	}

	// Unsubscribe.
	detach(v?) {
		if((source == nil) || !source.ofKind(EventNotifier))
			return(nil);
		return(source.removeSubscriber(subscriber, v));
	}
;

// Mixin class for objects that want to EMIT events.
class EventNotifier: object
	_eventSubscribers = nil		// list of objects subscribed to us

	// Returns the list of subscribers, creating an empty one if necessary.
	getSubscribers() {
		if(_eventSubscribers == nil)
			_eventSubscribers = new Vector(16);
		return(_eventSubscribers);
	}

	// Add a subscriber to
	addSubscriber(v, type?, cb?) {
		local l;

		l = getSubscribers();
		if(l.indexOf(v) == nil)
			l.append(new EventSubscription(v, cb, type, self));
	}
	removeSubscriber(v) {
		local idx, l;

		l = getSubscribers();

		idx = l.indexOf(v);
		if(idx == nil)
			return(nil);
		_eventSubscribers = l.removeElementAt(idx);

		return(true);
	}
	notifySubscribers(type, data?) {
		getSubscribers.forEach(function(o) {
			o.fire(type, data);
		});
	}
;

class EventListener: object
	_eventHandler(obj) {
		if((obj == nil) || !obj.ofKind(EventHandlerEvent))
			return;
		eventHandler(obj);
	}
	eventHandler(obj) {}
;
