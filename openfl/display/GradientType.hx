package openfl.display;
#if js
#if bitfive_enums
@:fakeEnum(String) enum GradientType {
	LINEAR;
	RADIAL;
}
#else
abstract GradientType(String) {
	@:extern public static inline var LINEAR:GradientType = "LINEAR";
	@:extern public static inline var RADIAL:GradientType = "RADIAL";
	//
	@:extern public inline function new(o:String) this = o;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) {
		return new GradientType(s);
	}
}
#end
#end
