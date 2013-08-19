package flash.display;
#if js

class Shape extends DisplayObject {
	public var graphics(default, null):Graphics;
	public function new() {
		(graphics = new Graphics()).displayObject = this;
		component = graphics.component;
		super();
	}
}
#end