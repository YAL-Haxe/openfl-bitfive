package flash.display;
#if js
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.Lib;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageElement;
/**
 * Status: Getting there.
 * Some standard path functions are supported.
 * Gradients and fancy lines missing.
 * Needs more research on Flash behaviour.
 */
class Graphics implements IBitmapDrawable {
	//
	@:extern private static inline var GFX_STOP = 0;
	@:extern private static inline var GFX_LINESTYLE = 1;
	@:extern private static inline var GFX_FILL_SOLID = 2;
	@:extern private static inline var GFX_FILL_BITMAP = 3;
	@:extern private static inline var GFX_END_FILL = 9;
	@:extern private static inline var GFX_MOVETO = 10;
	@:extern private static inline var GFX_LINETO = 11;
	@:extern private static inline var GFX_CURVETO = 12;
	@:extern private static inline var GFX_RECT = 13;
	@:extern private static inline var GFX_CIRCLE = 14;
	@:extern private static inline var GFX_ROUNDRECT = 15;
	@:extern private static inline var GFX_TILES = 16; // also used in openfl.display.Tilesheet.drawTiles
	//
	@:extern private static inline var GFF_FILL = 1;
	@:extern private static inline var GFF_STROKE = 2;
	@:extern private static inline var GFF_PATTERN = 4;
	@:extern private static inline var GFF_TILED = 8;
	//
	public var component:CanvasElement;
	public var context:CanvasRenderingContext2D;
	public var displayObject(default, set):DisplayObject;
	/** Determines current content bounds. Could use for hitTestPoint? */
	public var bounds(default, null):Rectangle;
	/** Only left here for correct bounds expansion */
	private var lineWidth:Float;
	/** Sequence of drawing commands. Array is cleaned up but never trimmed. */
	public var rec(default, null):Array<Dynamic>;
	public var len:Int;
	private var synced:Bool = true;
	/** Whether a regeneration is already scheduled and no change is needed*/
	private var rgPending:Bool = false;
	private var compX:Int;
	private var compY:Int;
	//
	private var _drawMatrix:Matrix;
	//
	public function new() {
		component = Lib.jsCanvas();
		#if debug
			component.setAttribute("node", Type.getClassName(Type.getClass(this)));
		#end
		context = component.getContext2d();
		context.save();
		bounds = new Rectangle();
		resetBounds();
		//
		rec = [];
		len = 0;
	}
	private function regenerate():Void {
		var o = component, s = component.style, q = context, b = bounds,
			bx:Int = untyped ~~(b.x - 2), by:Int = untyped ~~(b.y - 2),
			bw:Int = Math.ceil(b.width + 4), bh:Int = Math.ceil(b.height + 4);
		// maybe generate higher-resolution graphic if image is scaled?
		// on one hand, higher-quality graphics, but on other hand, would
		// have to override component scaling... somehow?
		synced = true;
		rgPending = false;
		if (b.width <= 0 || b.height <= 0) {
			o.width = o.height = 1;
			s.top = s.left = "0";
			return;
		}
		// take a slightly larger area for case of excessive anti-aliasing:
		if (compX != bx || compY != by) {
			s.left = bx + "px";
			s.top = by + "px";
		}
		if (bw != o.width || bh != o.height) {
			o.width = bw;
			o.height = bh;
		} else q.clearRect(0, 0, o.width, o.height);
		//
		q.save();
		q.translate( -bx, -by);
		render(o, q);
		q.restore();
	}
	private function set_displayObject(v:DisplayObject):DisplayObject {
		if (displayObject != v) {
			displayObject = v;
			if (!synced) Lib.schedule(regenerate);
		}
		return v;
	}
	private function resetBounds():Void {
		bounds.setVoid();
		invalidate();
	}
	/**
	 * Ensures that bounds include given rectangle area.
	 * @param	x	Left/X coordinate of rectangle
	 * @param	y	Top/Y coordinate of rectangle
	 * @param	r	Right coordinate of rectangle
	 * @param	b	Bottom coordinate of rectangle
	 */
	public function grab(x:Float, y:Float, r:Float, b:Float):Void {
		var i;
		if (x < (i = bounds.x)) { i = i - x; bounds.x -= i; bounds.width += i; }
		if (y < (i = bounds.y)) { i = i - y; bounds.y -= i; bounds.height += i; }
		if (r > (i = bounds.right)) { bounds.width += r - i; }
		if (b > (i = bounds.bottom)) { bounds.height += b - i; }
		invalidate();
	}
	@:extern inline private function grabPoint(x:Float, y:Float):Void {
		grab(x, y, x, y);
	}
	@:extern inline private function grabRange(x:Float, y:Float, r:Float):Void {
		grab(x - r, y - r, x + r, y + r);
	}
	@:extern inline private function grabPen(x:Float, y:Float):Void {
		var r:Float = lineWidth;
		grab(x - r, y - r, x + r, y + r);
	}
	public function invalidate() {
		if (synced) {
			synced = false;
			// should develop a better "do on next frame" mechanism.
			if (!rgPending && displayObject != null && displayObject.stage != null) {
				Lib.schedule(regenerate);
				rgPending = true;
			}
		}
	}
	public function clear():Void {
		var i:Int = 0;
		while (i < len) rec[i++] = GFX_STOP;
		len = 0;
		resetBounds();
		invalidate();
	}
	public function lineStyle(?w:Float, c:Int = 0, a:Float = 1, ?nz:Dynamic, ?lsm:Dynamic):Void {
		rec[len++] = GFX_LINESTYLE;
		rec[len++] = lineWidth = (w != null && w > 0 ? w : 0);
		if (w > 0) rec[len++] = Lib.rgbf(c, a);
	}
	public function beginFill(c:Int = 0, a:Float = 1):Void {
		rec[len++] = GFX_FILL_SOLID;
		rec[len++] = Lib.rgbf(c, a);
	}
	public function beginBitmapFill(bitmap:BitmapData, ?m:flash.geom.Matrix,
	?repeat:Bool, ?smooth:Bool):Void {
		rec[len++] = GFX_FILL_BITMAP;
		rec[len++] = bitmap;
		rec[len++] = repeat != null ? repeat : true;
		if (Lib.bool(rec[len++] = m != null)) {
			rec[len++] = m.a;
			rec[len++] = m.b;
			rec[len++] = m.c;
			rec[len++] = m.d;
			rec[len++] = m.tx;
			rec[len++] = m.ty;
		}
	}
	public function endFill() {
		rec[len++] = GFX_END_FILL;
		invalidate();
	}
	public function moveTo(x:Float, y:Float):Void {
		rec[len++] = GFX_MOVETO;
		rec[len++] = x;
		rec[len++] = y;
		grabPen(x, y);
	}
	public function lineTo(x:Float, y:Float):Void {
		rec[len++] = GFX_LINETO;
		rec[len++] = x;
		rec[len++] = y;
		grabPen(x, y);
	}
	public function curveTo(u:Float, v:Float, x:Float, y:Float):Void {
		rec[len++] = GFX_CURVETO;
		rec[len++] = u;
		rec[len++] = v;
		rec[len++] = x;
		rec[len++] = y;
		grabPen(x, y);
	}
	public function drawRect(x:Float, y:Float, w:Float, h:Float):Void {
		rec[len++] = GFX_RECT;
		rec[len++] = x;
		rec[len++] = y;
		rec[len++] = w;
		rec[len++] = h;
		grab(x, y, x + w, y + h);
	}
	public function drawRoundRect(x:Float, y:Float, w:Float, h:Float, r:Float, ?q:Float):Void {
		rec[len++] = GFX_ROUNDRECT;
		rec[len++] = x;
		rec[len++] = y;
		rec[len++] = w;
		rec[len++] = h;
		rec[len++] = r;
		rec[len++] = q;
		grab(x, y, x + w, y + h);
	}
	public function drawCircle(x:Float, y:Float, r:Float):Void {
		rec[len++] = GFX_CIRCLE;
		rec[len++] = x;
		rec[len++] = y;
		rec[len++] = r;
		grabRange(x, y, r);
	}
	//
	function rgba(c:Int, a:Float):String {
		return "rgba(" + ((c >> 16) & 255) + ", " + ((c >> 8) & 255)
			+ ", " + (c & 255) + ", " + (untyped a.toFixed(4)) + ")";
	}
	// Tile constants:
	@:extern public static inline var TILE_SCALE = 0x0001;
	@:extern public static inline var TILE_ROTATION = 0x0002;
	@:extern public static inline var TILE_RGB = 0x0004;
	@:extern public static inline var TILE_ALPHA = 0x0008;
	@:extern public static inline var TILE_TRANS_2x2 = 0x0010;
	@:extern public static inline var TILE_BLEND_NORMAL = 0x00000000;
	@:extern public static inline var TILE_BLEND_ADD = 0x00010000;
	//
	
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?mtx:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		ctx.save();
		if (mtx != null) ctx.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
		render(cnv, ctx);
		ctx.restore();
	}
	
	private function _closePath(cnv:CanvasElement, ctx:CanvasRenderingContext2D, f:Int, m:Matrix,
	texture:ImageElement):Int {
		ctx.closePath();
		if (Lib.bool(f & GFF_FILL)) {
			if (Lib.bool(f & GFF_PATTERN)) {
				ctx.save();
				ctx.transform(m.a, m.b, m.c, m.d, m.tx, m.ty);
				ctx.fillStyle = ctx.createPattern(texture,
					Lib.bool(f & GFF_TILED) ? "repeat" : "no-repeat");
				ctx.fill();
				ctx.restore();
			} else {
				ctx.fill();
			}
		}
		if (Lib.bool(f & GFF_STROKE)) ctx.stroke();
		ctx.beginPath();
		return f;
	}
	/** Renders Graphics into given canvas-context pair */
	public function render(cnv:CanvasElement, ctx:CanvasRenderingContext2D):Void {
		var f:Int = 0, p:Int = -1, v:Dynamic, m:Matrix = _drawMatrix, n:Int = 0,
		tex:ImageElement = null;
		if (m == null) _drawMatrix = m = new Matrix();
		while (++p < len) switch (v = rec[p]) {
		case GFX_STOP:
			break;
		case GFX_LINESTYLE:
			if (n > 0) f = _closePath(cnv, ctx, f, m, tex);
			ctx.lineWidth = v = rec[++p];
			if (v > 0) {
				f |= GFF_STROKE;
				ctx.strokeStyle = rec[++p];
			} else { // disable stroke if lineWidth <= 0
				f &= ~GFF_STROKE;
				ctx.strokeStyle = null;
			}
		case GFX_FILL_SOLID, GFX_FILL_BITMAP:
			if (n > 0) f = _closePath(cnv, ctx, f, m, tex);
			f |= GFF_FILL;
			if (v == GFX_FILL_BITMAP) {
				tex = rec[++p].handle();
				var r:Bool = rec[++p];
				if (rec[++p]) { // uses matrix
					if (r) f |= GFF_TILED; else f &= ~GFF_TILED; // repeat
					// matrix:
					m.a = rec[++p];
					m.b = rec[++p];
					m.c = rec[++p];
					m.d = rec[++p];
					m.tx = rec[++p];
					m.ty = rec[++p];
					f |= GFF_PATTERN;
				} else {
					ctx.fillStyle = ctx.createPattern(cast tex, r ? "repeat" : "no-repeat");
					f &= ~GFF_PATTERN;
				}
			} else { // solid fill
				ctx.fillStyle = rec[++p];
				f &= ~GFF_PATTERN;
			}
			n = 0;
		case GFX_END_FILL:
			if (n > 0) { f = _closePath(cnv, ctx, f, m, tex); n = 0; }
		case GFX_MOVETO:
			ctx.moveTo(rec[++p], rec[++p]); n++;
		case GFX_LINETO:
			ctx.lineTo(rec[++p], rec[++p]); n++;
		case GFX_CURVETO:
			ctx.quadraticCurveTo(rec[++p], rec[++p], rec[++p], rec[++p]); n++;
		case GFX_RECT:
			var x = rec[++p], y = rec[++p], w = rec[++p], h = rec[++p];
			ctx.rect(x, y, w, h);
			//if ((f & GFF_FILL) != 0) ctx.fillRect(x, y, w, h);
			//if ((f & GFF_STROKE) != 0) ctx.strokeRect(x, y, w, h);
			n++;
		case GFX_CIRCLE:
			ctx.arc(rec[++p], rec[++p], rec[++p], 0, Math.PI * 2, true); n++;
		case GFX_ROUNDRECT:
			var x = rec[++p], y = rec[++p], w = rec[++p], h = rec[++p], u = rec[++p], q = rec[++p];
			if (q == null || ctx.quadraticCurveTo == null) { // single-radius or fallback
				ctx.moveTo(x + u, y + h);
				ctx.arcTo(x + w - u, y + h - u, x + w, y + h - u, u); // bottom right
				ctx.arcTo(x + w, y + u, x + w - u, y, u); // top right
				ctx.arcTo(x + u, y, x, y + u, u); // top left
				ctx.arcTo(x + u, y + h - u, x + u, y + h, u); // bottom left
			} else { // multi-radius. Actually pretty simple.
				ctx.moveTo(x + u, y + h);
				ctx.lineTo(x + w - u, y + h);
				ctx.quadraticCurveTo(x + w, y + h, x + w, y + h - q);
				ctx.lineTo(x + w, y + q);
				ctx.quadraticCurveTo(x + w, y, x + w - u, y);
				ctx.lineTo(x + u, y);
				ctx.quadraticCurveTo(x, y, x, y + q);
				ctx.lineTo(x, y + h - q);
				ctx.quadraticCurveTo(x, y + h, x + u, y + h);
			}
			n++;
		case GFX_TILES:
			var tex:BitmapData = rec[++p],
				d:CanvasElement = tex.handle(), // element to draw
				fx:Int = rec[++p], // flags
				fs:Bool = (fx & TILE_SCALE) != 0, // scaling
				fr:Bool = (fx & TILE_ROTATION) != 0, // rotation
				fc:Bool = (fx & TILE_RGB) != 0, // not actually supported
				fa:Bool = (fx & TILE_ALPHA) != 0, // alpha
				fm:Bool = (fx & TILE_TRANS_2x2) != 0, // Transform (abcd of matrix)
				c:Int = cast (rec[++p] - 1),
				tx:Float, ty:Float, // translateXY
				ox:Float, oy:Float, // originXY
				rx:Float, ry:Float, rw:Float, rh:Float; // source rectangle
			//
			ctx.save();
			ctx.globalCompositeOperation = ((fx & TILE_BLEND_ADD) != 0) ? "lighter" : "source-over";
			while (p < c) {
				tx = rec[++p]; ty = rec[++p];
				ox = rec[++p]; oy = rec[++p];
				rx = rec[++p]; ry = rec[++p];
				rw = rec[++p]; rh = rec[++p];
				ctx.save();
				// the extra data:
				if (fm) {
					ctx.transform(rec[++p], rec[++p], rec[++p], rec[++p], tx, ty);
				} else {
					ctx.translate(tx, ty);
					if (fs) ctx.scale(v = rec[++p], v);
					if (fr) ctx.rotate(rec[++p]);
				}
				if (fc) p += 3;
				if (fa) ctx.globalAlpha = rec[++p];
				//
				ctx.drawImage(d, rx, ry, rw, rh, -ox, -oy, rw, rh);
				ctx.restore();
			}
			ctx.restore();
		default:
			Lib.trace(Std.string(v));
			break;
		}
		if (n > 0) f = _closePath(cnv, ctx, f, m, tex);
	}
}
#end
