package flash.system;
#if js
import js.Browser;
class System {
	public static var totalMemory(get, null):Int;
	public static var useCodePage:Bool = false;
	public static var vmVersion(get, null):String;
	public static function exit(code:Int):Void {
		Browser.window.close();
	}
	private static function get_totalMemory():Int {
		// this currently works only in Chrome, but oh well, at least we tried.
		var v;
		return untyped __js__("((v = console) && (v = v.memory) && (v = v.totalJSHeapSize)) || 0");
	}
	private static function get_vmVersion():String {
		return "2.0 js openfl";
	}
}
#end