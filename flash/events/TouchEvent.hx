package flash.events;
#if js
/**
 * Will need some bridge to properly support multi-touch.
 */
class TouchEvent extends Event {
	@:extern public static inline var TOUCH_BEGIN:String = "touchbegin";
	@:extern public static inline var TOUCH_END:String = "touchend";
	@:extern public static inline var TOUCH_MOVE:String = "touchmove";
	@:extern public static inline var TOUCH_OUT:String = "touchout";
	@:extern public static inline var TOUCH_OVER:String = "touchover";
	@:extern public static inline var TOUCH_ROLL_OUT:String = "touchrollout";
	@:extern public static inline var TOUCH_ROLL_OVER:String = "touchrollover";
	@:extern public static inline var TOUCH_TAP:String = "touchtap";
	//
	public var altKey(default, null):Bool;
	public var ctrlKey(default, null):Bool;
	public var shiftKey(default, null):Bool;
	public var stageX:Float;
	public var stageY:Float;
	public var touchPointID:Int;
	//
	function new(type:String, bubbles:Bool = true, cancelable:Bool = false, touchPointID:Int = 0,
	isPrimaryTouchPoint:Bool = false, localX:Float = 0, localY:Float = 0, sizeX:Float = 0, sizeY:Float = 0,
	pressure:Float = 0, ?relObject:Dynamic, ctrlKey:Bool = false, altKey:Bool = false, shiftKey:Bool = false):Void {
		super(type, bubbles, cancelable);
		this.altKey = altKey;
		this.shiftKey = shiftKey;
		this.ctrlKey = ctrlKey;
	}
}
#end