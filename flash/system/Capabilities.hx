package flash.system;
#if js
import js.Browser;
class Capabilities
{
	static public var screenResolutionX(get, null):Float;
	static public var screenResolutionY(get, null):Float;
	static public var os(get, null):String;
	static public var language(get, null):String;
	inline static private function get_screenResolutionX():Float {
		return Browser.window.screen.width;
	}
	inline static private function get_screenResolutionY():Float {
		return Browser.window.screen.height;
	}
	inline static private function get_os():String {
		return untyped navigator.oscpu;
	}
	static private function get_language():String {
		if (untyped navigator.language) return untyped navigator.language;
        else if (untyped navigator.browserLanguage) return untyped navigator.browserLanguage;
        else if (untyped navigator.systemLanguage) return untyped navigator.systemLanguage;
        else if (untyped navigator.userLanguage) return untyped navigator.userLanguage;
		return "unknown";
	}
}
#end