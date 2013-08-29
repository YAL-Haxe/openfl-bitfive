package flash.media;
#if js
import flash.events.Event;
import js.html.AudioElement;

class SoundChannel extends flash.events.EventDispatcher {
	public var leftPeak(default, null):Float = 1;
	public var rightPeak(default, null):Float = 1;
	public var soundTransform(default, set):SoundTransform;
	public var position(get, set):Float;
	//
	public var component(default, null):AudioElement;
	public var qSound:Sound;
	public var active:Bool = false;
	private var _position:Float = 0;
	private var _loops:Int = 1;
	//
	public function new():Void {
		super();
	}
	public function init(q:Sound, v:AudioElement, loops:Int=1):Void {
		qSound = q;
		component = v;
		_loops = loops;
		component.addEventListener("ended", cast onEnded);
		//component.loop = true;
	}
	public function play(p:Float):Void {
		if (!active) {
			component.play();
			position = p;
			active = true;
		}
	}
	public function stop():Void {
		if (active) {
			active = false;
			component.pause();
			flash.Lib.trace(component.src + ":end");
			qSound.qCache.push(this);
		}
	}
	private function set_soundTransform(v:SoundTransform):SoundTransform {
		soundTransform = v;
		component.volume = v != null ? v.volume : 1;
		return v;
	}
	private function get_position():Float {
		return component.currentTime * 1000;
	}
	private function set_position(v:Float):Float {
		var p = !component.paused;
		if (p) component.pause();
		component.currentTime = (v / 1000);
		if (p) component.play();
		flash.Lib.trace(component.src + ".time = " + v);
		return v;
	}
	private function onEnded(e:Event):Void {
		if (active) {
			_loops--;
			if ( _loops > 0 )
			{
				component.play();
			}
			else
			{
				stop();
				component.currentTime = 0;
				flash.Lib.trace(component.src + ":complete");
				dispatchEvent(new Event(Event.SOUND_COMPLETE));
			}
		}
	}
}
#end
