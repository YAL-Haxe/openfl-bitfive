package flash.media;
#if js
import flash.net.URLRequest;
import js.html.AudioElement;
/**
 * 
 */
class Sound extends flash.events.EventDispatcher {
	//
	public var id3:ID3Info;
	private var component:AudioElement;
	public var qCache:Array<SoundChannel>;
	public var length(get, null):Float;
	public static var library:Map<String, AudioElement>;
	private static var canPlayMap:Map<String, Bool>;
	//
	public function new(?stream:URLRequest, ?ctx:SoundLoaderContext) {
		super();
		if (stream != null) load(stream, ctx);
	}
	
	public function close():Void {
		if (component != null) {
			component = null;
		} else throw new flash.errors.IOError("Attempt to close unexisting stream.");
	}
	
	public function load(?stream:URLRequest, ?ctx:SoundLoaderContext):Void {
		var s = stream.url;
		if (library != null && library.exists(s)) {
			component = library.get(s);
			library.set(s, cast component.cloneNode(true));
		} else {
			#if OFL_LOG_LOAD
				flash.Lib.trace("Loading " + s);
			#end
			component = untyped __js__("new Audio(s)");
		}
		qCache = [];
	}
	
	public function play(ofs:Float = 0, loops:Int = 0, ?stf:SoundTransform):SoundChannel {
		var o:SoundChannel, i:Int;
		//flash.Lib.trace(component.src + ":play[" + qCache.length + "]");
		if (qCache.length == 0) {
			(o = new SoundChannel()).init(this, component, loops);
			component = cast component.cloneNode(true);
		} else {
			// attempt to find a sound with currentTime matching one asked:
			o = qCache[0];
			for (v in qCache) if (v.position == ofs) { o = v; break; }
			qCache.remove(o);
		}
		o.soundTransform = stf;
		try {
			o.play(ofs);
		} catch (e:Dynamic) {
			var f = null;
			f = function(e) {
				o.component.removeEventListener("canplaythrough", f);
				o.play(ofs);
			};
			o.addEventListener("canplaythrough", f);
		}
		return o;
	}
	
	private function get_length():Float {
		return component != null ? component.duration * 1000 : 0;
	}
	
	public static function canPlayType(o:String):Bool {
		var f:String, v:Bool;
		o = o.toLowerCase();
		if (canPlayMap != null) {
			if (canPlayMap.exists(o)) return canPlayMap.get(o);
		} else canPlayMap = new Map();
		f = getFormatType(o);
		v = untyped __js__("new Audio()").canPlayType(f) != "no";
		canPlayMap.set(o, v);
		return v;
	}
	
	private static function getFormatType(o:String):String {
		return
		o == "mp3" ? "audio/mpeg;"
		: o == "ogg" ? 'audio/ogg; codecs="vorbis"'
		: null;
	}
}
#end
