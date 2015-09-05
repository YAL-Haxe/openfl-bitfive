package flash.events;
#if js
import haxe.ds.ObjectMap;
import js.html.Element;
import js.html.EventTarget;

/**
 * This simple class is responsible for seemingly unhealthy idea of mapping
 * HTML events to OpenFL events for cases where EventTarget is available.
 * @author YellowAfterlife
 */
class EventWrapper extends EventDispatcher {
	public var component:Element;
	private var eventMap:ObjectMap < Dynamic, Dynamic->Void > ;
	override public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false,
	priority:Int = 0, weak:Bool = false):Void {
		super.addEventListener(type, listener, useCapture, priority, weak);
		var f = function wrapper(e:Event):Void {
			if (e.target == component) e.target = this;
			e.currentTarget = this; // translation needed.
			listener(e);
		};
		if (!eventMap.exists(listener)) eventMap.set(listener, f);
		component.addEventListener(type, f, useCapture);
	}
	override public function removeEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false):Void {
		super.removeEventListener(type, listener, useCapture);
		if (eventMap.exists(listener)) {
			component.removeEventListener(type, eventMap.get(listener), useCapture);
			eventMap.remove(listener);
		}
	}
	public function new() {
		super();
		eventMap = new ObjectMap();
	}
}
#end