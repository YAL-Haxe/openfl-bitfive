package flash.events;
#if js
class MouseEvent extends Event {
	@:extern public static inline var CLICK:String = "click";
	@:extern public static inline var DOUBLE_CLICK:String = "doubleclick";
	@:extern public static inline var MOUSE_DOWN:String = "mousedown";
	@:extern public static inline var MOUSE_MOVE:String = "mousemove";
	@:extern public static inline var MOUSE_OUT:String = "mouseout";
	@:extern public static inline var MOUSE_OVER:String = "mouseover";
	@:extern public static inline var MOUSE_UP:String = "mouseup";
	@:extern public static inline var MOUSE_WHEEL:String = "mousewheel";
	/*// Delayed: requires an extra hack on event addition
	@:extern public static inline var RIGHT_CLICK:String = "rightClick";
	@:extern public static inline var RIGHT_MOUSE_DOWN:String = "rightMouseDown";
	@:extern public static inline var RIGHT_MOUSE_UP:String = "rightMouseUp";
	//*/
	@:extern public static inline var ROLL_OUT:String = "rollout";
	@:extern public static inline var ROLL_OVER:String = "rollover";
	//
	public var altKey(default, null):Bool;
	public var ctrlKey(default, null):Bool;
	public var shiftKey(default, null):Bool;
	public var buttonDown(get, null):Bool;
	private var button:Int;
	public var delta(get, null):Int;
	private var wheelDelta:Int;
	
	function new(type:String, bubbles:Bool = true, cancelable:Bool = false, ?localX:Float, ?localY:Float,
	?relatedObject:Dynamic, ctrlKey:Bool = false, altKey:Bool = false, shiftKey:Bool = false,
	buttonDown:Bool = false, delta:Int = 0):Void {
		super(type, bubbles, cancelable);
		this.ctrlKey = ctrlKey;
		this.altKey = altKey;
		this.shiftKey = shiftKey;
		button = buttonDown ? 0 : 1;
		wheelDelta = delta;
	}
	
	private function get_buttonDown():Bool { return button == 0; }
	private function get_delta():Int { return wheelDelta; }
	
	public function updateAfterEvent():Void {
		// There's no need to force a redraw with current organization.
	}
	
	private static function __init__() {
		untyped (function() {
			var o = js.html.MouseEvent.prototype, q = MouseEvent.prototype;
			o.get_buttonDown = q.get_buttonDown;
			o.get_delta = q.get_delta;
		})();
	}
}
#end