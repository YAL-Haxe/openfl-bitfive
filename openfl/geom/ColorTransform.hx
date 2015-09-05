package openfl.geom;
#if js
import flash.Lib;

class ColorTransform {
	public var alphaMultiplier:Float;
	public var alphaOffset:Float;
	public var blueMultiplier:Float;
	public var blueOffset:Float;
	public var color(get_color, set_color):Int;
	public var greenMultiplier:Float;
	public var greenOffset:Float;
	public var redMultiplier:Float;
	public var redOffset:Float;
	
	public function new(?r:Float, ?g:Float, ?b:Float, ?a:Float,
	?ro:Float, ?go:Float, ?bo:Float, ?ao:Float):Void {
		redMultiplier = Lib.nz(r, 1);
		greenMultiplier = Lib.nz(g, 1);
		blueMultiplier = Lib.nz(b, 1);
		alphaMultiplier = Lib.nz(a, 1);
		redOffset = Lib.nz(ro, 0);
		greenOffset = Lib.nz(go, 0);
		blueOffset = Lib.nz(bo, 0);
		alphaOffset = Lib.nz(ao, 0);
	}
	
	public function concat(o:ColorTransform):Void {
		redMultiplier += o.redMultiplier;
		greenMultiplier += o.greenMultiplier;
		blueMultiplier += o.blueMultiplier;
		alphaMultiplier += o.alphaMultiplier;
	}
	
	/** Returns whether CT is used to fully override RGB(A) of image */
	public function isColorSetter():Bool {
		return redMultiplier == 0 && greenMultiplier == 0 && blueMultiplier == 0
		&& (alphaMultiplier == 0 || alphaOffset == 0);
	}
	
	/** Returns whether CT only affects alpha channel */
	public function isAlphaMultiplier():Bool {
		return redMultiplier == 1 && greenMultiplier == 1 && blueMultiplier == 1
		&& redOffset == 0 && greenOffset == 0 && blueOffset == 0 && alphaOffset == 0;
	}
	
	// Getters & Setters
	private function get_color():Int {
		return ((Std.int(redOffset) << 16) |(Std.int(greenOffset) << 8) | Std.int(blueOffset));
	}
	
	private function set_color(value:Int):Int {
		redOffset = (value >> 16) & 0xFF;
		greenOffset = (value >> 8) & 0xFF;
		blueOffset = value & 0xFF;
		
		redMultiplier = greenMultiplier = blueMultiplier = 0;
		
		return color;
	}
}


#end