package openfl.display;
#if js
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

interface IBitmapDrawable {
	function drawToSurface(cnv:CanvasElement, ctx:CanvasRenderingContext2D, ?mtx:Matrix,
		?ctr:ColorTransform, ?blendMode:BlendMode, ?clipRect:Rectangle, ?smoothing:Bool):Void;
}
#end