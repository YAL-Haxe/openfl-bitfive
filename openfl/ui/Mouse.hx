package openfl.ui;
#if js
class Mouse {
	public static var cursor:Dynamic;
	public static function hide():Void {
		openfl.Lib.stage.component.style.cursor = "none";
	}
	public static function show():Void {
		openfl.Lib.stage.component.style.cursor = null;
	}
}
#end