package flash.utils;
#if js
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import js.Browser;

class Timer extends EventDispatcher {
	public var currentCount(default, null):Int;
	public var delay(default, set):Float;
	public var repeatCount(default, set):Int;
	public var running(default, null):Bool;
	
	private var timerId:Int;
	
	public function new(delay:Float, repeatCount:Int = 0):Void {
		super();
		this.running = false;
		this.delay = delay;
		this.repeatCount = repeatCount;
		this.currentCount = 0;
	}
	
	public function reset():Void {
		stop();
		currentCount = 0;
	}
	
	public function start():Void {
		if (!running) {
			running = true;
			timerId = Browser.window.setInterval(onInterval, Std.int(delay));
		}
	}
	
	public function stop():Void {
		if (timerId != null) {
			Browser.window.clearInterval(timerId);
			timerId = null;
		}
		running = false;
	}
	
	private function onInterval():Void {
		var e:TimerEvent = null, o:TimerEvent;
		if (repeatCount != 0 && ++currentCount >= repeatCount) {
			stop();
			e = new TimerEvent(TimerEvent.TIMER_COMPLETE);
			e.target = this;
		}
		o = new TimerEvent(TimerEvent.TIMER);
		o.target = this;
		dispatchEvent(o);
		if (e != null) dispatchEvent(e);
	}
	
	private function set_delay(v:Float):Float {
		if (v != delay) {
			var o = running;
			if (o) stop();
			delay = v;
			if (o) start();
		}
		return v;
	}
	
	private function set_repeatCount(v:Int):Int {
		if (running && v != 0 && v <= currentCount) stop();
		return repeatCount = v;
	}
}
#end