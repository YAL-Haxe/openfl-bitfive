package flash.text;
#if js
import flash.display.IBitmapDrawable;
import js.html.Element;
import js.html.TextAreaElement;
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
	public var multiline(default, set):Bool;
	public var scrollV:Int;
	public var maxScrollV:Int;
	public var selectable(default, set):Bool;
	public var selectedText(get, null):String;
	public var selectionBeginIndex(get, set):Int;
	public var selectionEndIndex(get, set):Int;
	public var styleSheet:Dynamic;
	public var text(get, set):String = "";
	public var textColor:Int;
	public var textHeight(get, null):Float;
	public var textWidth(get, null):Float;
	public var type(default, set):String = "DYNAMIC";
	public var wordWrap:Bool;
	//
	private var qText:String = "";
	private var qFontStyle:String;
	private var qLineHeight:Float;
	private var qTextArea:TextAreaElement;
	private var qEditable:Bool;
	//
	public function new() {
		super();
		var s = component.style;
		s.whiteSpace = "nowrap";
		s.overflow = "hidden";
		//
		defaultTextFormat = new TextFormat("_serif", 16, 0);
		textColor = 0;
		wordWrap = qEditable = false;
		width = height = 100;
	}
	//
	public function setTextFormat(v:TextFormat, ?f:Int, ?l:Int) {
		
	}
	//
	private function get_text():String {
		return qEditable ? qTextArea.value : qText;
	}
	private function set_text(v:String):String {
		if (text != v) {
			var o, q:TextFormat = defaultTextFormat, z = qEditable;
			qText = v;
			if (z) {
				qTextArea.value = v;
			} else if (component.innerText == null) {
				component.innerHTML = StringTools.replace(StringTools.htmlEscape(v), "\n", "<br>");
			} else component.innerText = v;
			// update according styles:
			o = (z ? qTextArea : component).style;
			qFontStyle = o.font = q.get_fontStyle();
			untyped o.lineHeight = (qLineHeight = Std.int(q.size * 1.25)) + "px";
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
			var o = (v != null ? v + "px" : "");
			component.style.width = o;
			if (qEditable) qTextArea.style.width = o;
			qWidth = v;
		}
		return v;
	}
	override private function set_height(v:Float):Float {
		if (qHeight != v) {
			var o = (v != null ? v + "px" : "");
			component.style.height = o;
			if (qEditable) qTextArea.style.height = o;
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
	private function set_type(v:String):String {
		// Currently will cause event listener loss.
		// Is someone crazy enough to switch type mid-run though?
		var z:Bool = (v == "INPUT"), o:TextField = this, c:Element, e:TextAreaElement, q:Dynamic,
			t:Dynamic, text:String, f:Float;
		if (z != o.qEditable) {
			c = o.component;
			text = o.text; o.text = text != "" ? "" : " ";
			if (o.qEditable = z) {
				// create input node:
				c.appendChild(e = untyped document.createElement(multiline ? "textarea" : "input"));
				e.value = text + " ";
				t = e.style;
				t.border = "0";
				t.background = "transparent";
				if ((f = o.qWidth) != null) t.width = f + "px";
				if ((f = o.qHeight) != null) t.height = f + "px";
				o.qTextArea = e;
			} else {
				// destroy input node:
				c.removeChild(o.qTextArea);
				o.qTextArea = null;
			}
			o.text = text;
		}
		return v;
	}
	private function set_multiline(v:Bool):Bool {
		if (multiline != v) {
			multiline = v;
			if (qEditable) {
				type = "DYNAMIC";
				type = "INPUT";
			}
		}
		return v;
	}
	private function set_selectable(v:Bool):Bool {
		if (selectable != v) {
			var s = component.style,
				q = (selectable = v) ? null : 'none',
				u = 'user-select', z = null;
			s.setProperty('-webkit-touch-callout', q, z); // mobile webkit
			s.setProperty('-webkit-' + u, q, z);
			s.setProperty('-khtml-' + u, q, z); 
			s.setProperty('-moz-' + u, q, z);
			s.setProperty('-ms-' + u, q, z); // newer IEs
			s.setProperty(u, q, z);
			s.setProperty("cursor", v ? "" : "default", z);
			component.setAttribute('unselectable', v ? null : 'on'); // older IEs
		}
		return v;
	}
	override public function giveFocus():Void {
		(qEditable ? qTextArea : component).focus();
	}
	// selection:
	private function get_selectionBeginIndex():Int return qEditable ? qTextArea.selectionStart : 0;
	private function get_selectionEndIndex():Int return qEditable ? qTextArea.selectionEnd : 0;
	private function set_selectionBeginIndex(v:Int):Int {
		if (qEditable && selectionBeginIndex != v) {
			qTextArea.selectionStart = v;
		}
		return v;
	}
	private function set_selectionEndIndex(v:Int):Int {
		if (qEditable && selectionEndIndex != v) {
			qTextArea.selectionEnd = v;
		}
		return v;
	}
	private function get_selectedText():String {
		var a:Int = qTextArea.selectionStart,
			b:Int = qTextArea.selectionEnd,
			c:Int;
		if (b < a) { c = a; a = b; b = c; }
		return qEditable ? qTextArea.value.substring(a, b) : null;
	}
	// event target overrides:
	override public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, weak:Bool = false):Void {
		var o = component;
		if (qEditable) component = qTextArea;
		super.addEventListener(type, listener, useCapture, priority, weak);
		if (qEditable) component = o;
	}
	override public function removeEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, weak:Bool = false):Void {
		var o = component;
		if (qEditable) component = qTextArea;
		super.removeEventListener(type, listener, useCapture, priority, weak);
		if (qEditable) component = o;
	}
}
#end