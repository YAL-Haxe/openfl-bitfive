package openfl.display;
#if js
#if bitfive_enums
@:fakeEnum(String) enum CapsStyle {
	NONE;
	ROUND;
	SQUARE;
}
#else
abstract CapsStyle(String) {
	@:extern public static inline var NONE:CapsStyle = "none";
	@:extern public static inline var ROUND:CapsStyle = "round";
	@:extern public static inline var SQUARE:CapsStyle = "square";
	//
	@:extern public inline function new(s:String) this = s;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) return new CapsStyle(s);
}
#end
#end
