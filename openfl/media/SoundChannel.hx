package openfl.media;
#if js
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.Lib;
import js.html.AudioElement;

class SoundChannel extends EventDispatcher {
	public var leftPeak(default, null):Float = 1;
	public var rightPeak(default, null):Float = 1;
	public var soundTransform(default, set):SoundTransform;
	public var position(get, set):Float;
	//
	public var component(default, null):AudioElement;
	public var qSound:Sound;
	public var active:Bool = false;
	public var _position:Float;
	public var _loops:Int = 1;
	//
	public function new():Void {
		super();
	}
	public function init(q:Sound, v:AudioElement, loops:Int=1):Void {
		qSound = q;
		component = v;
		_loops = loops;
		component.addEventListener("ended", cast onEnded);
	}
	public function play(p:Float):Void {
		var o = component, l:Float;
		if (!active) {
			l = get_duration();
			if (p == 0 || p / 1000 <= l) {
				_position = position = p;
				o.load();
				o.play();
				active = true;
			} else {
				// attempt to hint preloading:
				position = 0;
				o.load();
				o.play();
				o.pause();
				qSound.qCache.push(this);
			}
		}
	}
	public function stop():Void {
		if (active) {
			active = false;
			component.pause();
			qSound.qCache.push(this);
		}
	}
	private function set_soundTransform(v:SoundTransform):SoundTransform {
		soundTransform = v;
		component.volume = v != null ? v.volume : 1;
		return v;
	}
	private function get_duration():Float {
		var o = component, f:Float;
		try {
			f = o.buffered != null ? o.buffered.end(0) : o.duration;
		} catch (_:Dynamic) {
			f = o.duration;
			if (Math.isNaN(f)) f = 0;
		}
		return f;
	}
	private inline function get_position():Float {
		return component.currentTime * 1000;
	}
	private function set_position(v:Float):Float {
		if (component.currentTime != v / 1000) {
			var p = !component.paused;
			if (p) component.pause();
			component.currentTime = (v / 1000);
			if (p) component.play();
		}
		return v;
	}
	private function onEnded(e:Event):Void {
		if (active) {
			if (--_loops > 0 ) {
				position = _position;
				if (component.paused) component.play();
			} else {
				stop();
				component.currentTime = 0;
				dispatchEvent(new Event(Event.SOUND_COMPLETE));
			}
		}
	}
}
#end
