package flash.text;
#if js
/**
 * Status: Implementation pending.
 * Should serialize and load fonts... or use web fonts.
 * I'm highly leaning towards second option. Would require format conversion though.
 */
class Font {
	public var fontName(default, null):String;
	public var fontStyle(default, null):FontStyle;
	public var fontType(default, null):FontType;
	public function new():Void {
		
	}
	public function hasGlyphs(v:String):Bool {
		return false;
	}
	public static function enumerateFonts(z:Bool = false):Array<Font> {
		return [];
	}
	public static function registerFont(v:Class<Dynamic>):Void {
		
	}
}
#end