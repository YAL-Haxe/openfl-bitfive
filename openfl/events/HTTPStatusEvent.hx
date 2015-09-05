package flash.events;
#if js
class HTTPStatusEvent extends Event {
	@:extern public static inline var HTTP_RESPONSE_STATUS:String = "httpResponseStatus";
	@:extern public static inline var HTTP_STATUS:String = "httpStatus";
	
	public var responseHeaders:Array<Dynamic>;
	public var responseURL:String;
	public var status(default, null):Int;
	
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, status:Int = 0):Void {
		this.status = status;
		super(type, bubbles, cancelable);
	}
}
#end