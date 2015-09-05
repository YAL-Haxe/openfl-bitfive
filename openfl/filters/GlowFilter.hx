package openfl.filters;
#if js
class GlowFilter extends BitmapFilter {
	public var color:Int;
	public var alpha:Float;
	public var blurX:Float;
	public var blurY:Float;
	public var strength:Float;
	public var quality:Int;
	public var inner:Bool;
	public var knockout:Bool;
	public function new (?color:Int, ?alpha:Float, ?blurX:Float, ?blurY:Float, ?strength:Float, ?quality:Int, ?inner:Bool, ?knockout:Bool) {
		super();
		this.color = Lib.nz(color, 0);
		this.alpha = Lib.nz(alpha, 1);
		this.blurX = Lib.nz(blurX, 6);
		this.blurY = Lib.nz(blurY, 6);
		this.strength = Lib.nz(strength, 2);
		this.quality = Lib.nz(quality, 1);
		this.inner = Lib.nz(inner, false);
		this.knockout = Lib.nz(knockout, false);
	}
	override public function clone():BitmapFilter {
		return new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}
}
#end
