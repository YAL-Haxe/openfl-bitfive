package flash.display;
#if js
class Bitmap extends DisplayObject implements IBitmapDrawable {
	public var bitmapData(default, set):BitmapData;
	/// Cannot be properly implemented at the moment. Please use the BitmapData.draw() parameter.
	public var smoothing:Bool = false;
	/// Has no effect.
	public var pixelSnapping:Bool = false;
	public function new(?bitmapData:BitmapData, ?pixelSnapping:Dynamic, smoothing:Bool = false) {
		super();
		this.bitmapData = bitmapData;
	}
	private function set_bitmapData(v:BitmapData):BitmapData {
		if (bitmapData != null) {
			component.removeChild(bitmapData.component);
		}
		if (v != null) {
			component.appendChild(v.handle());
		}
		return bitmapData = v;
	}
	override private function get_width():Float {
		return __width != null ? __width : bitmapData != null ? bitmapData.width : 0;
	}
	override private function get_height():Float {
		return __height != null ? __height : bitmapData != null ? bitmapData.height : 0;
	}
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?matrix:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		bitmapData.drawToSurface(cnv, ctx, matrix, ctr, blendMode, clipRect, smoothing);
	}
	override public function hitTestLocal(x:Float, y:Float, p:Bool, ?v:Bool):Bool {
		return hitTestVisible(v) && bitmapData != null && x >= 0 && y >= 0 && x < bitmapData.width && y < bitmapData.height;
	}
}
#end