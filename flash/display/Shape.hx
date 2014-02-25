package flash.display;
#if js

class Shape extends DisplayObject implements IBitmapDrawable {
	public var graphics(default, null):Graphics;
	public function new() {
		(graphics = new Graphics()).displayObject = this;
		component = graphics.component;
		super();
	}
	
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?mtx:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		graphics.drawToSurface(cnv, ctx, mtx, ctr, blendMode, clipRect, smoothing);
	}
	override private function set_stage(v:Stage):Stage {
		var z = stage == null && v != null,
			r = super.set_stage(v);
		if (z) graphics.invalidate();
		return r;
	}
	override public function hitTestLocal(x:Float, y:Float):Bool {
		return graphics.hitTestLocal(x, y);
	}
}
#end