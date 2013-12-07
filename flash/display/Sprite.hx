package flash.display;
#if js
import flash.display.Graphics;

class Sprite extends DisplayObjectContainer implements IBitmapDrawable {
	//
	public var graphics(get, null):Graphics;
	private var _graphics:Graphics;
	public var useHandCursor(default, set):Bool;
	public var buttonMode:Bool;
	//
	public function new() {
		super();
	}
	
	private function get_graphics():Graphics {
		if (_graphics == null) {
			// This is made into a getter since it's common to use Sprite as generic container.
			var o:Graphics = new Graphics(), q = o.component;
			o.displayObject = this;
			if (this.children.length == 0) component.appendChild(q);
			else component.insertBefore(q, children[0].component);
			_graphics = o;
		}
		return _graphics;
	}
	
	override private function set_stage(v:Stage):Stage {
		var z = stage == null && v != null,
			r = super.set_stage(v);
		if (z && _graphics != null) _graphics.invalidate();
		return r;
	}
	
	private function set_useHandCursor(o:Bool):Bool {
		component.style.cursor = o ? 'pointer' : null;
		return (useHandCursor = o);
	}
	
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?mtx:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		graphics.drawToSurface(cnv, ctx, mtx, ctr, blendMode, clipRect, smoothing);
	}
}
#end