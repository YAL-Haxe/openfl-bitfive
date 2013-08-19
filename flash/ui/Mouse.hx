package flash.ui;
#if js
class Mouse {
	public static var cursor:Dynamic;
	public static function hide():Void {
		flash.Lib.stage.component.style.cursor = "none";
	}
	public static function show():Void {
		flash.Lib.stage.component.style.cursor = null;
	}
}
#end