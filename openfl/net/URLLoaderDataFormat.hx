package openfl.net;
#if js
abstract URLLoaderDataFormat(Int) {
	@:extern public static inline var BINARY:URLLoaderDataFormat = 0;
	@:extern public static inline var TEXT:URLLoaderDataFormat = 1;
	@:extern public static inline var VARIABLES:URLLoaderDataFormat = 2;
	//
	@:extern public inline function new(o:Int) this = o;
	@:extern @:to public inline function toInt():Int return this;
	@:extern @:from public static inline function fromInt(v:Int) {
		return new URLLoaderDataFormat(v);
	}
}
#end