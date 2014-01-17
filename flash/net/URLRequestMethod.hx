package flash.net;
#if js
abstract URLRequestMethod(String) {
	@:extern public static inline var DELETE : String = "DELETE";
	@:extern public static inline var GET : String = "GET";
	@:extern public static inline var HEAD : String = "HEAD";
	@:extern public static inline var OPTIONS : String = "OPTIONS";
	@:extern public static inline var POST : String = "POST";
	@:extern public static inline var PUT : String = "PUT";
	//
	public inline function new(o:String) this = o;
	@:to public inline function toString():String return this;
	@:from public static inline function fromString(s:String) return new URLRequestMethod(s);
}
#end