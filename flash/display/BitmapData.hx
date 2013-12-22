package flash.display;

import flash.errors.IOError;
import flash.utils.ByteArray;
import js.html.ImageData;
import js.html.ImageElement;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.geom.Point;
import js.html.Uint8ClampedArray;


typedef LoadData = {
	var image : ImageElement;
	var texture:CanvasElement;
	var inLoader:Null<LoaderInfo>;
	var bitmapData:BitmapData;
}

class ImageDataLease {
	public var seed:Float;
	public var time:Float;
	public function new () {}
	public function set(s,t) { 
		this.seed = s; 
		this.time = t; 
	}
	public function clone() {
		var leaseClone = new ImageDataLease();
		leaseClone.seed = seed;
		leaseClone.time = time;
		return leaseClone;
	}
}
/**
 * Status: Almost there!
 * Most functions work correctly.
 * Only alpha channel of ColorTransform's is supported.
 * Specific BitmapData can only be bound to a one Bitmap at time.
 */
class BitmapData implements IBitmapDrawable {
	public var component:CanvasElement;
	public var qContext:CanvasRenderingContext2D;

	public var width(get, null):Int;
	public var height(get, null):Int;
	public var rect:Rectangle;

	// qSync flags
	/** 0x1 Indicates that Canvas represents current state */
	@:extern private static inline var SY_CANVAS = 0x1;
	/** 0x2 Indicates that ImageData represents current state */
	@:extern private static inline var SY_IMDATA = 0x2;
	/** 0x4 Indicates that state has changed */
	@:extern private static inline var SY_CHANGE = 0x4;
	/** 0x3 Mask for checking current type */
	@:extern private static inline var SM_TYPE = 0x3;
	/** A pointer to current imageData object */
	var qImageData:ImageData;
	/** Modification flags (1: canvas; 2: imageData; 4: changed) */
	var qSync:Int;
	/** Indicates if bitmap's background is transparent */
	var qTransparent:Bool;
	/** Time (Date.getTime()) of last change to canvas */
	var qTime:Float;
	/** Seed (not right term?) of last change to canvas */
	var qTick:Int;
	/** Single-pixel image-data. Could be static too */
	var qPixel:ImageData;

	public function new(inWidth:Int, inHeight:Int,
			?inTransparent:Bool = true,
			?inFillColor:Int) {
		qSync = 1;
		qTransparent = inTransparent;
		qTick = 0;
		qTime = Date.now().getTime();
		rect = new Rectangle(0, 0, inWidth, inHeight);
		// create canvas:
		component = flash.Lib.jsCanvas();
		#if debug
			component.setAttribute("node", Type.getClassName(Type.getClass(this)));
		#end
		component.width = inWidth;
		component.height = inHeight;
		qContext = component.getContext('2d');
		setSmoothing(qContext, true);
		qPixel = qContext.createImageData(1, 1);
		// fill with white by default:
		if (inFillColor == null) inFillColor = 0xFFFFFFFF;
		// make fill opaque if not transparent:
		if (!inTransparent) inFillColor |= 0xFF000000;
		// if context must be filled:
		if ((inFillColor & 0xFF000000) != 0) {
			fillRect(rect, inFillColor);
		}
	}
	public function fillRect(area:Rectangle, color:UInt):Void {
		// common useless operation check:
		if (area == null || area.width <= 0 || area.height <= 0) return;
		// trick for clearing canvas fast:
		if (area.equals(rect) && qTransparent && ((color & 0xFF000000) == 0)) {
			component.width = component.width;
			return;
		}
		if (!qTransparent) {
			// rectangles are opaque on non-transparent bitmaps
			color |= 0xFF000000;
		} else if ((color & 0xFF000000) != 0xFF000000) {
			// clear what was below the rectangle in transparent ones
			qContext.clearRect(area.x, area.y, area.width, area.height);
		}
		// now actually just draw a rectangle:
		if ((color & 0xFF000000) != 0) {
			qContext.fillStyle = makeColor(color);
			qContext.fillRect(area.x, area.y, area.width, area.height);
		}
		qSync |= SY_CANVAS | SY_CHANGE;
	}
	//
	public function clone():BitmapData {
		syncCanvas();
		var r:BitmapData = new BitmapData(width, height, qTransparent, 0x0);
		r.qContext.drawImage(component, 0, 0);
		r.qSync |= SY_CANVAS | SY_CHANGE;
		return r;
	}
	public function dispose():Void {
		component.width = component.height = 1;
		qImageData = null;
		qSync = SY_CANVAS | SY_CHANGE;
	}
	public function handle():CanvasElement {
		syncCanvas();
		if ((qSync & SY_CHANGE) != 0) {
			qTick++;
			qTime = Date.now().getTime();
			qSync &= ~SY_CHANGE;
		}
		return component;
	}
	private inline function getTime():Float { return qTime; }
	private inline function getTick():Int { return qTick; }
	@:extern private inline function get_width():Int {
		return component.width;
	}
	@:extern private inline function get_height():Int {
		return component.height;
	}
	//
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?matrix:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
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
		if (qTransparent && !mergeAlpha) {
			qContext.clearRect(dx, dy, sw, sh);
		}
		// draw:
		qContext.drawImage(bit, sx, sy, sw, sh, dx, dy, sw, sh);
		//
		qSync |= SY_CANVAS | SY_CHANGE;
	}
	public function draw(source:IBitmapDrawable, ?matrix:Matrix,
			?colorTransform:ColorTransform, ?blendMode:Dynamic,
			?clipRect:Rectangle, ?smoothing):Void {
		syncCanvas();
		var a:Float = 0;
		qContext.save();
		if (colorTransform != null) {
			// currently only alpha channel of colorTransforms is supported.
			// use .colorTransform to "bake" colored versions.
			a = colorTransform.alphaMultiplier;
			colorTransform.alphaMultiplier = 1;
			qContext.globalAlpha *= a;
		}
		if (clipRect != null) {
			qContext.beginPath();
			qContext.rect(clipRect.x, clipRect.y, clipRect.width, clipRect.height);
			qContext.clip();
		}
		if (smoothing != null) setSmoothing(qContext, smoothing);
		source.drawToSurface(handle(), qContext, matrix, colorTransform, blendMode, clipRect, null);
		qContext.restore();
		if (colorTransform != null) {
			colorTransform.alphaMultiplier = a;
		}
		qSync |= SY_CANVAS | SY_CHANGE;
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
	public function getPixel(x:Int, y:Int):Int {
		if (x < 0 || y < 0 || x >= width || y >= height) return 0;
		if ((qSync & 3) == 1) {
			var d = qContext.getImageData(x, y, 1, 1).data;
			return (d[0] << 16) | (d[1] << 8) | d[2];
		} else {
			var o = (y * width + x) << 2;
			return (qImageData.data[o] << 16) | (qImageData.data[o + 1] << 8) | qImageData.data[o + 2];
		}
	}
	public function getPixel32(x:Int, y:Int):Int {
		if (x < 0 || y < 0 || x >= width || y >= height) return 0;
		if ((qSync & 3) == 1) {
			var d = qContext.getImageData(x, y, 1, 1).data;
			return (qTransparent ? d[3] << 24 : 0xFF000000) | (d[0] << 16) | (d[1] << 8) | d[2];
		} else {
			var o = (y * width + x) << 2;
			return (qTransparent ? qImageData.data[o + 3] << 24 : 0xFF000000)
			| (qImageData.data[o] << 16)
			| (qImageData.data[o + 1] << 8)
			| qImageData.data[o + 2];
		}
	}
	public function setPixel(x:Int, y:Int, color:Int):Void {
		if (x < 0 || y < 0 || x >= width || y >= height) return;
		if (hasCanvas()) {
			qPixel.data[0] = (color >>> 16) & 0xFF;
			qPixel.data[1] = (color >>> 8) & 0xFF;
			qPixel.data[2] = color & 0xFF;
			qPixel.data[3] = 0xFF;
			qContext.putImageData(qPixel, x, y);
			qSync |= SY_CHANGE | SY_CANVAS;
		} else {
			var o = (y * width + x) << 2;
			qImageData.data[o] = (color >>> 16) & 0xFF;
			qImageData.data[o+1] = (color >>> 8) & 0xFF;
			qImageData.data[o+2] = color & 0xFF;
			qImageData.data[o+3] = 0xFF;
			qSync |= SY_CHANGE | SY_IMDATA;
		}
	}
	public function setPixel32(x:Int, y:Int, color:Int):Void {
		if (x < 0 || y < 0 || x >= width || y >= height) return;
		if (hasCanvas()) {
			qPixel.data[0] = (color >>> 16) & 0xFF;
			qPixel.data[1] = (color >>> 8) & 0xFF;
			qPixel.data[2] = color & 0xFF;
			qPixel.data[3] = (color >>> 24) & 0xFF;
			qContext.putImageData(qPixel, x, y);
			qSync |= SY_CHANGE | SY_CANVAS;
		} else {
			var o = (y * width + x) << 2;
			qImageData.data[o] = (color >>> 16) & 0xFF;
			qImageData.data[o+1] = (color >>> 8) & 0xFF;
			qImageData.data[o+2] = color & 0xFF;
			qImageData.data[o+3] = (color >>> 24) & 0xFF;
			qSync |= SY_CHANGE | SY_IMDATA;
		}
	}
	public function getColorBoundsRect(mask:Int, color:Int, findColor:Bool = true):Rectangle {
		syncData();
		var data:Uint8ClampedArray = qImageData.data;
		var minX = width, minY = height, maxX = 0, maxY = 0, len = data.length, i, px, x, y;
		i = 0;
		while (i < len) {
			px = (qTransparent ? data[i + 3] << 24 : 0xFF000000)
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
			d:Uint8ClampedArray = qImageData.data,
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
		qSync |= SY_CHANGE | SY_IMDATA;
		if (wasCanvas) unlock();
	}
	public function colorTransform(q:flash.geom.Rectangle, o:flash.geom.ColorTransform):Void {
		// 
		var x:Int = untyped ~~q.x, y:Int = untyped ~~q.y,
			w:Int = untyped ~~q.width, h:Int = untyped ~~q.height,
			tw:Int = this.width, th:Int = this.height,
			f:String = qContext.globalCompositeOperation, a:Float = qContext.globalAlpha;
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
			qContext.globalCompositeOperation = "copy";
			qContext.globalAlpha *= o.alphaMultiplier;
			qContext.drawImage(component, x, y, w, h, x, y, w, h);
			//
			qSync |= 5;
		} else if (o.isColorSetter()) {
			// 
			var s = qContext.fillStyle;
			if (o.alphaMultiplier != 0) {
				// replace, multiply
				qContext.globalCompositeOperation = "source-in";
				qContext.fillStyle = untyped "rgb(" + ~~o.redOffset + "," + ~~o.greenOffset
					+ "," + ~~o.blueOffset + ")";
				qContext.fillRect(x, y, w, h);
				qContext.globalCompositeOperation = "copy";
				qContext.globalAlpha = o.alphaMultiplier;
				qContext.drawImage(component, x, y, w, h, x, y, w, h);
			} else {
				// replace
				qContext.globalCompositeOperation = "copy";
				qContext.fillStyle = untyped "rgba(" + ~~o.redOffset + "," + ~~o.greenOffset
					+ "," + ~~o.blueOffset + "," + ~~o.alphaOffset + ")";
				qContext.fillRect(x, y, w, h);
			}
			qContext.fillStyle = s;
		} else {
			// the long way around
			var wasCanvas = hasCanvas();
			lock();
			var d:Uint8ClampedArray = qImageData.data,
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
			qSync |= SY_CHANGE | SY_IMDATA;
			if (wasCanvas) unlock();
		}
		qContext.globalCompositeOperation = f;
		qContext.globalAlpha = a;
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
			var f = qContext.globalCompositeOperation, s = qContext.fillStyle;
			// draw image into itself 8 times to max out opacity:
			qContext.globalCompositeOperation = "darker";
			i = 0; while (i++ < 8)
			qContext.drawImage(component, px, py, w, h, px, py, w, h);
			// replace fully transparent areas with black (flash behaviour):
			qContext.globalCompositeOperation = "destination-over";
			qContext.fillStyle = "black";
			qContext.fillRect(x, y, w, h);
			// "multiply" alpha channels of images:
			qContext.globalCompositeOperation = "destination-atop";
			qContext.drawImage(o.handle(), x, y, w, h, px, py, w, h);
			// restore state:
			qContext.globalCompositeOperation = f;
			qContext.fillStyle = s;
		} else {
			var wasCanvas = hasCanvas(), ds:Uint8ClampedArray, dd:Uint8ClampedArray;
			lock(); dd = qImageData.data;
			o.lock(); ds = o.qImageData.data;
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
				i = (px + tw * j) * 4 + dc; u = (x + sw * v) * 4 + sc;
				while (c-- > 0) {
					dd[u] = ds[i];
					i += 4; u += 4;
				}
			}
			qSync |= SY_CHANGE | SY_IMDATA;
			if (wasCanvas) unlock();
		}
	}
	public function applyFilter(sourceBitmapData:BitmapData, sourceRect:flash.geom.Rectangle,
	destPoint:flash.geom.Point, filter:flash.filters.BitmapFilter):Void {
		
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
		data.bitmapData.rect = new Rectangle(0,0,width,height);

		if (data.inLoader != null) {
			var e = new flash.events.Event( flash.events.Event.COMPLETE );
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
	static /*inline*/ function makeColor(color:UInt):String {
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
			qContext.putImageData(qImageData, 0, 0);
			qSync = (qSync & 0xFFFFFFFC);
		}
	}
	// ensures that ImageData is up-to-date:
	function syncData():Void {
		if (!hasImData()) {
			qImageData = qContext.getImageData(0, 0,
				component.width, component.height);
			qSync = (qSync & 0xFFFFFFFC);
		}
	}
	
	@:extern private inline function isImData():Bool { return qSync & SM_TYPE == SY_IMDATA; }
	@:extern private inline function isCanvas():Bool { return qSync & SM_TYPE == SY_CANVAS; }
	@:extern private inline function hasImData():Bool { return qSync & SM_TYPE != SY_CANVAS; }
	@:extern private inline function hasCanvas():Bool { return qSync & SM_TYPE != SY_IMDATA; }
	// All that goes below is from NME:
	public static function loadFromBytes(bytes:ByteArray, inRawAlpha:ByteArray = null, onload:BitmapData -> Void) {
		var bitmapData = new BitmapData(0, 0);
		bitmapData.nmeLoadFromBytes(bytes, inRawAlpha, onload);
		return bitmapData;
	}
	
	private function nmeLoadFromBytes(c:ByteArray, a:ByteArray = null, ?h:BitmapData->Void) {
		var t:String,
			o:ImageElement = untyped document.createElement("img"),
			n:CanvasElement = component,
			q:CanvasRenderingContext2D,
			f:Dynamic->Void = null,
			i:Int, l:Int, p:ImageData;
		if (!flash.Lib.bool(t = nmeIsPNG(c) ? "png" : nmeIsJPG(c) ? "jpeg" : ""))
			throw new IOError("BitmapData can only load from ByteArrays with PNG/JPEG data.");
		f = function(_) {
			o.removeEventListener("load", f);
			//
			rect.width = n.width = o.width;
			rect.height = n.height = o.height;
			q = qContext = n.getContext("2d");
			//
			q.drawImage(o, 0, 0);
			//
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

	private static function nmeIsPNG(bytes:ByteArray) {
		
		bytes.position = 0;
		return (bytes.readByte() == 0x89 && bytes.readByte() == 0x50 && bytes.readByte() == 0x4E && bytes.readByte() == 0x47 && bytes.readByte() == 0x0D && bytes.readByte() == 0x0A && bytes.readByte() == 0x1A && bytes.readByte() == 0x0A);
		
	}
	private static function nmeIsJPG(bytes:ByteArray) {
		bytes.position = 0;
		return bytes.readByte() == 0xFF && bytes.readByte() == 0xD8;
	}
}
