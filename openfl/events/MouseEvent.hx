package flash.events;
#if js
import flash.display.InteractiveObject;
import flash.geom.Point;
import flash.Lib;

class MouseEvent extends UIEvent {
	// Hover:
	@:extern public static inline var MOUSE_MOVE:String = "mouseMove";
	@:extern public static inline var MOUSE_OVER:String = "mouseOver";
	@:extern public static inline var MOUSE_OUT:String = "mouseOut";
	// Misc:
	@:extern public static inline var DOUBLE_CLICK:String = "doubleClick";
	@:extern public static inline var MOUSE_WHEEL:String = "mouseWheel";
	// Left button:
	@:extern public static inline var CLICK:String = "mouseClick";
	@:extern public static inline var MOUSE_DOWN:String = "mouseDown";
	@:extern public static inline var MOUSE_UP:String = "mouseUp";
	// Middle button:
	@:extern public static inline var MIDDLE_CLICK:String = "middleClick";
	@:extern public static inline var MIDDLE_MOUSE_DOWN:String = "middleMouseDown";
	@:extern public static inline var MIDDLE_MOUSE_UP:String = "middleMouseUp";
	// Right button:
	@:extern public static inline var RIGHT_CLICK:String = "rightClick";
	@:extern public static inline var RIGHT_MOUSE_DOWN:String = "rightMouseDown";
	@:extern public static inline var RIGHT_MOUSE_UP:String = "rightMouseUp";
	// Not yet supported:
	//@:extern public static inline var ROLL_OUT:String = "rollOut";
	//@:extern public static inline var ROLL_OVER:String = "rollOver";
	// Fields:
	public var buttonDown:Bool;
	public var delta:Int;
	//

	/**
	 * Creates a new MouseEvent instance.
	 * @param	type	  Event type
	 * @param	?bubbles
	 * @param	?cancelable
	 * @param	?lx	      Local X
	 * @param	?ly	      Local Y
	 * @param	?obj	  Related object
	 * @param	?ctrlKey  Control key status
	 * @param	?altKey   Alt key status
	 * @param	?shiftKey Shift key status
	 * @param	?bt	      "buttonDown"
	 * @param	?delta	  Mouse wheel delta, if any
	 */
	public function new(type:String, ?bubbles:Bool, ?cancelable:Bool, ?lx:Float, ?ly:Float,
	?obj:InteractiveObject, ?ctrlKey:Bool, ?altKey:Bool, ?shiftKey:Bool,
	?bt:Bool, ?delta:Int):Void {
		super(type, Lib.nz(bubbles, true), Lib.nz(cancelable, false));
		this.ctrlKey = Lib.nz(ctrlKey, false);
		this.altKey = Lib.nz(altKey, false);
		this.shiftKey = Lib.nz(shiftKey, false);
		//
		relatedObject = obj;
		buttonDown = Lib.nz(bt, false);
		this.delta = Lib.nz(delta, 0);
	}
	
	// Extra methods:
	public function updateAfterEvent():Void {
		// There's no need to force a redraw with current organization.
	}
}
#end