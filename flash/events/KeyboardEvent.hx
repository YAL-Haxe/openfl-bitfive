package flash.events;
#if js
class KeyboardEvent extends Event {
	@:extern public static inline var KEY_DOWN = "keydown";
	@:extern public static inline var KEY_UP = "keyup";
	//
	public var altKey(default, null):Bool;
	public var ctrlKey(default, null):Bool;
	public var shiftKey(default, null):Bool;
	public var keyCode(default, null):Int;
	public var charCode(default, null):Int;
	function new(type:String, bubbles:Bool = true, cancelable:Bool = false, charCodeValue:Int = 0,
	keyCodeValue:Int = 0):Void {
		super(type, bubbles, cancelable);
		keyCode = keyCodeValue;
		charCode = charCodeValue;
	}
}
#end