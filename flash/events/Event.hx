package flash.events;
#if js
import js.html.Event;
class Event {
	// from NativeEvent:
	private var _target:Dynamic;
	private var _current:Dynamic;
	/// Original JS event object, if any.
	public var __jsEvent:js.html.Event;
	public var target(get, set):Dynamic;
	private function get_target():Dynamic { return untyped __js__("this._target || this.target"); }
	private function set_target(v:Dynamic):Dynamic { return _target = v; }
	public var currentTarget(get, set):Dynamic;
	private function get_currentTarget():Dynamic { return  untyped __js__("this._current || this.currentTarget"); }
	private function set_currentTarget(v:Dynamic):Dynamic { return _current = v; }
	public var type:String;
	public var timeStamp:Int;
	public var bubbles:Bool;
	public var cancelBubble:Bool;
	public var cancelable:Bool;
	public var defaultPrevented:Bool;
	// Event types. All the inline event types:
	@:extern public static inline var ACTIVATE = "activate"; // null
	@:extern public static inline var ADDED = "added"; // ofl
	@:extern public static inline var ADDED_TO_STAGE = "addedToStage"; // ofl
	@:extern public static inline var CANCEL = "cancel"; // js
	@:extern public static inline var CHANGE = "change"; // null
	@:extern public static inline var CLOSE = "close"; // js
	@:extern public static inline var COMPLETE = "complete"; // ofl
	@:extern public static inline var CONNECT = "connect"; // null
	@:extern public static inline var CONTEXT3D_CREATE = "context3DCreate"; // null
	@:extern public static inline var DEACTIVATE = "deactivate"; // null
	@:extern public static inline var ENTER_FRAME = "enterFrame"; // ofl
	@:extern public static inline var ID3 = "id3"; // null
	@:extern public static inline var INIT = "init"; // ofl
	@:extern public static inline var MOUSE_LEAVE = "mouseLeave"; // what is this doing here?
	@:extern public static inline var OPEN = "open"; // null
	@:extern public static inline var REMOVED = "removed"; // ofl
	@:extern public static inline var REMOVED_FROM_STAGE = "removedFromStage"; // ofl
	@:extern public static inline var RENDER = "render"; // null
	@:extern public static inline var RESIZE = "resize"; // js
	@:extern public static inline var SCROLL = "scroll"; // null
	@:extern public static inline var SELECT = "select"; // null
	@:extern public static inline var TAB_CHILDREN_CHANGE = "tabChildrenChange"; // null
	@:extern public static inline var TAB_ENABLED_CHANGE = "tabEnabledChange"; // null
	@:extern public static inline var TAB_INDEX_CHANGE = "tabIndexChange"; // null
	@:extern public static inline var UNLOAD = "unload"; // null
	@:extern public static inline var SOUND_COMPLETE = "soundComplete"; // null
	//
	static function __init__() {
		untyped (function() {
			var a = js.html.Event.prototype, b = flash.events.Event.prototype;
			a.clone = b.clone;
			a.isDefaultPrevented = b.isDefaultPrevented;
			a.get_target = b.get_target;
			a.set_target = b.set_target;
			a.get_currentTarget = b.get_currentTarget;
			a.set_currentTarget = b.set_currentTarget;
		})();
	}
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		this.type = type;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
	}
	public function preventDefault() {
		// Actual implementation lies in JS events, where appropriate.
		if (__jsEvent != null) __jsEvent.preventDefault();
		defaultPrevented = true;
	}
	public function isDefaultPrevented():Bool {
		return defaultPrevented;
	}
	public function clone():Event {
		return new Event(type, bubbles, cancelable);
	}
}
#end