package openfl.display;
#if js
abstract StageDisplayState(String) {
	@:extern public static inline var FULL_SCREEN:StageDisplayState = "FULL_SCREEN";
	@:extern public static inline var FULL_SCREEN_INTERACTIVE:StageDisplayState = "FULL_SCREEN_INTERACTIVE";
	@:extern public static inline var NORMAL:StageDisplayState = "NORMAL";
	//
	@:extern public inline function new(o:String) this = o;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) return new StageDisplayState(s);
}
#end
