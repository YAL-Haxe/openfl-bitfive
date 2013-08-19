package flash.display;
#if js
import flash.geom.Rectangle;
import flash.Lib;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
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
	//
	@:extern private static inline var GFF_FILL = 1;
	@:extern private static inline var GFF_STROKE = 2;
	//
	public var component:CanvasElement;
	public var context:CanvasRenderingContext2D;
	public var displayObject(default, set):DisplayObject;
	/** Determines current content bounds. Could use for hitTestPoint? */
	public var bounds(default, null):Rectangle;
	/** Only left here for correct bounds expansion */
	private var lineWidth:Float;
	/** Sequence of drawing commands. Array is cleaned up but never trimmed. */
	private var rec(default, null):Array<Dynamic>;
	private var len:Int;
	private var synced:Bool = true;
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
		var o = component, s = component.style, q = context;
		// maybe generate higher-resolution graphic if image is scaled?
		// on one hand, higher-quality graphics, but on other hand, would
		// have to override component scaling... somehow?
		synced = true;
		if (bounds.width <= 0 || bounds.height <= 0) {
			component.width = component.height = 1;
			s.top = s.left = "0";
			return;
		}
		// take a slightly larger area for case of excessive anti-aliasing:
		s.left = (bounds.x - 2) + "px";
		s.top = (bounds.y - 2) + "px";
		o.width = Math.ceil(bounds.width + 4);
		o.height = Math.ceil(bounds.height + 4);
		//
		q.save();
		q.translate( -bounds.x + 2, -bounds.y + 2);
		render(o, q);
		q.restore();
	}
	private function set_displayObject(v:DisplayObject):DisplayObject {
		if (displayObject != v) {
			displayObject = v;
			if (!synced) untyped setTimeout(regenerate, 0);
		}
		return v;
	}
	private function resetBounds():Void {
		bounds.left = 0x7fffffff;
		bounds.right = -0x80000000;
		bounds.top = 0x7fffffff;
		bounds.bottom = -0x80000000;
		invalidate();
	}
	/**
	 * Ensures that bounds include given rectangle area.
	 * @param	x	Left/X coordinate of rectangle
	 * @param	y	Top/Y coordinate of rectangle
	 * @param	r	Right coordinate of rectangle
	 * @param	b	Bottom coordinate of rectangle
	 */
	private function grab(x:Float, y:Float, r:Float, b:Float):Void {
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
	private function invalidate() {
		if (synced) {
			synced = false;
			// should develop a better "do on next frame" mechanism.
			if (displayObject != null) untyped setTimeout(regenerate, 0);
		}
	}
	public function clear():Void {
		var i:Int = 0;
		while (i < len) rec[i++] = GFX_STOP;
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
	public function beginBitmapFill(bitmap:BitmapData, ?matrix:flash.geom.Matrix,
	?repeat:Bool, ?smooth:Bool):Void {
		rec[len++] = GFX_FILL_BITMAP;
		rec[len++] = bitmap;
		rec[len++] = repeat != false ? "repeat" : "no-repeat";
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
		grab(x, y, w, h);
	}
	public function drawRoundRect(x:Float, y:Float, w:Float, h:Float, r:Float, ?q:Float):Void {
		rec[len++] = GFX_ROUNDRECT;
		rec[len++] = x;
		rec[len++] = y;
		rec[len++] = w;
		rec[len++] = h;
		rec[len++] = r;
		rec[len++] = q;
		grab(x, y, w, h);
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
	// TILES TILES TILES
	@:extern public static inline var TILE_SCALE = 0x0001;
	@:extern public static inline var TILE_ROTATION = 0x0002;
	@:extern public static inline var TILE_RGB = 0x0004;
	@:extern public static inline var TILE_ALPHA = 0x0008;
	@:extern public static inline var TILE_TRANS_2x2 = 0x0010;
	@:extern public static inline var TILE_BLEND_NORMAL = 0x00000000;
	@:extern public static inline var TILE_BLEND_ADD = 0x00010000;
	//
	public function drawTiles(sheet:openfl.display.Tilesheet,
	tileData:Array<Float>, smooth:Bool = false, flags:Int = 0):Void {
		Lib.trace("drawTiles");
	}
	
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?mtx:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		render(cnv, ctx);
	}
	/** Renders Graphics into given canvas-context pair */
	public function render(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D):Void {
		var f:Int = 0, p:Int = -1, v:Dynamic;
		//Lib.trace(rec);
		while (++p < len) switch (v = rec[p]) {
		case GFX_STOP:
			break;
		case GFX_LINESTYLE:
			ctx.lineWidth = v = rec[++p];
			if (v > 0) {
				f |= GFF_STROKE;
				ctx.strokeStyle = rec[++p];
			} else {
				f &= ~GFF_STROKE;
				ctx.strokeStyle = null;
			}
		case GFX_FILL_SOLID, GFX_FILL_BITMAP:
			if ((f & GFF_FILL) != 0) {
				ctx.closePath();
				if ((f & GFF_STROKE) != 0) ctx.stroke();
				ctx.fill();
			} else f |= GFF_FILL;
			ctx.fillStyle = v == GFX_FILL_BITMAP
				? ctx.createPattern(rec[++p].handle(), rec[++p])
				: rec[++p];
			ctx.beginPath();
		case GFX_END_FILL:
			ctx.closePath();
			if ((f & GFF_FILL) != 0) {
				ctx.fill();
				f &= ~GFF_FILL;
			}
			if ((f & GFF_STROKE) != 0) ctx.stroke();
		case GFX_MOVETO:
			ctx.moveTo(rec[++p], rec[++p]);
		case GFX_LINETO:
			ctx.lineTo(rec[++p], rec[++p]);
		case GFX_CURVETO:
			ctx.quadraticCurveTo(rec[++p], rec[++p], rec[++p], rec[++p]);
		case GFX_RECT:
			ctx.rect(rec[++p], rec[++p], rec[++p], rec[++p]);
		case GFX_CIRCLE:
			ctx.arc(rec[++p], rec[++p], rec[++p], 0, Math.PI * 2, true);
		case GFX_ROUNDRECT:
			var x = rec[++p], y = rec[++p], w = rec[++p], h = rec[++p], u = rec[++p], v = rec[++p];
			if (v == null || ctx.quadraticCurveTo == null) {
				ctx.moveTo(x + u, y + h);
				ctx.arcTo(x + w - u, y + h - u, x + w, y + h - u, u); // bottom right
				ctx.arcTo(x + w, y + u, x + w - u, y, u); // top right
				ctx.arcTo(x + u, y, x, y + u, u); // top left
				ctx.arcTo(x + u, y + h - u, x + u, y + h, u); // bottom left
			} else {
				ctx.moveTo(x + u, y + h);
				ctx.lineTo(x + w - u, y + h);
				ctx.quadraticCurveTo(x + w, y + h, x + w, y + h - v);
				ctx.lineTo(x + w, y + v);
				ctx.quadraticCurveTo(x + w, y, x + w - u, y);
				ctx.lineTo(x + u, y);
				ctx.quadraticCurveTo(x, y, x, y + v);
				ctx.lineTo(x, y + h - v);
				ctx.quadraticCurveTo(x, y + h, x + u, y + h);
			}
		default:
			Lib.trace(Std.string(v));
			break;
		}
		if ((f & GFF_FILL) != 0) {
			ctx.closePath();
			ctx.fill();
		}
		//if ((f & GFF_STROKE) != 0) ctx.stroke();
	}
}
#end