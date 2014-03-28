package openfl.display;
#if js


import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;


class Tilesheet {
	
	
	@:extern public static inline var TILE_SCALE = 0x0001;
	@:extern public static inline var TILE_ROTATION = 0x0002;
	@:extern public static inline var TILE_RGB = 0x0004; // not supported
	@:extern public static inline var TILE_ALPHA = 0x0008;
	@:extern public static inline var TILE_TRANS_2x2 = 0x0010;
	@:extern public static inline var TILE_BLEND_NORMAL = 0x00000000;
	@:extern public static inline var TILE_BLEND_ADD = 0x00010000;
	
	// Despite of being private, fields are used by multiple frameworks. Seal of disaproval.
	/** @private */ public var nmeBitmap:BitmapData;
	/** @private */ public var qOffsets:Array<Point>;
	/** @private */ public var qRects:Array<Rectangle>;
	private var bounds:Rectangle;
	private var tile:Rectangle;
	private var matrix:Matrix;
	
	
	public function new(image:BitmapData) {
		nmeBitmap = image;
		qOffsets = new Array<Point>();
		qRects = new Array<Rectangle>();
		//
		bounds = new Rectangle();
		tile = new Rectangle();
		matrix = new Matrix();
	}
	
	
	public function addTileRect(r:Rectangle, p:Point = null):Int {
		if (p == null) p = new Point();
		// optimize?
		/*if (r.x < 0) { p.x += r.x; r.x = 0; }
		if (r.y < 0) { p.y += r.y; r.y = 0; }
		if (r.right > nmeBitmap.width) r.right = nmeBitmap.width;*/
		//
		qRects.push(r);
		qOffsets.push(p);
		return qRects.length - 1;
	}
	
	public function getTileCenter(i:Int):Point return qOffsets[i];
	public function getTileRect(i:Int):Rectangle return qRects[i];
	
	public function drawTiles(g:Graphics, d:Array<Float>, smooth:Bool = false, f:Int = 0):Void {
		//
		var lenOfs:Int,
			tc:Int = 0, // tile count
			nr = g.frec, np = g.flen,
			i:Int = 0, c:Int = d.length, j:Int,
			z:Int = 0, // extra data length
			t:Int, o:Point, q:Rectangle, // tile data
			v:Float, // swap
			b:Rectangle = bounds,
			u:Rectangle = tile, // transformed tile rectangle
			m:Matrix = matrix,
			tx:Float, ty:Float,
			ox:Float, oy:Float,
			qx:Float, qy:Float, qw:Float, qh:Float, // tile rectangle
			fs:Bool = (f & TILE_SCALE) != 0, // scale
			fr:Bool = (f & TILE_ROTATION) != 0, // rotate
			fm:Bool = (f & TILE_TRANS_2x2) != 0, // matrix
			ft:Bool = fs || fr || fm, // any transform
			rl:Float = 0x7fffffff, rt:Float = 0x7fffffff,
			rr:Float = -0x80000000, rb:Float = -0x80000000; // bounds
		// helpers:
		inline function addf(v:Float):Float return nr[np++] = v;
		//
		g.addInt(16); // Graphics.GFX_TILES
		g.addObject(nmeBitmap);
		g.addInt(f);
		// find extra data length:
		if ((f & TILE_RGB) != 0) z += 3;
		if ((f & TILE_ALPHA) != 0) z++;
		//
		b.setVoid();
		while (i < c) {
			// x, y:
			addf(tx = d[i++]);
			addf(ty = d[i++]);
			// parse tile ID into offset + rectangle list:
			t = cast d[i++];
			q = qRects[t];
			o = qOffsets[t];
			// add offset & rectangle:
			addf(ox = o.x); addf(oy = o.y);
			addf(qx = q.x); addf(qy = q.y);
			addf(qw = q.width); addf(qh = q.height);
			// handle bounds:
			u.x = -o.x; u.width = q.width;
			u.y = -o.y; u.height = q.height;
			if (ft) { // bounds transformations
				m.identity();
				if (fm) { // matrix
					addf(m.a = d[i++]);
					addf(m.b = d[i++]);
					addf(m.c = d[i++]);
					addf(m.d = d[i++]);
				} else { // rotation/scaling
					if (fs) m.scale(addf(v = d[i++]), v);
					if (fr) m.rotate(addf(d[i++]));
				}
				m.translate(q.x, q.y);
				u.transform(m);
			}
			u.x += tx; u.y += ty;
			b.join(u);
			// push extra data:
			j = 0; while (j++ < z) addf(d[i++]);
			tc++;
		}
		g.addInt(tc);
		g.flen = np;
		g.grab(b.x, b.y, b.x + b.width, b.y + b.height);
	}
	
	
}


#end
