package flash.display;
#if js
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.Lib;
import js.Browser;
import js.html.Element;
import js.html.WheelEvent;
//
class Stage extends DisplayObjectContainer {
	public var align:StageAlign;
	public var quality:String;
	public var scaleMode:StageScaleMode;
	public var displayState:StageDisplayState;
	public var stageWidth(get, null):Int;
	public var stageHeight(get, null):Int;
	public var showDefaultContextMenu:Bool;
	public var frameRate(default, set):Float = 0; // should be retrieved from XML instead.
	public var focus(get, set):InteractiveObject;
	public var mousePos:Point;
	/** Whether device is touch screen.
	 * If device dispatches touch events, these are more reliable source of mouse coordinates */
	private var isTouchScreen:Bool = false;
	private var touchCount:Int = 0;
	#if !OFL_SETTIMEOUT
	private var frameInterval:Int = 0;
	#end
	//
	public function new() {
		super();
		var s = component.style;
		s.position = "absolute";
		s.overflow = "hidden";
		s.left = s.top = "0";
		s.width = s.height = "100%";
		Lib.window.setTimeout(onTimer, 0);
		mousePos = new Point();
		var o:js.html.DOMWindow = untyped window;
		// right and other clicks:
		o.addEventListener("contextmenu", function(_:js.html.Event) _.preventDefault());
		// mouse listeners:
		o.addEventListener("click", onMouse);
		o.addEventListener("mousedown", onMouse);
		o.addEventListener("mouseup", onMouse);
		o.addEventListener("mousemove", onMouse);
		o.addEventListener("mousewheel", onWheel);
		// touch events (to prevent scrolling and to track mouse position):
		o.addEventListener("touchstart", onTouch);
		o.addEventListener("touchend", onTouch);
		o.addEventListener("touchmove", onTouch);
		//
		mouseMtxDepth = [];
		mouseMtxStack = [];
		mouseMtxCache = [];
	}
	// Mouse magic
	private var mouseMtxDepth:Array<DisplayObject>;
	private var mouseMtxStack:Array<Matrix>;
	private var mouseMtxCache:Array<Matrix>;
	private var mouseOver:DisplayObject;
	private function _broadcastMouseEvent(f:MouseEvent):Void {
		var o:DisplayObject = mouseOver, q:DisplayObject;
		f.stageX = mousePos.x;
		f.stageY = mousePos.y;
		broadcastMouse(mouseMtxDepth, f, mouseMtxStack, mouseMtxCache);
		mouseOver = q = f.relatedObject;
		if (o != q) {
			if (o != null) o.dispatchEvent(_alterMouseEvent(f, MouseEvent.MOUSE_OUT));
			if (q != null) q.dispatchEvent(_alterMouseEvent(f, MouseEvent.MOUSE_OVER));
		}
	}
	private function _alterMouseEvent(e:MouseEvent, type:String):MouseEvent {
		var r:MouseEvent = new MouseEvent(type, e.bubbles, e.cancelable, e.localX, e.localY,
			e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta);
		r.stageX = e.stageX;
		r.stageY = e.stageY;
		return r;
	}
	/// Translates JavaScript event into OpenFL-bitfive one:
	private function _translateMouseEvent(e:js.html.MouseEvent, type:String):MouseEvent {
		return new MouseEvent(type, true, false, null, null, null, e.ctrlKey, e.altKey, e.shiftKey);
	}
	private function onTouch(e:js.html.TouchEvent):Void {
		isTouchScreen = true;
		e.preventDefault();
		var l:Int = e.targetTouches.length, n:Int = touchCount, t:String, f:MouseEvent,
			q:js.html.Touch = l > 0 ? e.targetTouches[0] : null;
		touchCount = l;
		// update mouse coordinates:
		if (l > 0) mousePos.setTo(q.pageX, q.pageY);
		// determine correct event via current-previous state difference:
		t = (l != 0 && n == 0) ? MouseEvent.MOUSE_DOWN
			: (l == 0 && n != 0) ? MouseEvent.MOUSE_UP
			: MouseEvent.MOUSE_MOVE;
		_broadcastMouseEvent(new MouseEvent(t));
	}
	private function onWheel(e:js.html.WheelEvent):Void {
		var f:MouseEvent = _translateMouseEvent(e, MouseEvent.MOUSE_WHEEL);
		// approximation (Flash counts lines, HTML5 counts pixels):
		f.delta = Math.round(e.wheelDelta / 40);
		mousePos.setTo(e.pageX, e.pageY);
		_broadcastMouseEvent(f);
	}
	private function onMouse(e:js.html.MouseEvent):Void {
		if (isTouchScreen) return;
		mousePos.setTo(e.pageX, e.pageY);
		// Convert events accordingly:
		var t:String = null;
		switch (e.type) {
		case "click": switch (e.button) {
			case 0: t = MouseEvent.CLICK;
			case 1: t = MouseEvent.MIDDLE_CLICK;
			case 2: t = MouseEvent.RIGHT_CLICK;
			}
		case "mousemove":
			t = MouseEvent.MOUSE_MOVE;
		case "mousedown": switch (e.button) {
			case 0: t = MouseEvent.MOUSE_DOWN;
			case 1: t = MouseEvent.MIDDLE_MOUSE_DOWN;
			case 2: t = MouseEvent.RIGHT_MOUSE_DOWN;
			}
		case "mouseup": switch (e.button) {
			case 0: t = MouseEvent.MOUSE_UP;
			case 1: t = MouseEvent.MIDDLE_MOUSE_UP;
			case 2: t = MouseEvent.RIGHT_MOUSE_UP;
			}
		}
		if (t != null) {
			_broadcastMouseEvent(new MouseEvent(t));
		}
	}
	override public function hitTestLocal(x:Float, y:Float, p:Bool):Bool {
		return true;
	}
	// a not-very-smart method of adding Stage listeners to Window, as opposed to it's Div.
	override public function addEventListener(type:String, listener:Dynamic -> Void,
	useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		var o = component; component = untyped window;
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		component = o;
	}
	override public function removeEventListener(type:String, listener:Dynamic -> Void,
	useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		var o = component; component = untyped window;
		super.removeEventListener(type, listener, useCapture, priority, useWeakReference);
		component = o;
	}
	//
	function get_focus():InteractiveObject {
		var o:Dynamic = untyped document.activeElement;
		return o != null && Std.is(o = o.node, InteractiveObject) ? o : null;
	}
	function set_focus(v:InteractiveObject):InteractiveObject {
		if (v != null) v.giveFocus();
		else component.blur();
		return v;
	}
	function get_stageWidth():Int {
		return Browser.window.innerWidth;
	}
	function get_stageHeight():Int {
		return Browser.window.innerHeight;
	}
	override private function get_stage():Stage {
		return this;
	}
	private function set_frameRate(v:Float):Float {
		if (frameRate != v) {
			frameRate = v;
			#if !OFL_SETTIMEOUT
			if (frameInterval != 0) Lib.window.clearInterval(frameInterval);
			if (v == 0) {
				frameInterval = 0;
				Lib.requestAnimationFrame(onTimer);
			} else frameInterval = Lib.window.setInterval(onTimer, Std.int(Math.max(0, 1000 / v)));
			#end
		}
		return v;
	}
	private function onTimer():Void {
		var t = Lib.getTimer(), f:Float;
		// handle scheduled executions:
		var i:Int = -1;
		while (++i < Lib.schLength) {
			Lib.schList[i]();
			Lib.schList[i] = null;
		}
		Lib.schLength = 0;
		//
		broadcastEvent(new flash.events.Event(flash.events.Event.ENTER_FRAME));
		// schedule next event:
		f = frameRate;
		if (f <= 0) Lib.requestAnimationFrame(onTimer);
		#if OFL_SETTIMEOUT
		else Lib.window.setTimeout(onTimer, Std.int(Math.max(0, t + 1000 / f - Lib.getTimer())));
		#end
	}
}
#end
