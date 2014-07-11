package flash.display;
#if js
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.Lib;
import js.Browser;
import js.html.CSSStyleDeclaration;
import js.html.DOMWindow;
import js.html.Element;
import js.html.Touch;
import js.html.TouchList;
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
	public var frameRate(default, set):Float = null; // should be retrieved from XML instead.
	public var focus(get, set):InteractiveObject;
	public var mousePos:Point;
	#if bitfive_gamepads
	public var joystickHandler:flash.ui.JoystickHandler;
	#end
	/** Whether device is touch screen.
	 * If device dispatches touch events, these are more reliable source of mouse coordinates */
	public var isTouchScreen:Bool = false;
	private var touchCount:Int = 0;
	//
	#if !bitfive_setTimeout
	private var intervalHandle:Dynamic = null;
	#end
	//
	public function new() {
		super();
		var s:CSSStyleDeclaration = component.style, o:DOMWindow = Lib.window, i:Int;
		s.position = "absolute";
		s.overflow = "hidden";
		s.left = s.top = "0";
		s.width = s.height = "100%";
		mousePos = new Point();
		// right and other clicks:
		#if !bitfive_allowContextMenu
		o.addEventListener("contextmenu", function(_:js.html.Event) _.preventDefault());
		#end
		// mouse listeners:
		o.addEventListener("click", onMouse);
		o.addEventListener("mousedown", onMouse);
		o.addEventListener("mouseup", onMouse);
		o.addEventListener("mousemove", onMouse);
		o.addEventListener("mousewheel", onWheel);
		// touch events (to prevent scrolling and to track mouse position):
		o.addEventListener("touchmove", getOnTouch(0));
		o.addEventListener("touchstart", getOnTouch(1));
		o.addEventListener("touchend", getOnTouch(2));
		o.addEventListener("touchcancel", getOnTouch(2));
		//
		mouseMtxDepth = [];
		mouseMtxStack = [];
		mouseMtxCache = [];
		mouseTriggered = [];
		mouseUntrigger = [];
		i = -1; while (++i < 3) {
			mouseTriggered[i] = false;
			mouseUntrigger[i] = getMouseUntrigger(i);
		}
		
		#if bitfive_gamepads
		joystickHandler = new flash.ui.JoystickHandler(this);
		#end
	}
	// Mouse magic
	private var mouseMtxDepth:Array<DisplayObject>;
	private var mouseMtxStack:Array<Matrix>;
	private var mouseMtxCache:Array<Matrix>;
	private var mouseOver:DisplayObject;
	private var mouseDown:Bool;
	private var mouseLastEvent:MouseEvent;
	private var mouseTriggered:Array<Bool>;
	private var mouseUntrigger:Array<Void->Void>;
	private var mouseDownTriggered:Bool;
	private var mouseUpTriggered:Bool;
	//
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
	private function _broadcastTouchEvent(f:flash.events.TouchEvent, x:Float, y:Float):Void {
		f.stageX = x;
		f.stageY = y;
		broadcastMouse(mouseMtxDepth, f, mouseMtxStack, mouseMtxCache);
	}
	private function getMouseUntrigger(i:Int):Void->Void {
		return function() mouseTriggered[i] = false;
	}
	/// Creates a copy of MouseEvent with new type.
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
	///
	private function _translateTouchEvent(e:js.html.TouchEvent, o:Touch, type:String):TouchEvent {
		return new TouchEvent(type, true, false, o.identifier, false,
			null, null, o.radiusX, o.radiusY, o.force, null, e.ctrlKey, e.altKey, e.shiftKey);
	}
	/**
	 * Prevents duplicate mouse+touch events from triggering.
	 * @param	o	Event type (0: move, 1: down, 2: up)
	 * @param	x	Page X
	 * @param	y	Page Y
	 * @return	Whether event is duplicate.
	 */
	private function mouseEventPrevent(o:Int, x:Float, y:Float):Bool {
		var mp = mousePos, q = (mp.x == x && mp.y == y);
		if (o >= 0 && q && mouseTriggered[o]) return true;
		// switch to new position:
		if (!q) mousePos.setTo(x, y);
		// mark event as triggered:
		if (o >= 0 && !mouseTriggered[o]) {
			mouseTriggered[o] = true;
			Lib.window.setTimeout(mouseUntrigger[o], 0);
		}
		// handle forgotten events
		if (o == 1) {
			if (mouseDown) {
				_broadcastMouseEvent(_alterMouseEvent(mouseLastEvent, MouseEvent.MOUSE_UP));
			} else mouseDown = true;
		} else if (o == 2) {
			if (!mouseDown) _broadcastMouseEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			else mouseDown = false;
		}
		//
		return false;
	}
	private function getOnTouch(i:Int):js.html.TouchEvent->Void {
		return function(e:js.html.TouchEvent) onTouch(e, i);
	}
	private function onTouch(e:js.html.TouchEvent, m:Int):Void {
		var lt:TouchList = e.targetTouches,
			nt:Int = lt.length,
			lc:TouchList = e.changedTouches,
			nc:Int = lc.length,
			qt:Touch = nt > 0 ? lt[0] : nc > 0 ? lc[0] : null,
			i:Int, t:String, o:Touch;
		//
		e.preventDefault();
		isTouchScreen = true;
		//
		if (qt != null && (
			(m == 0) || // swipes are okay
			(m == 1 && nt == nc) || // first touch pressed
			(m == 2 && nt == 0 && nc > 0) // last touch released
		) && !mouseEventPrevent(m, qt.pageX, qt.pageY)) {
			_broadcastMouseEvent(mouseLastEvent = new MouseEvent(
				m == 1 ? MouseEvent.MOUSE_DOWN :
				m == 2 ? MouseEvent.MOUSE_UP : MouseEvent.MOUSE_MOVE));
			// click events:
			if (m == 2) _broadcastMouseEvent(new MouseEvent(MouseEvent.CLICK));
		}
		//
		if (nc > 0) {
			switch (m) {
			case 1: t = TouchEvent.TOUCH_BEGIN;
			case 2: t = TouchEvent.TOUCH_END;
			default: t = TouchEvent.TOUCH_MOVE;
			}
			i = -1; while (++i < nc) {
				o = lc[i];
				_broadcastTouchEvent(_translateTouchEvent(e, o, t), o.pageX, o.pageY);
			}
		}
	}
	private function onWheel(e:js.html.WheelEvent):Void {
		var f:MouseEvent = _translateMouseEvent(e, MouseEvent.MOUSE_WHEEL);
		// approximation (Flash counts lines, HTML5 counts pixels):
		f.delta = Math.round(e.wheelDelta / 40);
		mousePos.setTo(e.pageX, e.pageY);
		_broadcastMouseEvent(f);
	}
	private function onMouse(e:js.html.MouseEvent):Void {
		// Convert events accordingly:
		var t:String = null, o:Int = -1, b:Int;
		if (e.type == "mousemove") {
			t = MouseEvent.MOUSE_MOVE;
			o = 0;
		} else {
			b = e.button;
			switch (e.type) {
			case "click":
				t = b == 0 ? MouseEvent.CLICK :
					b == 1 ? MouseEvent.RIGHT_CLICK :
					b == 2 ? MouseEvent.MIDDLE_CLICK :
					t;
			case "mousedown":
				t = b == 0 ? MouseEvent.MOUSE_DOWN :
					b == 1 ? MouseEvent.MIDDLE_MOUSE_DOWN :
					b == 2 ? MouseEvent.RIGHT_MOUSE_DOWN :
					t;
				o = 1;
			case "mouseup":
				t = b == 0 ? MouseEvent.MOUSE_UP :
					b == 1 ? MouseEvent.MIDDLE_MOUSE_UP :
					b == 2 ? MouseEvent.RIGHT_MOUSE_UP :
					t;
				o = 2;
			default: return;
			}
		}
		if (!mouseEventPrevent(o, e.pageX, e.pageY)) {
			_broadcastMouseEvent(new MouseEvent(t));
		}
		#if bitfive_mouseTouches
		if (!isTouchScreen) {
			switch (e.type) {
			case "mousedown": t = TouchEvent.TOUCH_BEGIN;
			case "mouseup": t = TouchEvent.TOUCH_END;
			default:
				if (mouseDown) t = TouchEvent.TOUCH_MOVE; else return;
			}
			_broadcastTouchEvent(new TouchEvent(t, true, false, 0, false, null, null, 0, 0, 1, null,
				e.ctrlKey, e.altKey, e.shiftKey), e.pageX, e.pageY);
		}
		#end
	}
	override public function hitTestLocal(x:Float, y:Float, p:Bool, ?v:Bool):Bool {
		return hitTestVisible(v);
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
	//
	function get_stageWidth():Int return Lib.window.innerWidth;
	function get_stageHeight():Int return Lib.window.innerHeight;
	override private function get_stage():Stage return this;
	//
	private function set_frameRate(v:Float):Float {
		if (frameRate != v) {
			#if !bitfive_setTimeout
			if (intervalHandle != null)
			if (frameRate <= 0) Lib.cancelAnimationFrame(intervalHandle);
			else Lib.window.clearInterval(intervalHandle);
			intervalHandle = (frameRate = v) <= 0
			? Lib.requestAnimationFrame(onTimer)
			: Lib.window.setInterval(onTimer, Std.int(Math.max(0, 1000 / v)));
			#else
			frameRate = v;
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
		#if bitfive_setTimeout
		if (f <= 0) Lib.requestAnimationFrame(onTimer);
		else Lib.window.setTimeout(onTimer, Std.int(Math.max(0, t + 1000 / f - Lib.getTimer())));
		#else
		if (f <= 0) intervalHandle = Lib.requestAnimationFrame(onTimer);
		#end
	}
}
#end
