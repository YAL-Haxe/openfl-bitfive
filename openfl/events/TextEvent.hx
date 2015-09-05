package openfl.events;
#if js
class TextEvent extends Event {
	//
	@:extern public static inline var LINK:String = "link";
	@:extern public static inline var TEXT_INPUT:String = "textInput";
	//
	public var text:String;
	//
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, text:String = ""):Void {
		super(type, bubbles, cancelable);
		this.text = text;
	}
}
#end