package openfl.text;
#if js
abstract TextFormatAlign(String) {
	@:extern public static inline var LEFT:TextFormatAlign = "LEFT";
	@:extern public static inline var RIGHT:TextFormatAlign = "RIGHT";
	@:extern public static inline var CENTER:TextFormatAlign = "CENTER";
	@:extern public static inline var JUSTIFY:TextFormatAlign = "JUSTIFY";
	//
	@:extern public inline function new(o:String) this = o;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) {
		return new TextFormatAlign(s);
	}
}
#end