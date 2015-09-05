package openfl.geom;

/**
 * ...
 * @author YellowAfterlife
 */

class Point {
	public var x:Float;
	public var y:Float;
	//
	public function new(?u:Float, ?v:Float) {
		x = Lib.nz(u, 0);
		y = Lib.nz(v, 0);
	}
	// Misc & meta:
	public function clone():Point {
		return new Point(x, y);
	}
	
	public function equals(o:Point):Bool {
		return x == o.x && y == o.y;
	}
	
	public function setTo(u:Float, v:Float):Void {
		x = u; y = v;
	}
	
	public var length(get_length, null):Float;
	private function get_length() {
		return Math.sqrt(x * x + y * y);
	}
	
	public function toString() {
		return 'point(' + x + ', ' + y + ')';
	}
	// Mutator methods:
	public function normalize(l:Float) {
		if (y == 0) x = x < 0 ? -l : l;
		else if (x == 0) y = y < 0 ? -l : l;
		else {
			var m = l / Math.sqrt(x * x + y * y);
			x *= m;
			y *= m;
		}
	}
	
	public function offset(dx:Float, dy:Float) {
		x += dx;
		y += dy;
	}
	
	// 'Operators':
	public function add(o:Point):Point {
		return new Point(x + o.x, y + o.y);
	}
	
	public function subtract(o:Point):Point {
		return new Point(x - o.x, y - o.y);
	}
	
	// Static methods:
	public static function interpolate(a:Point, b:Point, f:Float):Point {
		return new Point(a.x + f * (b.x - a.x), a.y + f * (b.y - a.y));
	}
	
	public static function polar(l:Float, d:Float):Point {
		return new Point(Math.cos(d) * l, Math.sin(d) * l);
	}
	
}
