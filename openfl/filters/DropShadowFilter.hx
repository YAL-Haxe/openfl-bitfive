package openfl.filters;
#if js
import openfl.Lib;
class DropShadowFilter extends BitmapFilter {
	public var distance:Float;
	public var angle:Float;
	public var color:Int;
	public var alpha:Float;
	public var blurX:Float;
	public var blurY:Float;
	public var strength:Float;
	public var quality:Int;
	public var inner:Bool;
	public var knockout:Bool;
	public var hideObject:Bool;
	public function new (?distance:Float, ?angle:Float, ?color:Int, ?alpha:Float, ?blurX:Float, ?blurY:Float, ?strength:Float, ?quality:Int, ?inner:Bool, ?knockout:Bool, ?hideObject:Bool) {
		super();
		this.distance = Lib.nz(distance, 4);
		this.angle = Lib.nz(angle, 45);
		this.color = Lib.nz(color, 0);
		this.alpha = Lib.nz(alpha, 1);
		this.blurX = Lib.nz(blurX, 4);
		this.blurY = Lib.nz(blurY, 4);
		this.strength = Lib.nz(strength, 1);
		this.quality = Lib.nz(quality, 1);
		this.inner = Lib.nz(inner, false);
		this.knockout = Lib.nz(knockout, false);
		this.hideObject = Lib.nz(hideObject, false);
	}
	override public function clone():BitmapFilter {
		return new DropShadowFilter(distance, angle, color, alpha,
			blurX, blurY, strength, quality, inner, knockout, hideObject);
	}
}
#end
