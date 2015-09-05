package openfl.events;
#if js
import openfl.events.Event;

class TimerEvent extends Event {
	@:extern public static inline var TIMER:String = "timer";
	@:extern public static inline var TIMER_COMPLETE:String = "timerComplete";
	
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false):Void {
		super(type, bubbles, cancelable);
	}
}
#end