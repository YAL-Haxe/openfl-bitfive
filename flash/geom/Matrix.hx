package flash.geom;

/**
 * Not necessarily very well documented Matrix class implementation.
 * @author YellowAfterlife
 */

class Matrix {
	//
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var tx:Float;
	public var ty:Float;
	//
	public function new(?a:Float, ?b:Float, ?c:Float, ?d:Float, ?tx:Float, ?ty:Float) {
		this.a = a == null ? 1 : a;
		this.b = b == null ? 0 : b;
		this.c = c == null ? 0 : c;
		this.d = d == null ? 1 : d;
		this.tx = tx == null ? 0 : tx;
		this.ty = ty == null ? 0 : ty;
	}
	
	public inline function clone() {
		return new Matrix(a, b, c, d, tx, ty);
	}
	
	public function identity() {
		a = d = 1;
		b = c = tx = ty = 0;
	}
	
	public function isIdentity():Bool {
		return a == 1 && d == 1 && tx == 0 && ty == 0 && b == 0 && c == 0;
	}
	
	public function copy(s:Matrix) {
		a = s.a; b = s.b;
		c = s.c; d = s.d;
		tx = s.tx; ty = s.ty;
	}
	
	public function invert() {
		var t, n = a * d - b * c;
		if (n == 0) {
			a = b = c = d = 0;
			tx = -tx;
			ty = -ty;
		} else {
			n = 1 / n;
			//
			t = d * n;
			d = a * n;
			a = t;
			//
			b *= -n;
			c *= -n;
			//
			t = -a * tx - c * ty;
			ty = -b * tx - d * ty;
			tx = t;
		}
	}
	
	
	
	public function translate(x:Float, y:Float) {
		tx += x;
		ty += y;
	}
	
	public function rotate(o:Float) {
		var ox = Math.cos(o), oy = Math.sin(o), t;
		//
		t = a * ox - b * oy;
		b = a * oy + b * ox;
		a = t;
		//
		t = c * ox - d * oy;
		d = c * oy + d * ox;
		c = t;
		//
		t = tx * ox - ty * oy;
		ty = tx * oy + ty * ox;
		tx = t;
	}
	
	public function scale(x:Float, y:Float) {
		a *= x; b *= y;
		c *= x; d *= y;
		tx *= x; ty *= y;
	}
	/** Concatenates with contents of given matrix */
	public function concat(o:Matrix) {
		var t;
		t = a * o.a + b * o.c;
		b = a * o.b + b * o.d;
		a = t;
		//
		t = c * o.a + d * o.c;
		d = c * o.b + d * o.d;
		c = t;
		//
		t = tx * o.a + ty * o.c + o.tx;
		ty = tx * o.b + ty * o.d + o.ty;
		tx = t;
		//
	}
	/** Resets matrix state */
	public function identify() {
		a = 1; b = 0;
		c = 0; d = 1;
		tx = 0; ty = 0;
	}
	
	public function transformPoint(o:Point):Point {
		return new Point(o.x * a + o.y * c + tx, o.x * b + o.y * d + ty);
	}
	
	/// toString methods
	/** Converts to string presentation */
	public inline function toString() {
		return 'matrix('
		+ a + ', ' + b + ', '
		+ c + ', ' + d + ', '
		+ tx + ', ' + ty + ')';
	}
	/** String presentation for Mozilla transformations - with pixel translation values
	 *  Current versions use "normal" format and unprefixed. */
	/*public inline function toMozString() {
		return 'matrix('
		+ a + ', ' + b + ', '
		+ c + ', ' + d + ', '
		+ tx + 'px, ' + ty + 'px)';
	}*/
	/** Converts to a 3d matrix string. Currently only used to force
	 *  hardware acceleration under Webkit, if used at all. */
	public inline function to3dString() {
		return 'matrix3d('
		+ a + ', ' + b + ', 0, 0, '
		+ c + ', ' + d + ', 0, 0, 0, 0, 1, 0, '
		+ tx + ', ' + ty + ', 0, 1)';
	}
	
}