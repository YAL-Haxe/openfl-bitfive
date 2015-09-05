package flash.text;
#if js
import flash.utils.UInt;

class TextFormat {
	
	public var align:TextFormatAlign;
	public var blockIndent:Null<Float>;
	public var bold:Bool;
	public var bullet:Bool;
	public var color:Null<UInt>;
	public var font:String;
	public var indent:Null<Float>;
	public var italic:Bool;
	public var kerning:Bool;
	public var leading:Null<Int>;
	public var leftMargin:Null<Float>;
	public var letterSpacing:Null<Float>;
	public var rightMargin:Null<Float>;
	public var size:Null<Float>;
	public var tabStops:Array<Int>;
	public var target:String;
	public var underline:Bool;
	public var url:String;
	
	public function new(?font:String, ?size:Float, ?color:UInt,
	?bold:Bool, ?italic:Bool, ?underline:Bool, ?url:String, ?target:String,
	?align:TextFormatAlign, ?leftMargin:Float, ?rightMargin:Float,
	?indent:Float, ?leading:Int) {
		this.font = font;
		this.size = size;
		this.color = color;
		this.bold = bold;
		this.italic = italic;
		this.underline = underline;
		this.url = url;
		this.target = target;
		this.align = align;
		this.leftMargin = leftMargin;
		this.rightMargin = rightMargin;
		this.indent = indent;
		this.leading = leading;
		this.tabStops = [];
	}
	
	public function merge(f:TextFormat) {
		if (f.font != null) font = f.font;
		if (f.size != null) size = f.size;
		if (f.color != null) color = f.color;
		if (f.bold != null) bold = f.bold;
		if (f.italic != null) italic = f.italic;
		if (f.underline != null) underline = f.underline;
		if (f.url != null) url = f.url;
		if (f.target != null) target = f.target;
		if (f.align != null) align = f.align;
		if (f.leftMargin != null) leftMargin = f.leftMargin;
		if (f.rightMargin != null) rightMargin = f.rightMargin;
		if (f.indent != null) indent = f.indent;
		if (f.leading != null) leading = f.leading;
		if (f.blockIndent != null) blockIndent = f.blockIndent;
		if (f.bullet != null) bullet = f.bullet;
		if (f.kerning != null) kerning = f.kerning;
		if (f.letterSpacing != null) letterSpacing = f.letterSpacing;
		if (f.tabStops != null) tabStops = f.tabStops;
	}
	
	public function clone():TextFormat {
		var r = new TextFormat(
			font, size, color, bold, italic, underline, url, target,
			align, leftMargin, rightMargin, indent, leading);
		r.blockIndent = blockIndent;
		r.bullet = bullet;
		r.indent = indent;
		r.kerning = kerning;
		r.letterSpacing = letterSpacing;
		r.tabStops = tabStops.slice(0);
		return r;
	}
	
	public function get_fontStyle():String {
		return (bold ? "bold " : "") + (italic ? "italic " : "")
			+ size + "px " + translateFont(font);
	}
	
	public static function translateFont(n:String):String {
		switch (n) {
		case "_sans": return "sans-serif";
		case "_serif": return "serif";
		case "_typewriter": return "monospace";
		default:
			if (n == null) return "sans-serif";
			return n;
		}
	}
}


#end