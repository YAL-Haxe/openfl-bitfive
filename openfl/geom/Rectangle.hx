package openfl.geom;

class Rectangle {
	// Properties:
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	// Float fields:
	public var left(get, set):Float;
	public var right(get, set):Float;
	public var top(get, set):Float;
	public var bottom(get, set):Float;
	// Point fields:
	public var size(get, set):Point;
	public var topLeft(get, set):Point;
	public var bottomRight(get, set):Point;
	// Meta:
	public function new(a:Float = 0, b:Float = 0, c:Float = 0, d:Float = 0):Void {
		this.x = a;
		this.y = b;
		this.width = c;
		this.height = d;
	}
	public function clone():Rectangle {
		return new Rectangle(x, y, width, height);
	}
	public function equals(o:Rectangle):Bool {
		return x == o.x && y == o.y && width == o.width && height == o.height;
	}
	public function isEmpty():Bool {
		return width <= 0 || height <= 0;
	}
	public function setEmpty():Void {
		x = y = width = height = 0;
	}
	public function copyFrom(o:Rectangle):Void {
		x = o.x;
		y = o.y;
		width = o.width;
		height = o.height;
	}
	public function setTo(a:Float, b:Float, c:Float, d:Float):Void {
		x = a; y = b; width = c; height = d;
	}
	public function setVoid():Void {
		//x = y = 0x7fffffff;
		//width = height = -0xffffffff;
		left = 0x7fffffff;
		right = -0x80000000;
		top = 0x7fffffff;
		bottom = -0x80000000;
	}
	// Float fields:
	private inline function get_left():Float { return x; }
	private inline function set_left(v:Float):Float { width -= v - x; return (x = v); }
	private inline function get_top():Float { return y; }
	private inline function set_top(v:Float) { height -= v - y; return (y = v); }
	private inline function get_right():Float { return x + width; }
	private inline function set_right(v:Float):Float { width = v - x; return v; }
	private inline function get_bottom():Float { return y + height; }
	private inline function set_bottom(v:Float):Float { height = v - y; return v; }
	// Point fields:
	private inline function get_size():Point { return new Point(width, height); }
	private inline function set_size(v:Point):Point { width = v.x; height = v.y; return v.clone(); }
	private inline function get_topLeft():Point { return new Point(x, y); }
	private inline function set_topLeft(v:Point):Point { width = v.x; height = v.y; return v.clone(); }
	private inline function get_bottomRight():Point { return new Point(x + width, y + height); }
	private inline function set_bottomRight(v:Point):Point { width = v.x - x; height = v.y - y; return v.clone(); }
	// Contains:
	public function contains(u:Float, v:Float):Bool {
		return (u -= x) >= 0
			&& (v -= y) >= 0
			&& u < width
			&& v < height;
	}
	public inline function containsPoint(o:Point):Bool {
		return contains(o.x, o.y);
	}
	public function containsRect(o:Rectangle):Bool {
		return (o.width <= 0 || o.height <= 0)
		? o.x > x && o.y > y && o.right < right && o.bottom < bottom
		: o.x >= x && o.y >= y && o.right <= right && o.bottom <= bottom;
	}
	//
	public function intersection(o:Rectangle):Rectangle {
		var x0:Float, x1:Float, y0:Float, y1:Float, a:Float, b:Float;
		return
		((x0 = (a = x) < (b = o.x) ? b : a)
		<= (x1 = (a += width) > (b += o.width) ? b : a))
		&& ((y0 = (a = y) < (b = o.y) ? b : a)
		<= (y1 = (a += height) > (b += o.height) ? b : a))
		? new Rectangle(x0, y0, x1 - x0, y1 - y0) : new Rectangle();
	}
	public function intersects(o:Rectangle):Bool {
		var x0, x1, y0, y1;
		return (x0 = (x < (x0 = o.x) ? x0 : x))
			<= (x1 = (right > (x1 = o.right) ? x1 : right))
			? false : (y0 = (y < (y0 = o.y) ? y0 : y))
			<= (y1 = (bottom > (y1 = o.bottom) ? y1 : y));
	}
	//
	public function join(o:Rectangle):Void {
		var v:Float;
		if ((v = o.x - x) < 0) { x += v; width -= v; }
		if ((v = o.y - y) < 0) { y += v; height -= v; }
		if ((v = o.right - right) > 0) { width += v; }
		if ((v = o.bottom - bottom) > 0) { height += v; }
	}
	public function union(o:Rectangle):Rectangle {
		var a:Float, b:Float, c:Float, d:Float;
		return new Rectangle(
			(a = x) < (c = o.x) ? a : c,
			(b = y) < (d = o.y) ? b : d,
			(a += width) > (c += o.width) ? a : c,
			(b += height) > (d += o.height) ? b : d);
	}
	//
	public function inflate(u:Float, v:Float):Void {
		x -= u; y -= v; width += u * 2; height += v * 2;
	}
	public function inflatePoint(v:Point):Void {
		inflate(v.x, v.y);
	}
	public function offset(u:Float, v:Float):Void {
		x += u; y += v;
	}
	public function offsetPoint(o:Point):Void {
		x += o.x; y += o.y;
	}
	public function transform(m:Matrix):Void {
		var v, l, t, r, b;
		// top left (default):
		r = l = m.a * x + m.c * y;
		b = t = m.b * x + m.d * y;
		// top right:
		v = m.a * (x + width) + m.c * y;
		if (v < l) l = v; if (v > r) r = v;
		v = m.b * (x + width) + m.d * y;
		if (v < t) t = v; if (v > b) b = v;
		// bottom left:
		v = m.a * x + m.c * (y + height);
		if (v < l) l = v; if (v > r) r = v;
		v = m.b * x + m.d * (y + height);
		if (v < t) t = v; if (v > b) b = v;
		// bottom right:
		v = m.a * (x + width) + m.c * (y + height);
		if (v < l) l = v; if (v > r) r = v;
		v = m.b * (x + width) + m.d * (y + height);
		if (v < t) t = v; if (v > b) b = v;
		// save:
		x = l + m.tx; width = r - l;
		y = t + m.ty; height = b - t;
	}
	public function toString():String {
		return "Rectangle(" + x + ", " + y + ", " + width + ", " + height + ")";
	}
}