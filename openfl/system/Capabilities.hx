package openfl.system;
#if js
import openfl.Lib;
//
import openfl.media.Sound;
//
import js.html.Navigator;

class Capabilities {
	// system
	public static var isDebugger(get, null):Bool;
	public static var isEmbeddedInAcrobat(get, null):Bool;
	public static var language(get, null):String;
	public static var os(get, null):String;
	public static var version(get, null):String;
	// screen
	public static var screenResolutionX(get, null):Float;
	public static var screenResolutionY(get, null):Float;
	public static var screenColor(get, null):String;
	public static var touchscreenType(get, null):String;
	// audio
	public static var hasAudio(get, null):Bool;
	public static var hasMP3(get, null):Bool;
	
	// system
	static function get_isDebugger() {
		// actually returns whether you are running in projector with FDB support?
		return #if debug true #else false #end;
	}
	static function get_isEmbeddedInAcrobat() return false;
	static function get_language() {
		var n:Navigator = Lib.window.navigator, r:String, i:Int;
		r = untyped n.systemLanguage || n.userLanguage || n.language;
		if (r == null) return "en";
		if ((i = r.indexOf("-")) > 0) r = r.substr(0, i);
		return r;
	}
	static var os_cached:String;
	static function get_os() {
		//if (os_cached != null) return os_cached;
		var r:String = "unknown", a:String = Lib.window.navigator.userAgent.toLowerCase(),
			e:EReg;
		if (a.indexOf("windows") >= 0) {
			if (a.indexOf("nt 6.3") >= 0) r = "Windows 8.1";
			else if (a.indexOf("nt 6.2") >= 0) r = "Windows 8";
			else if (a.indexOf("nt 6.1") >= 0) r = "Windows 7";
			else if (a.indexOf("nt 6.0") >= 0) r = "Windows Vista";
			else if (a.indexOf("nt 5.2") >= 0) r = "Windows Server 2003";
			else if (a.indexOf("nt 5.1") >= 0) r = "Windows XP";
			else if (a.indexOf("nt 5.0") >= 0) r = "Windows 2000";
			else r = "Windows"; // too odd to matter
		} else if (a.indexOf("android") >= 0) {
			r = "Android";
			e = ~/android ([\._\d]+)/;
			if (e.match(a)) r += " " + e.matched(1);
		} else if (a.indexOf("iphone") >= 0 || a.indexOf("ipad") >= 0 || a.indexOf("ipod") >= 0) {
			r = "iOS";
			// "iOS 6_0" or "iOS 6_0_1":
			e = ~/os (\d+)_(\d+)_?(\d+)?/;
			if (e.match(a)) {
				r += " " + e.matched(1) + "." + e.matched(2);
				if (e.matched(3) != null) r += "." + e.matched(3);
			}
		} else if (a.indexOf("mac os x") >= 0) {
			r = "Mac OS X";
			// Either "Mac OS X 10_9_1" or "Mac OS X 10.6":
			e = ~/mac os x (\d+)[\._](\d+)[\._]?(\d+)?/;
			if (e.match(a)) {
				r += " " + e.matched(1) + "." + e.matched(2);
				if (e.matched(3) != null) r += "." + e.matched(3);
			}
		} else if (a.indexOf("mac") >= 0) {
			r = "Mac OS";
		} else if (a.indexOf("linux") >= 0 || a.indexOf("x11") >= 0) {
			r = "Linux";
		} else if (a.indexOf("unix") >= 0) {
			r = "Unix";
		}
		return os_cached = r;
	}
	static function get_version() {
		// certainly not the best approach.
		return Lib.window.navigator.userAgent;
	}
	
	// screen
	static function get_screenResolutionX() return Lib.window.screen.width;
	static function get_screenResolutionY() return Lib.window.screen.height;
	static function get_screenColor() {
		var i:Int = Lib.window.screen.colorDepth;
		return (i == null || i > 8) ? "color" : i > 1 ? "gray" : "bw";
	}
	static function get_touchscreenType() {
		var e = Lib.window.ontouchend;
		return (Lib.stage.isTouchScreen || untyped __js__("e !== undefined"))
		? TouchscreenType.FINGER : TouchscreenType.NONE;
	}
	
	// audio
	static function get_hasAudio() return Sound.canPlayType("mp3") || Sound.canPlayType("ogg");
	static function get_hasMP3() return Sound.canPlayType("mp3");
}
#end