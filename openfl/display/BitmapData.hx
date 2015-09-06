package openfl.display;
#if js
import js.html.DataView;
import js.html.ImageData;
import js.html.ImageElement;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Uint8ClampedArray;
import openfl.events.Event;
import openfl.errors.IOError;
import openfl.utils.ByteArray;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.geom.Point;

typedef LoadData = {
	var image:ImageElement;
	var texture:CanvasElement;
	var inLoader:Null<LoaderInfo>;
	var bitmapData:BitmapData;
}

/**
 * Status: Almost there!
 * Most functions work correctly.
 * Only alpha channel of ColorTransform's is supported.
 * Specific BitmapData can only be bound to a one Bitmap at time.
 */
@:autoBuild(openfl.Assets.embedBitmap())
class BitmapData implements IBitmapDrawable {
	/** The associated HTML5 <canvas> element */
	public var component:CanvasElement;
	/** The rendering context of the associated <canvas> element */
	public var context:CanvasRenderingContext2D;
	//
	public var width(get, null):Int;
	public var height(get, null):Int;
	public var transparent(get, null):Bool;
	//{
	public var rect(get, null):Rectangle;
	inline function get_rect() return __rect.clone();
	private var __rect:Rectangle;
	//}
	private var __imageData:ImageData;
	/// A single-pixel ImageData for setPixel/setPixel32
	private var __pixelData:ImageData;
	
	//{ __sync flags:
	/// Indicates that Canvas represents the current state
	@:extern private static inline var SY_CANVAS = 0x1;
	/// Indicates that ImageData represents the current state
	@:extern private static inline var SY_IMDATA = 0x2;
	/// Indicates that the state has changed
	@:extern private static inline var SY_CHANGE = 0x4;
	/// A bit mask for checking for the current type (Canvas/ImageData)
	@:extern private static inline var SM_TYPE = 0x3;
	//}
	private var __sync:Int;
	/** Indicates if bitmap's background is transparent */
	private var __transparent:Bool;
	/** Incremented on retrieving canvas. Not actually used anywhere. */
	private var __revision:Int;
	/**
	 * Creates a new BitmapData
	 * @param	w	Width
	 * @param	h	Height
	 * @param	?t	Transparent background
	 * @param	?c	Fill color
	 */
	public function new(w:Int, h:Int, ?t:Bool = true, ?c:Int) {
		__sync = 1;
		__transparent = t;
		__revision = 0;
		__rect = new Rectangle(0, 0, w, h);
		// create canvas:
		component = openfl.bitfive.NodeTools.createCanvasElement();
		#if debug
			component.setAttribute("node", Type.getClassName(Type.getClass(this)));
		#end
		component.width = w;
		component.height = h;
		context = component.getContext('2d');
		setSmoothing(context, true);
		__pixelData = context.createImageData(1, 1);
		// fill with white by default:
		if (c == null) c = 0xFFFFFFFF;
		// make fill opaque if not transparent:
		if (!t) c |= 0xFF000000;
		// if context must be filled:
		if ((c & 0xFF000000) != 0) {
			fillRect(__rect, c);
		}
	}
	public function fillRect(area:Rectangle, color:Int):Void {
		// common useless operation check:
		if (area == null || area.width <= 0 || area.height <= 0) return;
		// trick for clearing canvas fast:
		if (area.equals(__rect) && __transparent && ((color & 0xFF000000) == 0)) {
			component.width = component.width;
			return;
		}
		if (!__transparent) {
			// rectangles are opaque on non-transparent bitmaps
			color |= 0xFF000000;
		} else if ((color & 0xFF000000) != 0xFF000000) {
			// clear what was below the rectangle in transparent ones
			context.clearRect(area.x, area.y, area.width, area.height);
		}
		// now actually just draw a rectangle:
		if ((color & 0xFF000000) != 0) {
			context.fillStyle = makeColor(color);
			context.fillRect(area.x, area.y, area.width, area.height);
		}
		__sync |= SY_CANVAS | SY_CHANGE;
	}
	//
	public function clone():BitmapData {
		syncCanvas();
		var r:BitmapData = new BitmapData(width, height, __transparent, 0x0);
		r.context.drawImage(component, 0, 0);
		r.__sync |= SY_CANVAS | SY_CHANGE;
		return r;
	}
	public function dispose():Void {
		component.width = component.height = 1;
		__imageData = null;
		__sync = SY_CANVAS | SY_CHANGE;
	}
	public function handle():CanvasElement {
		syncCanvas();
		if ((__sync & SY_CHANGE) != 0) {
			__revision++;
			__sync &= ~SY_CHANGE;
		}
		return component;
	}
	//
	@:extern private inline function get_width():Int return component.width;
	@:extern private inline function get_height():Int return component.height;
	@:extern private inline function get_transparent():Bool return __transparent;
	//
	public function drawToSurface(cnv:CanvasElement, ctx:CanvasRenderingContext2D,
	?matrix:Matrix, ?ctr:ColorTransform, ?blendMode:BlendMode,
	?clipRect:Rectangle, ?smoothing:Bool):Void {
		// todo: add cliprect handling
		ctx.save();
		if (smoothing != null && ctx.imageSmoothingEnabled != smoothing) setSmoothing(ctx, smoothing);
		if (matrix != null) {
			if (matrix.a == 1 && matrix.b == 0 && matrix.c == 0 && matrix.d == 1) 
				ctx.translate(matrix.tx, matrix.ty);
			else
				ctx.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
		}

		ctx.drawImage(handle(), 0, 0);
		ctx.restore();
	}
	//
	public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point,
			?alphaBitmapData:BitmapData, ?alphaPoint:Point, mergeAlpha:Bool = false):Void {
		syncCanvas();
		// errors:
		if (alphaBitmapData != null) throw 'alphaBitmapData is not supported yet.';
		// find what we are going to draw:
		var bit:CanvasElement = sourceBitmapData.handle(), bw, bh,
			tw = width, th = height;
		// pointless operation handling:
		if (bit == null || (bw = bit.width) <= 0 || (bh = bit.height) <= 0) return;
		var dx = untyped ~~destPoint.x, dy = untyped ~~destPoint.y, sx, sy, sw, sh;
		// apply cliprect, if needed:
		if (sourceRect != null) {
			sx = sourceRect.x;
			sy = sourceRect.y;
			sw = sourceRect.width;
			sh = sourceRect.height;
			if (sx < 0) { sw += sx; sx = 0; }
			if (sy < 0) { sh += sy; sy = 0; }
			if (sx + sw > bw) sw = bw - sx;
			if (sy + sh > bh) sh = bh - sy;
		} else {
			sx = sy = 0; sw = bw; sh = bh;
		}
		// drawing outside bounds is useless.
		if (dx < 0) { sw += dx; sx -= dx; dx = 0; }
		if (dy < 0) { sh += dy; sy -= dy; dy = 0; }
		if (dx + sw > tw) sw = tw - dx;
		if (dy + sh > th) sh = th - dy;
		// drawing nothing may crash some browsers:
		if (sw <= 0 || sh <= 0) return;
		// clear area before drawing if needed:
		if (__transparent && !mergeAlpha) {
			context.clearRect(dx, dy, sw, sh);
		}
		// draw:
		context.drawImage(bit, sx, sy, sw, sh, dx, dy, sw, sh);
		//
		__sync |= SY_CANVAS | SY_CHANGE;
	}
	public function draw(source:IBitmapDrawable, ?matrix:Matrix,
			?colorTransform:ColorTransform, ?blendMode:Dynamic,
			?clipRect:Rectangle, ?smoothing):Void {
		syncCanvas();
		var a:Float = 0;
		context.save();
		if (colorTransform != null) {
			// currently only alpha channel of colorTransforms is supported.
			// use .colorTransform to "bake" colored versions.
			a = colorTransform.alphaMultiplier;
			colorTransform.alphaMultiplier = 1;
			context.globalAlpha *= a;
		}
		if (clipRect != null) {
			context.beginPath();
			context.rect(clipRect.x, clipRect.y, clipRect.width, clipRect.height);
			context.clip();
			context.beginPath();
		}
		if (smoothing != null) setSmoothing(context, smoothing);
		source.drawToSurface(handle(), context, matrix, colorTransform, blendMode, clipRect, null);
		context.restore();
		if (colorTransform != null) {
			colorTransform.alphaMultiplier = a;
		}
		__sync |= SY_CANVAS | SY_CHANGE;
	}
	public static function setSmoothing(o:CanvasRenderingContext2D, v:Bool):Void {
		untyped o.imageSmoothingEnabled = 
		o.oImageSmoothingEnabled = 
		o.msImageSmoothingEnabled = 
		o.webkitImageSmoothingEnabled =
		o.mozImageSmoothingEnabled = v;
	}
	/// Pixel functions:
	public function lock():Void {
		syncData();
	}
	public function unlock():Void {
		syncCanvas();
	}
	public function hitTestLocal(x:Float, y:Float):Bool {
		if (x >= 0 && y >= 0 && x < width && y < height) {
			try {
				return context.getImageData(x, y, 1, 1).data[3] != 0;
			} catch (_:Dynamic) {
				return true;
			}
		}
		return false;
	}
	public function getPixel(x:Int, y:Int):Int {
		if (x < 0 || y < 0 || x >= width || y >= height) return 0;
		if (!hasImData()) {
			var d = context.getImageData(x, y, 1, 1).data;
			return (d[0] << 16) | (d[1] << 8) | d[2];
		} else {
			var o = (y * width + x) << 2;
			return (__imageData.data[o] << 16) | (__imageData.data[o + 1] << 8) | __imageData.data[o + 2];
		}
	}
	public function getPixel32(x:Int, y:Int):Int {
		if (x < 0 || y < 0 || x >= width || y >= height) return 0;
		if (!hasImData()) {
			var d = context.getImageData(x, y, 1, 1).data;
			return (__transparent ? d[3] << 24 : 0xFF000000) | (d[0] << 16) | (d[1] << 8) | d[2];
		} else {
			var o = (y * width + x) << 2;
			return (__transparent ? __imageData.data[o + 3] << 24 : 0xFF000000)
			| (__imageData.data[o] << 16)
			| (__imageData.data[o + 1] << 8)
			| __imageData.data[o + 2];
		}
	}
	public function setPixel(x:Int, y:Int, color:Int):Void {
		if (x < 0 || y < 0 || x >= width || y >= height) return;
		if (!hasImData()) {
			__pixelData.data[0] = (color >>> 16) & 0xFF;
			__pixelData.data[1] = (color >>> 8) & 0xFF;
			__pixelData.data[2] = color & 0xFF;
			__pixelData.data[3] = 0xFF;
			context.putImageData(__pixelData, x, y);
			__sync |= SY_CHANGE | SY_CANVAS;
		} else {
			var o = (y * width + x) << 2;
			__imageData.data[o] = (color >>> 16) & 0xFF;
			__imageData.data[o+1] = (color >>> 8) & 0xFF;
			__imageData.data[o+2] = color & 0xFF;
			__imageData.data[o+3] = 0xFF;
			__sync |= SY_CHANGE | SY_IMDATA;
		}
	}
	public function setPixel32(x:Int, y:Int, color:Int):Void {
		if (x < 0 || y < 0 || x >= width || y >= height) return;
		if (!hasImData()) {
			__pixelData.data[0] = (color >>> 16) & 0xFF;
			__pixelData.data[1] = (color >>> 8) & 0xFF;
			__pixelData.data[2] = color & 0xFF;
			__pixelData.data[3] = (color >>> 24) & 0xFF;
			context.putImageData(__pixelData, x, y);
			__sync |= SY_CHANGE | SY_CANVAS;
		} else {
			var o = (y * width + x) << 2;
			__imageData.data[o] = (color >>> 16) & 0xFF;
			__imageData.data[o+1] = (color >>> 8) & 0xFF;
			__imageData.data[o+2] = color & 0xFF;
			__imageData.data[o+3] = (color >>> 24) & 0xFF;
			__sync |= SY_CHANGE | SY_IMDATA;
		}
	}
	public function getPixels(q:Rectangle):ByteArray {
		var d:ImageData, v:DataView, r:ByteArray = new ByteArray(),
			u:Uint8ClampedArray,
			qx:Int = Std.int(q.x), qy:Int = Std.int(q.y),
			qw:Int = Std.int(q.width), qh:Int = Std.int(q.height),
			i:Int = 0, j:Int, l:Int = qw * qh * 4;
		r.length = l;
		v = r.data;
		if (!hasImData()) {
			d = context.getImageData(qx, qy, qw, qh);
			u = d.data;
			while (i < l) {
				r.writeUnsignedInt((u[i++] << 16) | (u[i++] << 8) | u[i++] | (u[i++] << 24));
			}
		} else {
			u = __imageData.data;
			if (qx == 0 && qy == 0 && qw == width && qh == height) {
				while (i < l) {
					r.writeUnsignedInt((u[i++] << 16) | (u[i++] << 8) | u[i++] | (u[i++] << 24));
				}
			} else {
				while (qh-- > 0) {
					i = (qx + (qy++) * (j = qw)) * 4;
					while (j-- > 0) {
						r.writeUnsignedInt((u[i++] << 16) | (u[i++] << 8) | u[i++] | (u[i++] << 24));
					}
				}
			}
		}
		return r;
	}
	public function setPixels(q:Rectangle, r:ByteArray):Void {
		var qx:Int = Std.int(q.x), qy:Int = Std.int(q.y),
			qw:Int = Std.int(q.width), qh:Int = Std.int(q.height),
			i:Int = 0, j:Int, l:Int = qw * qh * 4, p:Int, w:Int = width,
			d:ImageData, u:Uint8ClampedArray;
		if (hasCanvas()) {
			d = context.createImageData(qw, qh);
			u = d.data;
			while (i < l) {
				p = r.readUnsignedInt();
				u[i + 0] = (p >> 16) & 255;
				u[i + 1] = (p >> 8) & 255;
				u[i + 2] = p & 255;
				u[i + 3] = (p >>> 24) & 255;
				i += 4;
			}
			context.putImageData(d, qx, qy);
		} else {
			u = __imageData.data;
			while (qh-- > 0) {
				i = (qx + (qy++) * w) * 4;
				j = qw;
				while (j-- > 0) {
					p = r.readUnsignedInt();
					u[i + 0] = (p >> 16) & 255;
					u[i + 1] = (p >> 8) & 255;
					u[i + 2] = p & 255;
					u[i + 3] = (p >>> 24) & 255;
					i += 4;
				}
			}
		}
	}
	public function getColorBoundsRect(mask:Int, color:Int, findColor:Bool = true):Rectangle {
		syncData();
		var data:Uint8ClampedArray = __imageData.data;
		var minX = width, minY = height, maxX = 0, maxY = 0, len = data.length, i, px, x, y;
		i = 0;
		while (i < len) {
			px = (__transparent ? data[i + 3] << 24 : 0xFF000000)
			| ((data[i] & 0xFF) << 16) | ((data[i + 1] & 0xFF) << 8) | (data[i + 2] & 0xFF);
			if ((px == color) == findColor) {
				x = Math.floor((i >> 2) % width);
				y = Math.floor((i >> 2) / width);
				if (x < minX) minX = x;
				if (x > maxX) maxX = x;
				if (y < minY) minY = y;
				if (y > maxY) maxY = y;
			}
			i += 4;
		}
		if (minX <= maxX && minY <= maxY) return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
		if (!findColor) return new Rectangle(0, 0, width, height);
		return new Rectangle(0, 0, 0, 0);
	}
	public function floodFill(fx:Int, fy:Int, fc:Int):Void {
		// Slightly better than Jeash/NME/OpenFL version, but still some strange code.
		// At least it doesn't spam thousands of Point allocations.
		var wasCanvas = isCanvas();
		lock();
		var q:Array<Int> = [fx | (fy << 16)], // queue
			c:Int = 1, // length of queue
			d:Uint8ClampedArray = __imageData.data,
			zr:Int, zg:Int, zb:Int, za:Int, // start color
			fr:Int, fg:Int, fb:Int, fa:Int, // fill color
			x:Int, y:Int, p:Int, // x, y, pointer/swap variable
			o:Array<Array<Int>> = [], // inspection history array (width>>5 x height cells)
			r:Array<Int>, // row for init of above array
			w:Int = width, h:Int = height;
		// Retrieve RGBA of starting pixel:
		p = (fy * width + fx) << 4;
		zr = d[p]; zg = d[p + 1]; zb = d[p + 2]; za = d[p + 3];
		// Split target color into RGBA:
		fa = (fc >>> 24);
		fr = (fc >> 16) & 255;
		fg = (fc >> 8) & 255;
		fb = fc & 255;
		// Create history array:
		y = -1; while (++y < h) {
			o.push(r = []);
			x = 0; while (x < w) {
				r.push(0);
				x += 32;
			}
		}
		//
		while (c > 0) {
			p = q[--c]; // does the side matter?
			x = p & 0xffff;
			y = p >>> 16;
			// out of bounds (how did this happen...)?
			if (x < 0 || y < 0 || x >= w || y >= h) continue;
			// skip if cell was already inspected:
			if (((o[y][x >> 5] >> (x & 31)) & 1) != 0) continue;
			// mark cell as inspected:
			o[y][x >> 5] |= 1 << (x & 31);
			// find offset for imageData:
			p = (y * width + x) << 2;
			// if it matches source color, set it to destination color and try to expand:
			if (d[p] == zr && d[p + 1] == zg && d[p + 2] == zb && d[p + 3] == za) {
				d[p] = fr; d[p + 1] = fg; d[p + 2] = fb; d[p + 3] = fa;
				// attempt to expand in all directions if locations have not been inspected yet:
				if ((p = x + 1) < w && (((o[y][p >> 5] >> (p & 31)) & 1) == 0)) q[c++] = (y << 16) | p;
				if (x > 0 && (((o[y][(p = x - 1) >> 5] >> (p & 31)) & 1) == 0)) q[c++] = (y << 16) | p;
				if ((p = y + 1) < h && (((o[p][x >> 5] >> (x & 31)) & 1) == 0)) q[c++] = (p << 16) | x;
				if (y > 0 && (((o[(p = y - 1)][x >> 5] >> (x & 31)) & 1) == 0)) q[c++] = (p << 16) | x;
			}
		}
		__sync |= SY_CHANGE | SY_IMDATA;
		if (wasCanvas) unlock();
	}
	public function colorTransform(q:Rectangle, o:ColorTransform):Void {
		// 
		var x:Int = untyped ~~q.x, y:Int = untyped ~~q.y,
			w:Int = untyped ~~q.width, h:Int = untyped ~~q.height,
			tw:Int = this.width, th:Int = this.height,
			f:String = context.globalCompositeOperation, a:Float = context.globalAlpha;
		// Recoloring something outside bounds may be a bad idea:
		if (x < 0) { w += x; x = 0; }
		if (y < 0) { h += y; y = 0; }
		if (x + w > tw) w = tw - x;
		if (y + h > th) h = th - y;
		// Nothing to be done case:
		if (w <= 0 || h <= 0) return;
		// 
		if (o.isAlphaMultiplier()) {
			// "Oh, the easy case!"
			syncCanvas();
			// May need to use an extra canvas if GCO is not supported?
			context.globalCompositeOperation = "copy";
			context.globalAlpha *= o.alphaMultiplier;
			context.drawImage(component, x, y, w, h, x, y, w, h);
			//
			__sync |= 5;
		} else if (o.isColorSetter()) {
			// 
			var s = context.fillStyle;
			if (o.alphaMultiplier != 0) {
				// replace, multiply
				context.globalCompositeOperation = "source-in";
				context.fillStyle = untyped "rgb(" + ~~o.redOffset + "," + ~~o.greenOffset
					+ "," + ~~o.blueOffset + ")";
				context.fillRect(x, y, w, h);
				context.globalCompositeOperation = "copy";
				context.globalAlpha = o.alphaMultiplier;
				context.drawImage(component, x, y, w, h, x, y, w, h);
			} else {
				// replace
				context.globalCompositeOperation = "copy";
				context.fillStyle = untyped "rgba(" + ~~o.redOffset + "," + ~~o.greenOffset
					+ "," + ~~o.blueOffset + "," + ~~o.alphaOffset + ")";
				context.fillRect(x, y, w, h);
			}
			context.fillStyle = s;
		} else {
			// the long way around
			var wasCanvas = hasCanvas();
			lock();
			var d:Uint8ClampedArray = __imageData.data,
				c:Int = tw * th * 4, i:Int = c, v:Int,
				rm:Float = o.redMultiplier, gm:Float = o.greenMultiplier,
				bm:Float = o.blueMultiplier, am:Float = o.alphaMultiplier,
				ro:Float = o.redOffset, go:Float = o.greenOffset,
				bo:Float = o.blueOffset, ao:Float = o.alphaOffset;
			if (x == 0 && y == 0 && w == tw && h == th)
			untyped while ((i -= 4) >= 0) {
				if ((v = d[i + 3]) > 0) // flash behaviour: only A>0 pixels are affected
					d[i + 3] = (v = v * am + ao) < 0 ? 0 : v > 255 ? 255 : ~~v;
				d[i + 2] = (v = d[i + 2] * bm + bo) < 0 ? 0 : v > 255 ? 255 : ~~v;
				d[i + 1] = (v = d[i + 1] * gm + go) < 0 ? 0 : v > 255 ? 255 : ~~v;
				d[  i  ] = (v = d[  i  ] * rm + ro) < 0 ? 0 : v > 255 ? 255 : ~~v;
			} else {
				var px:Int, py:Int = y - 1, pb:Int = y + h, pr:Int;
				while (++py < pb) {
					i = (tw * py + x - 1) << 2;
					pr = i + w * 4;
					untyped while ((i += 4) < pr) {
						if ((v = d[i + 3]) > 0)
							d[i + 3] = (v = v * am + ao) < 0 ? 0 : v > 255 ? 255 : ~~v;
						d[i + 2] = (v = d[i + 2] * bm + bo) < 0 ? 0 : v > 255 ? 255 : ~~v;
						d[i + 1] = (v = d[i + 1] * gm + go) < 0 ? 0 : v > 255 ? 255 : ~~v;
						d[  i  ] = (v = d[  i  ] * rm + ro) < 0 ? 0 : v > 255 ? 255 : ~~v;
					}
				}
			}
			__sync |= SY_CHANGE | SY_IMDATA;
			if (wasCanvas) unlock();
		}
		context.globalCompositeOperation = f;
		context.globalAlpha = a;
	}
	public function copyChannel(o:BitmapData, q:Rectangle, p:Point,
	sourceChannel:Int, destChannel:Int):Void {
		var x:Int = untyped ~~o.x, px:Int = untyped ~~p.x,
			y:Int = untyped ~~o.y, py:Int = untyped ~~p.y,
			w:Int = untyped ~~q.width, h:Int = untyped ~~q.height,
			sw:Int = o.width, sh:Int = o.height,
			tw:Int = this.width, th:Int = this.height,
			i:Int, j:Int, u:Int, v:Int, c:Int,
			sc = sourceChannel, dc = destChannel;
		// No modifications outside bounds.
		if (px < 0) { w += px; px = 0; }
		if (py < 0) { h += py; py = 0; }
		if (x < 0) { w += x; x = 0; }
		if (y < 0) { h += y; y = 0; }
		if (x + w > sw) w = sw - x;
		if (y + h > sh) h = sh - y;
		if (px + w > tw) w = tw - px;
		if (py + h > th) h = th - py;
		// Nothing to be done case:
		if (w <= 0 || h <= 0) return;
		//
		if (sc == BitmapDataChannel.ALPHA && dc == BitmapDataChannel.ALPHA) {
			// ridiculous, but still 10x faster than ImageData...
			var f = context.globalCompositeOperation, s = context.fillStyle;
			// draw image into itself 8 times to max out opacity:
			context.globalCompositeOperation = "darker";
			i = 0; while (i++ < 8)
			context.drawImage(component, px, py, w, h, px, py, w, h);
			// replace fully transparent areas with black (flash behaviour):
			context.globalCompositeOperation = "destination-over";
			context.fillStyle = "black";
			context.fillRect(x, y, w, h);
			// "multiply" alpha channels of images:
			context.globalCompositeOperation = "destination-atop";
			context.drawImage(o.handle(), x, y, w, h, px, py, w, h);
			// restore state:
			context.globalCompositeOperation = f;
			context.fillStyle = s;
		} else {
			var wasCanvas = hasCanvas(), ds:Uint8ClampedArray, dd:Uint8ClampedArray;
			lock(); dd = __imageData.data;
			o.lock(); ds = o.__imageData.data;
			// find channel offsets:
			sc = sc == 8 ? 3 : sc == 4 ? 2 : sc == 2 ? 1 : sc == 1 ? 0 : -1;
			dc = dc == 8 ? 3 : dc == 4 ? 2 : dc == 2 ? 1 : dc == 1 ? 0 : -1;
			// wrong channels?
			if (sc < 0 || dc < 0) return;
			// a bit of optimized mess:
			j = py + h; v = y + h;
			while (--v >= y) {
				--j;
				c = w;
				i = (px + tw * j) * 4 + sc; u = (x + sw * v) * 4 + dc;
				while (c-- > 0) {
					dd[u] = ds[i];
					i += 4; u += 4;
				}
			}
			__sync |= SY_CHANGE | SY_IMDATA;
			if (wasCanvas) unlock();
		}
	}
	public function noise(q:Int, l:Int = 0, h:Int = 255, c:Int = 7, m:Bool = false):Void {
		var wasCanvas:Bool = hasCanvas(), i:Int = 0, n:Int,
			// pixels, delta, random seed:
			p:Uint8ClampedArray, d:Int = h - l + 1, z:Int = q,
			// channel flags:
			r:Bool = (c & 1) > 0, g:Bool = (c & 2) > 0,
			b:Bool = (c & 4) > 0, a:Bool = (c & 8) > 0;
		// Has exactly right behaviour:
		inline function rand():Int return z = (z * 16807) % 2147483647;
		// Lock and process:
		lock();
		p = __imageData.data;
		n = p.length;
		while (i < n) {
			if (m) { // grayscale/monochrome
				p[i] = p[i + 1] = p[i + 2] = l + rand() % d;
				i += 3;
			} else { // RGB
				p[i++] = r ? l + rand() % d : 0;
				p[i++] = g ? l + rand() % d : 0;
				p[i++] = b ? l + rand() % d : 0;
			}
			// alpha channel:
			p[i++] = a ? l + rand() % d : 255;
		}
		//
		__sync |= SY_CHANGE | SY_IMDATA;
		if (wasCanvas) unlock();
	}
	public function applyFilter(sourceBitmapData:BitmapData, sourceRect:openfl.geom.Rectangle,
	destPoint:openfl.geom.Point, filter:openfl.filters.BitmapFilter):Void {
		
	}
	/// Jeash/NME-specific:
	function jeashOnLoad( data:LoadData, e) {
		var canvas:CanvasElement = cast data.texture;
		var width = data.image.width;
		var height = data.image.height;
		canvas.width = width;
		canvas.height = height;

		var ctx : CanvasRenderingContext2D = canvas.getContext("2d");
		ctx.drawImage(data.image, 0, 0, width, height);

		data.bitmapData.width = width;
		data.bitmapData.height = height;
		data.bitmapData.__rect = new Rectangle(0,0,width,height);

		if (data.inLoader != null) {
			var e = new Event(Event.COMPLETE);
			e.target = data.inLoader;
			data.inLoader.dispatchEvent( e );
		}
	}
	public function nmeLoadFromFile(inFilename:String, ?inLoader:LoaderInfo) {
		var image : ImageElement = cast js.Browser.document.createElement("img");
		if ( inLoader != null ) {
			var data : LoadData = {image:image, texture: component, inLoader:inLoader, bitmapData:this};
			image.addEventListener( "load", jeashOnLoad.bind(data), false );
			// IE9 bug, force a load, if error called and complete is false.
			image.addEventListener( "error", function (e) { if (!image.complete) jeashOnLoad(data, e); }, false);
		}
		image.src = inFilename;
	}
	/// Helper functions
	// creates a rgba() string:
	static /*inline*/ function makeColor(color:Int):String {
		untyped { return 'rgba(' + ((color >> 16) & 0xFF)
			+ ',' + ((color >> 8) & 0xFF)
			+ ',' + (color & 0xFF)
			+ ',' + (((color >> 24) & 0xFF) / 255).toFixed(4)
			+ ')';
		}
	}
	// ensures that Canvas element is up-to-date:
	function syncCanvas():Void {
		if (!hasCanvas()) {
			context.putImageData(__imageData, 0, 0);
			__sync = (__sync & 0xFFFFFFFC);
		}
	}
	// ensures that ImageData is up-to-date:
	function syncData():Void {
		if (!hasImData()) {
			__imageData = context.getImageData(0, 0,
				component.width, component.height);
			__sync = (__sync & 0xFFFFFFFC);
		}
	}
	
	@:extern private inline function isImData():Bool { return __sync & SM_TYPE == SY_IMDATA; }
	@:extern private inline function isCanvas():Bool { return __sync & SM_TYPE == SY_CANVAS; }
	@:extern private inline function hasImData():Bool { return __sync & SM_TYPE != SY_CANVAS; }
	@:extern private inline function hasCanvas():Bool { return __sync & SM_TYPE != SY_IMDATA; }
	/**
	 * 
	 * @param	bytes	ByteArray containing image bytes (PNG/JPG)
	 * @param	inRawAlpha	(optional) A ByteArray containing alpha values (bytes) for each pixel of image.
	 * @param	onload	Callback for when BitmapData is fully loaded.
	 * @return	Resulting BitmapData. Will remain 0x0 until actually loaded.
	 */
	public static function loadFromBytes(bytes:ByteArray, inRawAlpha:ByteArray = null, onload:BitmapData->Void) {
		var bitmapData = new BitmapData(0, 0);
		bitmapData.__loadFromBytes(bytes, inRawAlpha, onload);
		return bitmapData;
	}
	
	private function __loadFromBytes(c:ByteArray, a:ByteArray = null, ?h:BitmapData->Void) {
		var t:String = null; // type
		var o:ImageElement = untyped document.createElement("img");
		var n:CanvasElement = component;
		var q:CanvasRenderingContext2D;
		var f:Dynamic->Void = null;
		var i:Int, l:Int;
		var p:ImageData;
		// determine type:
		if (__isPNG(c)) {
			t = "png";
		} else if (__isJPG(c)) {
			t = "jpeg";
		} else throw new IOError("BitmapData can only load from ByteArrays with PNG/JPEG data.");
		//
		f = function(_) {
			o.removeEventListener("load", f);
			//
			__rect.width = n.width = o.width;
			__rect.height = n.height = o.height;
			q = context = n.getContext("2d");
			//
			q.drawImage(o, 0, 0);
			// load alpha from a 8-bit collection, if provided:
			if (a != null) {
				i = -1; l = a.length;
				p = q.getImageData(0, 0, o.width, o.height);
				while (++i < l) p.data[(i << 2) + 3] = a.readUnsignedByte();
				q.putImageData(p, 0, 0);
			}
			//
			if (h != null) h(this);
		};
		o.addEventListener("load", f);
		o.src = "data:image/" + t + ";base64," + c.toBase64();
	}
	/// Returns whether given ByteArray seems to start like a PNG
	private static function __isPNG(d:ByteArray) {
		if (d.length < 8) return false;
		d.position = 0;
		return (d.readByte() == 0x89 && d.readByte() == 0x50 && d.readByte() == 0x4E && d.readByte() == 0x47
			&& d.readByte() == 0x0D && d.readByte() == 0x0A && d.readByte() == 0x1A && d.readByte() == 0x0A);
	}
	/// Returns whether given ByteArray seems to start like a JPG
	private static function __isJPG(d:ByteArray) {
		if (d.length < 2) return false;
		d.position = 0;
		return (d.readByte() == 0xFF && d.readByte() == 0xD8);
	}
}
#end