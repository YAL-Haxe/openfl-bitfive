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
	
	public function setTo(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
		this.a = a; this.b = b; this.tx = tx;
		this.c = c; this.d = d; this.ty = ty;
	}
	
	public inline function clone() {
		return new Matrix(a, b, c, d, tx, ty);
	}
	/** Resets matrix state */
	public function identity():Void {
		a = d = 1;
		b = c = tx = ty = 0;
	}
	/** Returns whether matrix is in identity state */
	public function isIdentity():Bool {
		return a == 1 && d == 1 && tx == 0 && ty == 0 && b == 0 && c == 0;
	}
	/** Mimics properties of specified matrix*/
	public function copy(s:Matrix):Void {
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
	
	public function transformPoint(o:Point):Point {
		return new Point(o.x * a + o.y * c + tx, o.x * b + o.y * d + ty);
	}
	
	public function createBox(sx:Float, sy:Float, ?r:Float, ?x:Float, ?y:Float) {
		a = sx;
		d = sy;
		b = Lib.nz(r, 0); // ?
		tx = Lib.nz(x, 0);
		ty = Lib.nz(y, 0);
	}
	
	public function createGradientBox(w:Float, h:Float, ?r:Float, ?x:Float, ?y:Float) {
		// ?:
		a = w / 1638.4;
		d = h / 1638.4;
		if (r != null && r != 0) {
			var rx = Math.cos(r), ry = Math.sin(r);
			b = ry * d;
			c = -ry * a;
			a *= rx;
			d *= rx; // ?
		} else b = c = 0;
		tx = x != null ? x + w / 2 : w / 2;
		ty = y != null ? y + h / 2 : h / 2;
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
	
	// A little bit of pooling
	/** Pool of reusable matrices */
	public static var pool:Array<Matrix> = [];
	/** Creates or takes a matrix from pool. Contents may vary. */
	public static function create():Matrix {
		var m:Array<Matrix> = pool;
		return m.length > 0 ? m.pop() : new Matrix();
	}
	/** Pushes current matrix into reusable object pool. Do not access it afterwards. */
	public inline function free() {
		pool.push(this);
	}
}