package flash.display;
import js.html.CanvasGradient;
import flash.geom.Point;
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
	@:extern private static inline var GFX_FILL_GRADIENT = 4;
	@:extern private static inline var GFX_END_FILL = 9;
	@:extern private static inline var GFX_MOVETO = 10;
	@:extern private static inline var GFX_LINETO = 11;
	@:extern private static inline var GFX_CURVETO = 12;
	@:extern private static inline var GFX_RECT = 13;
	@:extern private static inline var GFX_CIRCLE = 14;
	@:extern private static inline var GFX_ROUNDRECT = 15;
	@:extern private static inline var GFX_TILES = 16; // also used in openfl.display.Tilesheet.drawTiles
	@:extern private static inline var GFX_ELLIPSE = 17;
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
	// integer list
	public var irec:Array<Int>;
	public var ilen:Int;
	@:extern public inline function addInt(v:Int):Int return irec[ilen++] = v;
	// float list
	public var frec:Array<Float>;
	public var flen:Int;
	@:extern public inline function addFloat(v:Float):Float return frec[flen++] = v;
	// object list
	public var arec:Array<Dynamic>;
	public var alen:Int;
	@:extern public inline function addObject(v:Dynamic):Dynamic return arec[alen++] = v;
	//
	private var synced:Bool = true;
	/** Whether a regeneration is already scheduled and no change is needed*/
	private var rgPending:Bool = false;
	public var offsetX:Int;
	public var offsetY:Int;
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
		irec = [];
		frec = [];
		arec = [];
		lineWidth = ilen = flen = alen = 0;
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
		if (offsetX != bx || offsetY != by) {
			s.left = (offsetX = bx) + "px";
			s.top = (offsetY = by) + "px";
		}
		if (bw != o.width || bh != o.height) {
			o.width = bw;
			o.height = bh;
		} else q.clearRect(0, 0, bw, bh);
		//
		q.save();
		q.translate( -bx, -by);
		render(o, q);
		q.restore();
	}
	private function regenerateTask():Void {
		// avoid rendering the same thing twice if canvas was already drawn by request:
		if (rgPending) regenerate();
	}
	private function requestRegeneration():Void {
		Lib.schedule(regenerateTask);
		rgPending = true;
	}
	private function set_displayObject(v:DisplayObject):DisplayObject {
		if (displayObject != v) {
			displayObject = v;
			if (!synced) requestRegeneration();
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
		r += lineWidth / 2;
		grab(x - r, y - r, x + r, y + r);
	}
	@:extern inline private function grabPen(x:Float, y:Float):Void {
		var r:Float = lineWidth / 2;
		grab(x - r, y - r, x + r, y + r);
	}
	@:extern inline private function grabRect(x:Float, y:Float, w:Float, h:Float):Void {
		var r:Float = lineWidth / 2;
		grab(x - r, y - r, x + w + r, y + h + r);
	}
	public function invalidate() {
		if (synced) {
			synced = false;
			// should develop a better "do on next frame" mechanism.
			if (!rgPending && displayObject != null && displayObject.stage != null) {
				requestRegeneration();
			}
		}
	}
	public function clear():Void {
		var i:Int = 0;
		while (i < alen) arec[i++] = null;
		lineWidth = ilen = flen = alen = 0;
		resetBounds();
		invalidate();
	}
	/**
	 * @param	?w	Width (in pixels)
	 * @param	?c	Color (24-bit)
	 * @param	?a	Alpha (0..1)
	 * @param	?ph	Pixel hinting (not actually supported)
	 * @param	?sm	Scale mode (not supported)
	 * @param	?cs	Caps style
	 * @param	?js	Joints style
	 * @param	?ml	Miter limit (default of 3)
	 */
	public function lineStyle(?w:Float, ?c:Int, ?a:Float, ?ph:Bool, ?sm:Dynamic, ?cs:CapsStyle,
	?js:JointStyle, ?ml:Float):Void {
		addInt(GFX_LINESTYLE);
		addFloat(lineWidth = w > 0 ? w : 0);
		if (w > 0) {
			addObject(Lib.rgbf(Lib.nz(c, 0), Lib.nz(a, 1)));
			addInt(cs == CapsStyle.NONE ? 2 : cs == CapsStyle.SQUARE ? 1 : 0);
			addInt(js == JointStyle.BEVEL ? 2 : js == JointStyle.MITER ? 1 : 0);
		}
	}
	/**
	 * @param	c	Color (24-bit)
	 * @param	a	Alpha (0..1)
	 */
	public function beginFill(?c:Int, ?a:Float):Void {
		addInt(GFX_FILL_SOLID);
		addObject(Lib.rgbf(Lib.nz(c, 0), Lib.nz(a, 1)));
	}
	public function beginBitmapFill(bitmap:BitmapData, ?m:flash.geom.Matrix,
	?repeat:Bool, ?smooth:Bool):Void {
		addInt(GFX_FILL_BITMAP);
		addObject(bitmap);
		addInt(repeat != false ? 1 : 0);
		var i = m != null ? 1 : 0;
		addInt(i);
		if (Lib.bool(i)) {
			var r = frec, l = flen;
			r[l++] = m.a; r[l++] = m.b;
			r[l++] = m.c; r[l++] = m.d;
			r[l++] = m.tx; r[l++] = m.ty;
			flen = l;
		}
	}
	public function beginGradientFill(type:GradientType, colors:Array<UInt>,
	alphas:Array<Dynamic>, ratios:Array<Dynamic>, ?m:Matrix,
	?spreadMethod:SpreadMethod, ?interpolationMethod:InterpolationMethod,
	fpr:Float = 0):Void {
		var g:CanvasGradient, i:Int = -1, n:Int = colors.length;
		addInt(GFX_FILL_GRADIENT);
		if (type == GradientType.LINEAR) {
			g = context.createLinearGradient(
				-819.2 * m.a + m.tx,
				-819.2 * m.b + m.ty,
				819.2 * m.a + m.tx,
				819.2 * m.b + m.ty);
		} else { // no ellipses yet
			fpr *= 819.2;
			g = context.createRadialGradient(
				fpr * m.a + m.tx,
				fpr * m.b + m.ty,
				0, 
				819.2 * m.c + m.tx,
				fpr * m.b + m.ty,
				819.2 * m.d + m.ty);
		}
		while (++i < n) {
			g.addColorStop(ratios[i] / 255, Lib.rgbf(colors[i], alphas[i]));
		}
		addObject(g);
	}
	public function endFill() {
		addInt(GFX_END_FILL);
		invalidate();
	}
	public function moveTo(x:Float, y:Float):Void {
		addInt(GFX_MOVETO);
		addFloat(x);
		addFloat(y);
		grabPen(x, y);
	}
	public function lineTo(x:Float, y:Float):Void {
		addInt(GFX_LINETO);
		addFloat(x);
		addFloat(y);
		grabPen(x, y);
	}
	public function curveTo(u:Float, v:Float, x:Float, y:Float):Void {
		addInt(GFX_CURVETO);
		var r = frec, l = flen;
		r[l++] = u; r[l++] = v;
		r[l++] = x; r[l++] = y;
		flen = l;
		grabPen(x, y);
	}
	public function drawRect(x:Float, y:Float, w:Float, h:Float):Void {
		addInt(GFX_RECT);
		var r = frec, l = flen;
		r[l++] = x; r[l++] = y;
		r[l++] = w; r[l++] = h;
		flen = l;
		grabRect(x, y, w, h);
	}
	public function drawRoundRect(x:Float, y:Float, w:Float, h:Float, p:Float, ?q:Float):Void {
		addInt(GFX_ROUNDRECT);
		var r = frec, l = flen;
		r[l++] = x; r[l++] = y;
		r[l++] = w; r[l++] = h;
		r[l++] = p; r[l++] = q;
		flen = l;
		grabRect(x, y, w, h);
	}
	public function drawCircle(x:Float, y:Float, q:Float):Void {
		addInt(GFX_CIRCLE);
		var r = frec, l = flen;
		r[l++] = x; r[l++] = y;
		r[l++] = q;
		flen = l;
		grabRange(x, y, q);
	}
	public function drawEllipse(x:Float, y:Float, w:Float, h:Float):Void {
		addInt(GFX_ELLIPSE);
		var r = frec, l = flen;
		r[l++] = x; r[l++] = y;
		r[l++] = w; r[l++] = h;
		flen = l;
		grab(x, y, x + w, y + h);
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
	
	public function drawToSurface(cnv:CanvasElement, ctx:CanvasRenderingContext2D,
	?mtx:Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:BlendMode,
	?clipRect:Rectangle, ?smoothing:Bool):Void {
		ctx.save();
		if (mtx != null) ctx.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
		render(cnv, ctx);
		ctx.restore();
	}
	
	/**
	 * Returns whether drawn image is non-transparent (alpha > 0) at given point.
	 * @param	x	Point X
	 * @param	y	Point Y
	 */
	public function hitTestLocal(x:Float, y:Float, p:Bool):Bool {
		if (bounds.contains(x, y)) {
			if (p) {
				if (!synced) regenerate();
				try {
					return context.getImageData(x - offsetX, y - offsetY, 1, 1).data[3] != 0;
				} catch (_:Dynamic) {
					// most likely canvas is tainted. assume a rectangular check
				}
			}
			return true;
		}
		return false;
	}
	
	/** Finishes the path and applies fill/stroke if needed. */
	private function _closePath(cnv:CanvasElement, ctx:CanvasRenderingContext2D, f:Int, m:Matrix,
	texture:ImageElement):Int {
		if (Lib.bool(f & GFF_FILL)) {
			ctx.closePath();
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
		var f:Int = 0x0,
			p:Int = -1,
			m:Matrix = _drawMatrix,
			v:Dynamic, // object
			i:Int, // integer
			d:Float, // float
			n:Int = 0, // number of operations in current path
			tex:ImageElement = null,
			ir:Array<Int> = irec, ip:Int = -1, il:Int = ir.length - 1,
			ar:Array<Dynamic> = arec, ap:Int = -1,
			nr:Array<Float> = frec, np:Int = -1;
		// helpers:
		inline function nextInt():Int return ir[++ip];
		inline function nextFloat():Float return nr[++np];
		inline function nextObject():Dynamic return ar[++ap];
		//
		if (m == null) _drawMatrix = m = new Matrix();
		while (ip < il) switch (i = nextInt()) {
		//case GFX_STOP: break;// ()
		case GFX_LINESTYLE: // (width:Float, style:String[, cap:Int, join:Int])
			if (n > 0) f = _closePath(cnv, ctx, f, m, tex);
			ctx.lineWidth = d = nextFloat();
			if (d > 0) {
				f |= GFF_STROKE;
				ctx.strokeStyle = nextObject();
				ctx.lineCap = (i = nextInt()) == 2 ? "butt" : i == 1 ? "square" : "round";
				ctx.lineJoin = (i = nextInt()) == 2 ? "bevel" : i == 1 ? "miter" : "round";
			} else { // disable stroke if lineWidth <= 0
				f &= ~GFF_STROKE;
				ctx.strokeStyle = null;
			}
		case GFX_FILL_SOLID, GFX_FILL_BITMAP, GFX_FILL_GRADIENT:
			if (n > 0) f = _closePath(cnv, ctx, f, m, tex);
			f |= GFF_FILL;
			if (i == GFX_FILL_BITMAP) {
				tex = nextObject().handle();
				i = nextInt();
				if (nextInt() != 0) { // uses matrix
					if (i != 0) f |= GFF_TILED; else f &= ~GFF_TILED; // repeat
					// matrix:
					m.a = nextFloat(); m.b = nextFloat();
					m.c = nextFloat(); m.d = nextFloat();
					m.tx = nextFloat(); m.ty = nextFloat();
					f |= GFF_PATTERN;
				} else {
					ctx.fillStyle = ctx.createPattern(tex, i != 0 ? "repeat" : "no-repeat");
					f &= ~GFF_PATTERN;
				}
			} else { // solid/gradient fill
				ctx.fillStyle = nextObject();
				f &= ~GFF_PATTERN;
			}
			n = 0;
		case GFX_END_FILL:
			if (n > 0) { f = _closePath(cnv, ctx, f, m, tex); n = 0; }
			f &= ~GFF_FILL;
		case GFX_MOVETO:
			ctx.moveTo(nextFloat(), nextFloat()); n++;
		case GFX_LINETO:
			ctx.lineTo(nextFloat(), nextFloat()); n++;
		case GFX_CURVETO:
			ctx.quadraticCurveTo(nextFloat(), nextFloat(), nextFloat(), nextFloat()); n++;
		case GFX_RECT:
			ctx.rect(nextFloat(), nextFloat(), nextFloat(), nextFloat());
			n++;
		case GFX_CIRCLE:
			var x = nextFloat(), y = nextFloat(), r = nextFloat();
			if (r < 0) r = -r;
			ctx.moveTo(x + r, y);
			if (r != 0) ctx.arc(x, y, r, 0, Math.PI * 2, true);
			n++;
		case GFX_ELLIPSE:
			var x = nextFloat(), y = nextFloat(), w = nextFloat(), h = nextFloat(),
				x1 = x + w / 2, y1 = y + h / 2, x2 = x + w, y2 = y + h,
				m = 0.275892, xm = w * m, ym = h * m;
			ctx.moveTo(x1, y);
			ctx.bezierCurveTo(x1 + xm, y, x2, y1 - ym, x2, y1);
			ctx.bezierCurveTo(x2, y1 + ym, x1 + xm, y2, x1, y2);
			ctx.bezierCurveTo(x1 - xm, y2, x, y1 + ym, x, y1);
			ctx.bezierCurveTo(x, y1 - ym, x1 - xm, y, x1, y);
			n++;
		case GFX_ROUNDRECT:
			var x = nextFloat(), y = nextFloat(),
				w = nextFloat(), h = nextFloat(),
				u = nextFloat(), q = nextFloat();
			if (q == null) { // single-radius or fallback
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
			var tex:BitmapData = nextObject(),
				d:CanvasElement = tex.handle(), // element to draw
				fx:Int = nextInt(), // flags
				fs:Bool = (fx & TILE_SCALE) != 0, // scaling
				fr:Bool = (fx & TILE_ROTATION) != 0, // rotation
				fc:Bool = (fx & TILE_RGB) != 0, // not actually supported
				fa:Bool = (fx & TILE_ALPHA) != 0, // alpha
				fm:Bool = (fx & TILE_TRANS_2x2) != 0, // Transform (abcd of matrix)
				c:Int = nextInt(),
				tx:Float, ty:Float, // translateXY
				ox:Float, oy:Float, // originXY
				rx:Float, ry:Float, rw:Float, rh:Float; // source rectangle
			//
			ctx.save();
			ctx.globalCompositeOperation = ((fx & TILE_BLEND_ADD) != 0) ? "lighter" : "source-over";
			while (--c >= 0) {
				tx = nextFloat(); ty = nextFloat();
				ox = nextFloat(); oy = nextFloat();
				rx = nextFloat(); ry = nextFloat();
				rw = nextFloat(); rh = nextFloat();
				ctx.save();
				// the extra data:
				if (fm) {
					ctx.transform(nextFloat(), nextFloat(), nextFloat(), nextFloat(), tx, ty);
				} else {
					ctx.translate(tx, ty);
					if (fs) ctx.scale(v = nextFloat(), v);
					if (fr) ctx.rotate(nextFloat());
				}
				if (fc) p += 3;
				if (fa) ctx.globalAlpha = nextFloat();
				//
				ctx.drawImage(d, rx, ry, rw, rh, -ox, -oy, rw, rh);
				ctx.restore();
			}
			ctx.restore();
		default:
			Lib.error(4000 + i, 'Unknown operation $i');
		}
		if (n > 0) f = _closePath(cnv, ctx, f, m, tex);
	}
}
#end
