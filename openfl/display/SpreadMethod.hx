package openfl.display;
#if js
#if bitfive_enums
@:fakeEnum(String) enum SpreadMethod {
	PAD;
	REFLECT;
	REPEAT;
}
#else
abstract SpreadMethod(String) {
	@:extern public static inline var PAD:SpreadMethod = "PAD";
	@:extern public static inline var REFLECT:SpreadMethod = "REFLECT";
	@:extern public static inline var REPEAT:SpreadMethod = "REPEAT";
	//
	@:extern public inline function new(o:String) this = o;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) {
		return new SpreadMethod(s);
	}
}
#end
#end
