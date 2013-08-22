package flash.text;
import flash.display.IBitmapDrawable;
#if js
/**
 * Status: Implementation pending.
 * Included solely to avoid infinite errors.
 */
class TextField extends flash.display.InteractiveObject implements IBitmapDrawable {
	public var autoSize:String;
	public var background:Bool;
	public var backgroundColor:Int;
	public var border:Bool;
	public var borderColor:Int;
	public var caretIndex(default, null):Int;
	public var defaultTextFormat:TextFormat;
	public var displayAsPassword:Bool;
	public var embedFonts:Bool;
	public var htmlText:String;
	public var length(default, null):Int;
	public var maxChars:Int;
	public var multiline:Bool;
	public var selectable(default, set):Bool;
	public var selectedText:String;
	public var selectionBeginIndex:Int;
	public var selectionEndIndex:Int;
	public var styleSheet:Dynamic;
	public var text(default, set):String;
	public var textColor:Int;
	public var textHeight(get, null):Float;
	public var textWidth(get, null):Float;
	public var type:String;
	public var wordWrap:Bool;
	//
	
	//
	public function new() {
		super();
		component.style.whiteSpace = 'nowrap';
		defaultTextFormat = new TextFormat("_sans", 16, 0);
	}
	//
	public function setTextFormat(v:TextFormat, ?f:Int, ?l:Int) {
		
	}
	//
	private function set_text(v:String):String {
		if (text != v) {
			text = v;
			if (component.innerText == null) {
				component.innerHTML = StringTools.htmlEscape(v);
			} else component.innerText = v;
			var o = component.style, q:TextFormat = defaultTextFormat;
			o.fontFamily = translateFont(q.font);
			o.color = flash.Lib.rgbf(q.color, 1);
			o.fontSize = q.size + "px";
		}
		return v;
	}
	private function translateFont(n:String):String {
		switch (n) {
		case "_sans": return "sans-serif";
		case "_serif": return "sans";
		case "_typewriter": return "monospace";
		default:
			if (n == null) return "sans-serif";
			return n;
		}
	}
	public function appendText(v:String):Void {
		
	}
	public function setSelection(v:Int, o:Int):Void {
		
	}
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?mtx:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		
	}
	override private function get_width():Float {
		return qWidth != null ? qWidth : get_textWidth();
	}
	override private function get_height():Float {
		return qHeight != null ? qHeight : get_textHeight();
	}
	private function get_textWidth():Float {
		return component.clientWidth;
	}
	private function get_textHeight():Float {
		return component.clientHeight;
	}
	private function set_selectable(v:Bool):Bool {
		if (selectable != v) {
			var s = component.style,
				q = (selectable = v) ? null : 'none',
				u = 'user-select', z = null;
			s.setProperty('-webkit-touch-callout', q, z);
			s.setProperty('-webkit-' + u, q, z);
			s.setProperty('-khtml-' + u, q, z);
			s.setProperty('-moz-' + u, q, z);
			s.setProperty('-ms-' + u, q, z);
			s.setProperty(u, q, z);
			s.setProperty("cursor", v ? "" : "default", z);
			component.setAttribute('unselectable', v ? null : 'on');
		}
		return v;
	}
}
#end