package flash.display;
#if js
import flash.events.Event;
import flash.events.EventWrapper;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.Lib;
/**
 * Supports a couple of things. No filters or clipping yet.
 * @author YellowAfterlife
 */
class DisplayObject extends EventWrapper {
	public var stage(get, set):Stage;
	public var name:String;
	//
	public var visible(default, set):Bool = true;
	public var alpha(default, set):Float = 1;
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;
	public var rotation(default, set):Float = 0;
	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var parent:DisplayObjectContainer;
	public var scrollRect(default, set):Rectangle;
	public var mask:DisplayObject;
	public var transform:Transform;
	public var filters:Array<Dynamic>;
	//
	public var loaderInfo:LoaderInfo;
	//
	public var mouseX(get, null):Float;
	public var mouseY(get, null):Float;
	//
	private var _stage:Stage;
	private var qWidth:Null<Float>;
	private var qHeight:Null<Float>;
	//
	public function new() {
		super();
		eventRemap = new Map();
		if (component == null) component = Lib.jsDiv();
		untyped component.node = this;
		#if debug
			component.setAttribute("node", Type.getClassName(Type.getClass(this)));
		#end
		transform = new Transform(this);
	}
	
	public function broadcastEvent(e:Event):Void {
		dispatchEvent(e);
	}
	
	public function invalidate():Void {
		
	}
	//
	private var _syncMtx_set:Bool;
	public function syncMtx():Void {
		var s = component.style, v, n;
		if (_syncMtx_set != true) {
			_syncMtx_set = true;
			// More than likely not actually needed.
			Lib.setCSSProperties(s, "transform-origin", "0% 0%", 31);
		}
		v = "";
		// ttip: transformations are applied in reverse order here
		if (x != 0 || y != 0) v += "translate(" + x + "px, " + y + "px) ";
		if (scaleX != 1 || scaleY != 1) v += "scale(" + scaleX + ", " + scaleY + ") ";
		if (rotation != 0) v += "rotate(" + rotation + "deg) ";
		if (transform != null) {
			var m = transform.matrix;
			if (m != null && !m.isIdentity()) v += m.toString() + " ";
		}
		#if debug
			component.setAttribute("transform", v);
		#end
		n = "transform";
		s.setProperty(n, v, null);
		s.setProperty("-o-" + n, v, null);
		s.setProperty("-ms-" + n, v, null);
		s.setProperty("-moz-" + n, v, null);
		s.setProperty("-webkit-" + n, v, null);
	}
	private function set_x(v:Float):Float {
		if (x != v) {
			x = v; syncMtx();
		} return v;
	}
	private function set_y(v:Float):Float {
		if (y != v) {
			y = v; syncMtx();
		} return v;
	}
	private function set_rotation(v:Float):Float {
		if (rotation != v) {
			rotation = v; syncMtx();
		} return v;
	}
	private function set_scaleX(v:Float):Float {
		if (scaleX != v) {
			scaleX = v; syncMtx();
		} return v;
	}
	private function set_scaleY(v:Float):Float {
		if (scaleY != v) {
			scaleY = v; syncMtx();
		} return v;
	}
	//
	private function get_width():Float { return untyped qWidth || 0; }
	private function get_height():Float { return untyped qHeight || 0; }
	private function set_width(v:Float):Float {
		var q = width;
		scaleX = (q == 0 || q == null) ? 1 : v / q;
		qWidth = v;
		return v;
	}
	private function set_height(v:Float):Float {
		var q = height;
		scaleY = (q == 0 || q == null) ? 1 : v / q;
		qHeight = v;
		return v;
	}
	private function set_alpha(v:Float):Float {
		if (v != alpha) {
			component.style.opacity = untyped (alpha = v).toFixed(4);
		} return v;
	}
	private function set_visible(v:Bool):Bool {
		component.style.display = (visible = v) ? null : "none";
		return v;
	}
	private function set_scrollRect(v:Rectangle):Rectangle {
		Lib.trace(Std.string(this) + ".scrollRect = " + Std.string(v));
		return v;
	}
	//
	
	private function get_stage():Stage { return _stage; }
	private function set_stage(v:Stage):Stage {
		if (_stage != v) {
			var z = (_stage != null) != (v != null);
			_stage = v;
			if (z) dispatchEvent(new Event(v != null
				? Event.ADDED_TO_STAGE : Event.REMOVED_FROM_STAGE));
		}
		return v;
	}
	//
	public function getBounds(?o:DisplayObject):Rectangle {
		var m:Matrix = getGlobalMatrix(), r:Rectangle = new Rectangle(0, 0, width, height);
		if (o == null) o = this;
		if (o != this) {
			r.transform(m);
			if (o != null) {
				m = o.getGlobalMatrix();
				m.invert();
				r.transform(m);
			}
		}
		return r;
	}
	public function getRect(?o:DisplayObject):Rectangle {
		return getBounds(o);
	}
	//
	/// Adds current transformation to specified matrix
	public function concatTransform(m:Matrix):Void {
		if (!transform.matrix.isIdentity()) m.concat(transform.matrix);
		if (rotation != 0) m.rotate(rotation * Math.PI / 180);
		if (scaleX != 1 || scaleY != 1) m.scale(scaleX, scaleY);
		if (x != 0 || y != 0) m.translate(x, y);
	}
	private static var convMatrix:Matrix;
	private static var convPoint:Point;
	private function getGlobalMatrix(?m:Matrix):Matrix {
		if (m == null) m = new Matrix();
		var o:DisplayObject = this;
		while (o != null) {
			o.concatTransform(m);
			o = o.parent;
		}
		return m;
	}
	public function globalToLocal(q:Point, ?r:Point):Point {
		if (r == null) r = new Point();
		var m:Matrix = convMatrix, u = q.x, v = q.y;
		if (m == null) m = convMatrix = new Matrix();
		m.identity();
		m = getGlobalMatrix(m);
		m.invert();
		r.x = u * m.a + v * m.c + m.tx;
		r.y = u * m.b + v * m.d + m.ty;
		return r;
	}
	public function localToGlobal(q:Point, ?r:Point):Point {
		if (r == null) r = new Point();
		var m:Matrix = convMatrix, u = q.x, v = q.y;
		if (m == null) m = convMatrix = new Matrix();
		m.identity();
		m = getGlobalMatrix(m);
		r.x = u * m.a + v * m.c + m.tx;
		r.y = u * m.b + v * m.d + m.ty;
		return r;
	}
	private function get_mouseX():Float {
		return (convPoint = globalToLocal(Lib.current.stage.mousePos, convPoint)).x;
	}
	private function get_mouseY():Float {
		return (convPoint = globalToLocal(Lib.current.stage.mousePos, convPoint)).y;
	}
	///
	public function hitTestPoint(x:Float, y:Float, p:Bool = false):Bool {
		convPoint.x = x;
		convPoint.y = y;
		globalToLocal(convPoint, convPoint);
		return hitTestLocal(convPoint.x, convPoint.y, p);
	}
	/**
	 * Tests whether a local point is overlapping the object
	 * @param	x	Point X
	 * @param	y	Point Y
	 * @param	p	Whether to use precise checks
	 * @param	v	Whether to take visibility into account
	 * @return
	 */
	public function hitTestLocal(x:Float, y:Float, p:Bool, ?v:Bool):Bool {
		return hitTestVisible(v) && x >= 0 && y >= 0 && x <= width && y <= height;
	}
	
	@:extern private inline function hitTestVisible(v:Bool):Bool {
		return (!v || visible);
	}
	//
	private var eventRemap:Map<String, Dynamic->Void>;
	static private var routedEvents:Map<String, Int>;
	override public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, weak:Bool = false):Void {
		super.addEventListener(type, listener, useCapture, priority, weak);
		/*if (remapTouch.exists(type)) {
			var f = function(e:js.html.TouchEvent):Void {
				var n = new flash.events.MouseEvent(type, e.bubbles, e.cancelable, 0, 0, cast this,
					e.ctrlKey, e.altKey, e.shiftKey, false), l = e.targetTouches;
				if (l.length > 0) {
					untyped n.pageX = l[0].pageX;
					untyped n.pageY = l[0].pageY;
				} else {
					untyped n.pageX = stage.mousePos.x;
					untyped n.pageY = stage.mousePos.y;
				}
				dispatchEvent(n);
			};
			super.addEventListener(remapTouch.get(type), f, useCapture, priority, weak);
		}*/
	}
	/**
	 * This method of fair complication handles routing of mouse events through the DOM tree.
	 * @param	h	"History" of DisplayObjects (hierarchy)
	 * @param	e	MouseEvent to be dispatched
	 * @param	ms	Matrix stack (auto-filled)
	 * @param	mc	Matrix cache (matrices are taken from and pushed back into here)
	 * @return	Whether an event was triggered
	 */
	public function broadcastMouse(h:Array<DisplayObject>, e:MouseEvent,
	ms:Array<Matrix>, mc:Array<Matrix>):Bool {
		if (!visible) return false;
		var o:DisplayObject, t:String = e.type, m:Matrix, m2:Matrix, d:Int = h.length, l:Int, x:Float, y:Float;
		if (hasEventListener(t) || (t == MouseEvent.MOUSE_MOVE && (
		hasEventListener(t = MouseEvent.MOUSE_OVER) ||
		hasEventListener(t = MouseEvent.MOUSE_OUT)))) {
			h.push(this);
			m = mc.length > 0 ? mc.pop() : new Matrix();
			// Lazy exploration: matrices are only calculated if actually needed:
			l = ms.length;
			while (l <= d) { // "<=" since "d" increases by 1 since it's assignment
				o = h[l];
				m.identity();
				o.concatTransform(m);
				m.invert();
				// Set step matrix to one of previous step + one just calculated
				m2 = mc.length > 0 ? mc.pop() : new Matrix();
				if (l > 0) m2.copy(ms[l - 1]); else m2.identity();
				m2.concat(m);
				ms.push(m2);
				l++;
			}
			// Transform mouse coordinates from global to local:
			m.copy(ms[d]);
			//Lib.trace(m.toString());
			x = e.stageX * m.a + e.stageY * m.c + m.tx;
			y = e.stageX * m.b + e.stageY * m.d + m.ty;
			//Lib.trace(e.stageX + ' ' + e.stageY + ' -> $x $y');
			// clean-up:
			mc.push(m);
			h.pop();
			// dispatch events if mouse did hit the object:
			if (hitTestLocal(x, y, true, true)) {
				if (e.relatedObject == null) {
					e.localX = x;
					e.localY = y;
					e.relatedObject = cast this;
				}
				if (t == e.type) {
					dispatchEvent(e);
					return true;
				}
			}
		}
		return false;
	}
	//
	override public function dispatchEvent(event:Event):Bool {
		var r:Bool = super.dispatchEvent(event);
		// some events will not bubble naturally, thus:
		if (r && routedEvents.exists(event.type) && event.bubbles) {
			var o:DisplayObjectContainer = parent;
			if (o != null) o.dispatchEvent(event);
		}
		return r;
	}
	//
	public function toString():String {
		return Type.getClassName(Type.getClass(this));
	}
	//
	private static function __init__():Void (function() {
		routedEvents = new Map();
		var m = [
			MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT,
			MouseEvent.CLICK, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP,
			MouseEvent.RIGHT_CLICK, MouseEvent.RIGHT_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_UP,
			MouseEvent.MIDDLE_CLICK, MouseEvent.MIDDLE_MOUSE_DOWN, MouseEvent.MIDDLE_MOUSE_UP,
			MouseEvent.MOUSE_WHEEL], i:Int = -1, l:Int = m.length;
		while (++i < l) routedEvents.set(m[i], 1);
	})();
}
#end
