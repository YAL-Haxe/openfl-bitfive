package flash.events;
#if js
class FocusEvent extends Event {
	//
	@:extern public static inline var FOCUS_IN = "focusIn";
	@:extern public static inline var FOCUS_OUT = "focusOut";
	@:extern public static inline var KEY_FOCUS_CHANGE = "keyFocusChange";
	@:extern public static inline var MOUSE_FOCUS_CHANGE = "mouseFocusChange";
	//
	public var keyCode:Int;
	public var relatedObject:flash.display.InteractiveObject;
	public var shiftKey:Bool;
	//
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false,
	inObject:flash.display.InteractiveObject = null, inShiftKey:Bool = false, inKeyCode:Int = 0) {
		super(type, bubbles, cancelable);
		
		keyCode = inKeyCode;
		shiftKey = inShiftKey == true;
		target = inObject;
		
	}
	
	
}


#end