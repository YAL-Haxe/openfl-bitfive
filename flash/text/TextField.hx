package flash.text;
import flash.display.IBitmapDrawable;
#if js
/**
 * Status: Implementation pending.
 * Included solely to avoid infinite errors.
 */
class TextField extends flash.display.InteractiveObject implements IBitmapDrawable {
	public var autoSize(default, set):String;
	public var antiAliasType:AntiAliasType;
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
	public var scrollV:Int;
	public var maxScrollV:Int;
	public var selectable(default, set):Bool;
	public var selectedText:String;
	public var selectionBeginIndex:Int;
	public var selectionEndIndex:Int;
	public var styleSheet:Dynamic;
	public var text(default, set):String = "";
	public var textColor:Int;
	public var textHeight(get, null):Float;
	public var textWidth(get, null):Float;
	public var type:String;
	public var wordWrap:Bool;
	//
	private var qFontStyle:String;
	private var qLineHeight:Float;
	//
	public function new() {
		super();
		var s = component.style;
		s.whiteSpace = "nowrap";
		s.overflow = "hidden";
		defaultTextFormat = new TextFormat("_serif", 16, 0);
		textColor = 0;
		wordWrap = false;
		width = height = 100;
	}
	//
	public function setTextFormat(v:TextFormat, ?f:Int, ?l:Int) {
		
	}
	//
	private function set_text(v:String):String {
		if (text != v) {
			text = v;
			if (component.innerText == null) {
				component.innerHTML = StringTools.replace(StringTools.htmlEscape(v), "\n", "<br>");
			} else component.innerText = v;
			var o = component.style, q:TextFormat = defaultTextFormat;
			qFontStyle = o.font = q.get_fontStyle();
			untyped o.lineHeight = (qLineHeight = q.size) + "px";
			o.color = flash.Lib.rgbf(q.color != null ? q.color : textColor, 1);
		}
		return v;
	}
	public function appendText(v:String):Void {
		
	}
	public function setSelection(v:Int, o:Int):Void {
		
	}
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?mtx:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		var q:TextFormat = defaultTextFormat;
		ctx.save();
		ctx.fillStyle = component.style.color;
		ctx.font = qFontStyle;
		ctx.textBaseline = "top";
		ctx.textAlign = "left";
		ctx.fillText(text, 0, 0);
		ctx.restore();
	}
	override private function get_width():Float {
		return qWidth != null ? qWidth : get_textWidth();
	}
	override private function get_height():Float {
		return qHeight != null ? qHeight : get_textHeight();
	}
	override private function set_width(v:Float):Float {
		if (qWidth != v) {
			component.style.width = (v != null ? v + "px" : "");
			qWidth = v;
		}
		return v;
	}
	override private function set_height(v:Float):Float {
		if (qHeight != v) {
			component.style.height = (v != null ? v + "px" : "");
			qHeight = v;
		}
		return v;
	}
	private function _measure_pre():js.html.DivElement {
		var o = flash.Lib.jsHelper(),
			s = o.style, q = component.style, i:Int;
		i = q.length; while (--i >= 0) untyped s[q[i]] = q[q[i]];
		o.innerHTML = component.innerHTML;
		return o;
	}
	private function _measure_post(o:js.html.DivElement):Void {
		var i:Int, s = o.style;
		i = s.length; while (--i >= 0) untyped s[s[i]] = "";
		o.innerHTML = "";
	}
	private function get_textWidth():Float {
		if (stage == null) {
			var o = _measure_pre(),
				r = o.clientWidth;
			_measure_post(o);
			return r;
		}
		return component.clientWidth;
	}
	private function get_textHeight():Float {
		if (stage == null) {
			var o = _measure_pre(),
				r = o.clientHeight;
			_measure_post(o);
			return r;
		}
		return component.clientHeight;
	}
	private function set_autoSize(v:String):String {
		if (autoSize != v) {
			if ((autoSize = v) != TextFieldAutoSize.NONE) width = height = null;
		}
		return v;
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