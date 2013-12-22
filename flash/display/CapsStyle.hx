package flash.display;
#if js
abstract CapsStyle(String) {
	@:extern public static inline var NONE:CapsStyle = "none";
	@:extern public static inline var ROUND:CapsStyle = "round";
	@:extern public static inline var SQUARE:CapsStyle = "square";
	//
	public inline function new(s:String) this = s;
	@:to public inline function toString():String return this;
	@:from public static inline function fromString(s:String) return new CapsStyle(s);
}
#end
