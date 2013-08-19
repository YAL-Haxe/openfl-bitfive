package flash.events;
#if js
import flash.events.Event;

/** Smaller functionality, since we'll be mapping this to EventTarget */
interface IEventDispatcher {
	public function addEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false,
	priority:Int = 0, useWeakReference:Bool = false):Void;
	public function removeEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false,
	priority:Int = 0, useWeakReference:Bool = false):Void;
	public function dispatchEvent(event:Event):Bool;
}
#end