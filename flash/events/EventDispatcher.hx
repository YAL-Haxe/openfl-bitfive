package flash.events;

class EventDispatcher implements IEventDispatcher {
	private var eventList:Map<String, Array<Dynamic->Void>>; // Map<EventType, EventList>
	public function new() {
		eventList = new Map();
	}
	public function addEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false,
	priority:Int = 0, weak:Bool = false):Void {
		var o;
		if (!eventList.exists(type)) eventList.set(type, o = []); else o = eventList.get(type);
		o.push(listener);
	}
	public function removeEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false,
	priority:Int = 0, weak:Bool = false):Void {
		if (eventList.exists(type)) {
			var r = eventList.get(type);
			for (o in r) {
				if (Reflect.compareMethods(o, listener)) {
					r.remove(o);
					break;
				}
			}
			if (r.length == 0) eventList.remove(type);
		}
	}
	public function hasEventListener(type:String):Bool {
		return eventList.exists(type);
	}
	public function dispatchEvent(event:Event):Bool {
		if (event.target == null) event.target = this;
		var t = event.type;
		if (eventList.exists(t)) for (o in eventList.get(t)) o(event);
		return true;
	}
}