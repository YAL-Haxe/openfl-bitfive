package openfl.events;
#if js
class SecurityErrorEvent extends ErrorEvent {
	@:extern public static inline var SECURITY_ERROR:String = "securityError";
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, text:String = ""):Void {
		super(type, bubbles, cancelable);
		this.text = text;
	}
}
#end