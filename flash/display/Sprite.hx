package flash.display;
#if js
import flash.display.Graphics;

class Sprite extends DisplayObjectContainer implements IBitmapDrawable {
	//
	public var graphics(get, null):IGraphics;
	private var _graphics:IGraphics;
	public var useHandCursor(default, set):Bool;
	public var buttonMode:Bool;
	//
	public function new() {
		super();
	}
	
	private function get_graphics():IGraphics {
		if (_graphics == null) {
			// This is made into a getter since it's common to use Sprite as a generic container.
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
	
	override public function hitTestLocal(x:Float, y:Float, p:Bool, ?v:Bool):Bool {
		var g;
		return hitTestVisible(v) && (
			super.hitTestLocal(x, y, p, v) || (
				((g = _graphics) != null) && g.hitTestLocal(x, y, p)
			)
		);
	}
}
#end