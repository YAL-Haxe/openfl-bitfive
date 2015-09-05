package openfl.ui;
#if js
class Multitouch {
	public static var inputMode:MultitouchInputMode;
	public static var supportsTouchEvents(default, null):Bool = false;
	public static var supportedGestures(default, null):Array<String>;
	public static var maxTouchPoints(default, null):Int = 0;
}
#end