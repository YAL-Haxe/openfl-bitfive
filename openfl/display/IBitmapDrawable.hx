package flash.display;
#if js
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

interface IBitmapDrawable {
	function drawToSurface(cnv:CanvasElement, ctx:CanvasRenderingContext2D, ?mtx:Matrix,
		?ctr:ColorTransform, ?blendMode:BlendMode, ?clipRect:Rectangle, ?smoothing:Bool):Void;
}
#end