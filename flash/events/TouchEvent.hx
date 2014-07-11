package flash.events;
#if js
import flash.display.InteractiveObject;
/**
 * Will need some bridge to properly support multi-touch.
 */
class TouchEvent extends Event {
	@:extern public static inline var TOUCH_BEGIN:String = "touchBegin";
	@:extern public static inline var TOUCH_END:String = "touchEnd";
	@:extern public static inline var TOUCH_MOVE:String = "touchMove";
	// Not yet supported:
	//@:extern public static inline var TOUCH_OUT:String = "touchOut";
	//@:extern public static inline var TOUCH_OVER:String = "touchOver";
	//@:extern public static inline var TOUCH_ROLL_OUT:String = "touchrollout";
	//@:extern public static inline var TOUCH_ROLL_OVER:String = "touchrollover";
	//@:extern public static inline var TOUCH_TAP:String = "touchtap"; // a bad idea anyway.
	//
	public var altKey(default, null):Bool;
	public var ctrlKey(default, null):Bool;
	public var shiftKey(default, null):Bool;
	//
	public var localX:Float;
	public var localY:Float;
	public var stageX:Float;
	public var stageY:Float;
	//
	public var sizeX:Float;
	public var sizeY:Float;
	public var pressure:Float;
	//
	public var touchPointID:Int;
	public var relatedObject:InteractiveObject;
	//
	function new(type:String, ?bubbles:Bool, ?cancelable:Bool,
	?id:Int, ?primary:Bool, ?lx:Float, ?ly:Float, ?sx:Float, ?sy:Float,
	?ps:Float, ?obj:InteractiveObject, ?ctrl:Bool, ?alt:Bool, ?shift:Bool) {
		super(type, bubbles, cancelable);
		this.altKey = altKey;
		this.shiftKey = shiftKey;
		this.ctrlKey = ctrlKey;
		//
		touchPointID = id;
		sizeX = sx;
		sizeY = sy;
		pressure = ps;
	}
}
#end