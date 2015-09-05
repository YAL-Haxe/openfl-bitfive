package flash.display;
#if js
#if bitfive_enums
@:fakeEnum(String) enum BlendMode {
	ADD;
	ALPHA;
	DARKEN;
	DIFFERENCE;
	ERASE;
	HARDLIGHT;
	INVERT;
	LAYER;
	LIGHTEN;
	MULTIPLY;
	NORMAL;
	OVERLAY;
	SCREEN;
	SHADER;
	SUBTRACT;
}
#else
abstract BlendMode(String) {
	@:extern public static inline var ADD:BlendMode = "ADD";
	@:extern public static inline var ALPHA:BlendMode = "ALPHA";
	@:extern public static inline var DARKEN:BlendMode = "DARKEN";
	@:extern public static inline var DIFFERENCE:BlendMode = "DIFFERENCE";
	@:extern public static inline var ERASE:BlendMode = "ERASE";
	@:extern public static inline var HARDLIGHT:BlendMode = "HARDLIGHT";
	@:extern public static inline var INVERT:BlendMode = "INVERT";
	@:extern public static inline var LAYER:BlendMode = "LAYER";
	@:extern public static inline var LIGHTEN:BlendMode = "LIGHTEN";
	@:extern public static inline var MULTIPLY:BlendMode = "MULTIPLY";
	@:extern public static inline var NORMAL:BlendMode = "NORMAL";
	@:extern public static inline var OVERLAY:BlendMode = "OVERLAY";
	@:extern public static inline var SCREEN:BlendMode = "SCREEN";
	@:extern public static inline var SUBTRACT:BlendMode = "SUBTRACT";
	//
	@:extern public inline function new(o:String) this = o;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) return new BlendMode(s);
}
#end
#end