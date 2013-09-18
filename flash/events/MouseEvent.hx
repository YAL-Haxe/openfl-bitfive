package flash.events;
import flash.display.InteractiveObject;
import flash.geom.Point;
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
	// Shared fields:
	public var altKey(default, null):Bool;
	public var ctrlKey(default, null):Bool;
	public var shiftKey(default, null):Bool;
	// Redirected fields:
	public var localX(get, null):Float;
	public var localY(get, null):Float;
	public var stageX(get, null):Float;
	public var stageY(get, null):Float;
	public var buttonDown(get, null):Bool;
	public var delta(get, null):Int;
	// OpenFL-specific:
	public var relatedObject:InteractiveObject;
	// JavaScript-specific:
	public var button:Int;
	public var wheelDelta:Int;
	public var pageX:Float;
	public var pageY:Float;
	//
	private static var convPoint:Point;
	
	public function new(type:String, bubbles:Bool = true, cancelable:Bool = false, ?lx:Float, ?ly:Float,
	?obj:InteractiveObject, ctrlKey:Bool = false, altKey:Bool = false, shiftKey:Bool = false,
	buttonDown:Bool = false, delta:Int = 0):Void {
		super(type, bubbles, cancelable);
		this.ctrlKey = ctrlKey;
		this.altKey = altKey;
		this.shiftKey = shiftKey;
		relatedObject = obj;
		button = buttonDown ? 0 : 1;
		wheelDelta = delta;
	}
	
	private function get_buttonDown():Bool { return button == 0; }
	private function get_delta():Int { return wheelDelta; }
	private function get_stageX():Float { return pageX; }
	private function get_stageY():Float { return pageY; }
	private function get_localPoint():Point {
		var p:Point = convPoint;
		if (p == null) convPoint = p = new Point();
		p.x = pageX; p.y = pageY;
		return relatedObject != null ? relatedObject.globalToLocal(p, p) : p;
	}
	private function get_localX():Float {
		return get_localPoint().x;
	}
	private function get_localY():Float {
		return get_localPoint().y;
	}
	
	public function updateAfterEvent():Void {
		// There's no need to force a redraw with current organization.
	}
	
	private static function __init__() {
		untyped (function() {
			var o = js.html.MouseEvent.prototype, q = MouseEvent.prototype;
			o.get_buttonDown = q.get_buttonDown;
			o.get_delta = q.get_delta;
			o.get_stageX = q.get_stageX;
			o.get_stageY = q.get_stageY;
			o.get_localX = q.get_localX;
			o.get_localY = q.get_localY;
			o.get_localPoint = q.get_localPoint;
		})();
	}
}
#end