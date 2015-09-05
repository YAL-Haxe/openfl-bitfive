package openfl.events;
#if js
class ErrorEvent extends TextEvent {
	@:extern public static inline var ERROR:String = "error";
	public function new(type:String, ?bubbles:Bool, ?cancelable:Bool, ?text:String):Void {
		super(type, bubbles, cancelable);
		this.text = text;
	}
}
#end