package openfl.display;
#if js
#if bitfive_enums
@:fakeEnum(String) enum InterpolationMethod {
	LINEAR_RGB;
	RGB;
}
#else
abstract InterpolationMethod(String) {
	@:extern public static inline var LINEAR_RGB:InterpolationMethod = "LINEAR_RGB";
	@:extern public static inline var RGB:InterpolationMethod = "RGB";
	//
	@:extern public inline function new(o:String) this = o;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) {
		return new InterpolationMethod(s);
	}
}
#end
#end
