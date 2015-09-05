package openfl.display;
#if js
abstract StageAlign(String) {
	@:extern public static inline var TOP_RIGHT:StageAlign = "TOP_RIGHT";
	@:extern public static inline var TOP_LEFT:StageAlign = "TOP_LEFT";
	@:extern public static inline var TOP:StageAlign = "TOP";
	@:extern public static inline var RIGHT:StageAlign = "RIGHT";
	@:extern public static inline var LEFT:StageAlign = "LEFT";
	@:extern public static inline var BOTTOM_RIGHT:StageAlign = "BOTTOM_RIGHT";
	@:extern public static inline var BOTTOM_LEFT:StageAlign = "BOTTOM_LEFT";
	@:extern public static inline var BOTTOM:StageAlign = "BOTTOM";
	//
	@:extern public inline function new(o:String) this = o;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) return new StageAlign(s);
}
#end