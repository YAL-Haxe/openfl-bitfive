package flash.filters;
#if js
class ColorMatrixFilter extends BitmapFilter {
	public var matrix:Array<Float>;
	public function new(?matrix:Array<Float>) {
		super();
		if (matrix == null) {
			this.matrix = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
		} else this.matrix = matrix;
	}
	override public function clone():BitmapFilter {
		return new ColorMatrixFilter(matrix.copy());
	}
}
#end
