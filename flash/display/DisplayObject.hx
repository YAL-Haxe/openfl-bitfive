package flash.display;
#if js
import flash.events.Event;
import flash.events.EventWrapper;
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
			v = "0% 0%";
			n = "syncMtx-origin";
			s.setProperty(n, v, null);
			s.setProperty("-o-" + n, v, null);
			s.setProperty("-ms-" + n, v, null);
			s.setProperty("-moz-" + n, v, null);
			s.setProperty("-webkit-" + n, v, null);
		}
		v = "";
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
		//Lib.trace(Std.string(this) + ".width = " + v);
		if (width == 0 || width == null)
		{
			scaleX = 1;
		}
		else
		{
			scaleX = v / this.width;
		}
		qWidth = v;
		return v;
	}
	private function set_height(v:Float):Float {
		//Lib.trace(Std.string(this) + ".height = " + v);
		if (height == 0 || height == null)
		{
			scaleY = 1;
		}
		else
		{
			scaleY = v / this.height;
		}
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
	private static var convMatrix:Matrix;
	private static var convPoint:Point;
	private function getGlobalMatrix(?m:Matrix):Matrix {
		if (m == null) m = new Matrix();
		var o:DisplayObject = this;
		while (o != null) {
			if (x != 0 || y != 0) m.translate(x, y);
			if (scaleX != 1 || scaleY != 1) m.scale(scaleX, scaleY);
			if (rotation != 0) m.rotate(rotation);
			m.concat(o.transform.matrix);
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
	//
	private var eventRemap:Map<String, Dynamic->Void>;
	static private var remapTouch:Map<String, String>;
	override public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, weak:Bool = false):Void {
		super.addEventListener(type, listener, useCapture, priority, weak);
		if (remapTouch.exists(type)) {
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
		}
	}
	//
	public function toString():String {
		return Type.getClassName(Type.getClass(this));
	}
	//
	private static function __init__():Void {
		remapTouch = new Map();
		remapTouch.set("mousedown", "touchstart");
		remapTouch.set("mousemove", "touchmove");
		remapTouch.set("mouseup", "touchend");
	}
}
#end