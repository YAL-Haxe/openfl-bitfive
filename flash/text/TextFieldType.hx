package flash.text;
#if js
#if bitfive_enums
@:fakeEnum(String) enum TextFieldType {
	DYNAMIC;
	INPUT;
}
#else
abstract TextFieldType(String) {
	@:extern public static inline var DYNAMIC:TextFieldType = "DYNAMIC";
	@:extern public static inline var INPUT:TextFieldType = "INPUT";
	//
	@:extern public inline function new(s:String) this = s;
	@:extern @:to public inline function toString():String return this;
	@:extern @:from public static inline function fromString(s:String) return new TextFieldType(s);
}
#end
#end
