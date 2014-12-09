package flash.text;
#if js
#if bitfive_enums
@:fakeEnum(String) enum TextFieldAutoSize {
	CENTER;
	LEFT;
	NONE;
	RIGHT;
}
#else
abstract TextFieldAutoSize(String) {
	@:extern public static inline var CENTER:TextFieldAutoSize = "CENTER";
	@:extern public static inline var LEFT:TextFieldAutoSize = "LEFT";
	@:extern public static inline var NONE:TextFieldAutoSize = "NONE";
	@:extern public static inline var RIGHT:TextFieldAutoSize = "RIGHT";
	//
	@:extern public inline function new(s:String) this = s;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) return new TextFieldAutoSize(s);
}
#end
#end