package flash.display;
#if js
#if bitfive_enums
@:fakeEnum(String) enum JointStyle {
	BEVEL;
	MITER;
	ROUND;
}
#else
abstract JointStyle(String) {
	@:extern public static inline var BEVEL:JointStyle = "bevel";
	@:extern public static inline var MITER:JointStyle = "miter";
	@:extern public static inline var ROUND:JointStyle = "round";
	//
	public inline function new(s:String) this = s;
	@:to public inline function toString():String return this;
	@:from public static inline function fromString(s:String) return new JointStyle(s);
}
#end
#end
