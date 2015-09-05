package openfl.display;
#if (js && !display)
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import flash.geom.Matrix;

interface IGraphics extends IBitmapDrawable {
	// bitfive-specific
	var component:CanvasElement;
	var context:CanvasRenderingContext2D;
	function invalidate():Void;
	function hitTestLocal(x:Float, y:Float, p:Bool):Bool;
	//
	function beginBitmapFill(bitmap:BitmapData, ?matrix:Matrix, ?repeat:Bool, ?smooth:Bool):Void;
	function beginFill(color:Int, ?alpha:Float = 1):Void;
	function beginGradientFill(type:GradientType, colors:Array<UInt>, alphas:Array<Dynamic>, ratios:Array<Dynamic>, ?matrix:Matrix, ?spreadMethod:SpreadMethod, ?interpolationMethod:InterpolationMethod, focalPointRatio:Float = 0):Void;
	function clear():Void;
	function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float):Void;
	function drawCircle(x:Float, y:Float, radius:Float):Void;
	function drawEllipse(x:Float, y:Float, width:Float, height:Float):Void;
	function drawRect(x:Float, y:Float, width:Float, height:Float):Void;
	function drawRoundRect(x:Float, y:Float, width:Float, height:Float, ellipseWidth:Float, ?ellipseHeight:Float):Void;
	function endFill():Void;
	function lineStyle(?thickness:Float, ?color:UInt, ?alpha:Float, ?pixelHinting:Bool, ?scaleMode:LineScaleMode, ?caps:CapsStyle, ?joints:JointStyle, ?miterLimit:Float):Void;
	function lineTo(x:Float, y:Float):Void;
	function moveTo(x:Float, y:Float):Void;
}
#end
