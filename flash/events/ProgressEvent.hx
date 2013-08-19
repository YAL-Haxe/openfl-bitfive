package flash.events;
#if js
/**
 * I wonder if .PROGRESS ever gets dispatched under JS-HTML5...
 */
class ProgressEvent extends Event {
	//
	@:extern public static inline var PROGRESS:String = "progress";
	@:extern public static inline var SOCKET_DATA:String = "socketData";
	//
	public var bytesLoaded:Float;
	public var bytesTotal:Float;
	//
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, bytesLoaded:Float = 0, bytesTotal:Float = 0) {
		super(type, bubbles, cancelable);
		this.bytesLoaded = bytesLoaded;
		this.bytesTotal = bytesTotal;
	}
}
#end