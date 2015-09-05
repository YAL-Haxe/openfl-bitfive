package openfl.display;
#if js
abstract StageScaleMode(String) {
	@:extern public static inline var SHOW_ALL:StageScaleMode = "SHOW_ALL";
	@:extern public static inline var NO_SCALE:StageScaleMode = "NO_SCALE";
	@:extern public static inline var NO_BORDER:StageScaleMode = "NO_BORDER";
	@:extern public static inline var EXACT_FIT:StageScaleMode = "EXACT_FIT";
	//
	@:extern public inline function new(o:String) this = o;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) return new StageScaleMode(s);
}
#end