package flash.text;
#if js
import flash.display.IBitmapDrawable;
import flash.Lib;
import js.html.DivElement;
import js.html.Element;
import js.html.TextAreaElement;
import js.html.CSSStyleDeclaration;
/**
 * Things mostly work, except when they do not.
 * @author YellowAfterlife
 */
class TextField extends flash.display.InteractiveObject implements IBitmapDrawable {
	public var autoSize(default, set):String;
	public var antiAliasType:AntiAliasType;
	public var background(default, set):Bool;
	public var backgroundColor(default, set):Int = 0xffffff;
	public var border(default, set):Bool = false;
	public var borderColor(default, set):Int = 0x0;
	public var caretIndex(default, null):Int;
	public var defaultTextFormat(get, set):TextFormat;
	public var displayAsPassword:Bool;
	public var embedFonts:Bool;
	public var htmlText:String;
	public var length(get, null):Int;
	public var maxChars(default, set):Int = 0;
	public var multiline(default, set):Bool = false;
	public var scrollH:Int;
	public var scrollV:Int;
	public var maxScrollH:Int;
	public var maxScrollV:Int;
	public var numLines(get, null):Int;
	public var selectable(default, set):Bool = true;
	public var selectedText(get, null):String;
	public var selectionBeginIndex(get, set):Int;
	public var selectionEndIndex(get, set):Int;
	public var text(get, set):String;
	public var textColor(get, set):Int;
	public var textHeight(get, null):Float;
	public var textWidth(get, null):Float;
	public var type(default, set):String = "DYNAMIC";
	public var wordWrap(default, set):Bool = false;
	//{ Internal
		/// autoSize index (-1: none, 0: left, 1: center, 2: right)
		@:noCompletion private var __autoSize:Int = -1;
		/// Current text. If __editable is set, field value is read instead.
		@:noCompletion private var __text:String = "";
		/// defaultTextFormat value. Copies are returned on main field access.
		@:noCompletion private var __textFormat:TextFormat;
		/// Whether __textFormat is up to date.
		@:noCompletion private var __textFormatSync:Bool;		
		/// Cached CSS `font` property.
		@:noCompletion private var __fontStyle:String;
		/// Whether text field is editable.
		@:noCompletion private var __editable:Bool = false;
		/// Editable field element. Can be either `input` or `textarea` actually.
		@:noCompletion private var __field:TextAreaElement;
	//}
	private static inline var padding:Float = 1.5;
	private static inline var padding2:Float = 3.0;
	//
	public function new() {
		super();
		var s:CSSStyleDeclaration = component.style;
		s.whiteSpace = "nowrap";
		s.overflow = "hidden";
		s.padding = padding + "px";
		//
		//qTextFormat = new TextFormat("_serif", 16, 0);
		__textFormat = new TextFormat(
			"Times New Roman", 12, 0x000000,
			false, false, false, "", "",
			TextFormatAlign.LEFT, 0, 0, 0, 0);
		__width = 100;
		__height = 100;
		__applySize(3);
		__applyTextFormat();
	}
	//{ Apperance
	private function set_background(v:Bool) {
		if (background != v) {
			var s = component.style;
			if (background = v) {
				s.background = Lib.rgbf(backgroundColor, 1);
			} else s.background = "";
		}
		return v;
	}
	private function set_backgroundColor(c:Int) {
		if (backgroundColor != c) {
			backgroundColor = c;
			if (background) component.style.background = Lib.rgbf(c, 1);
		}
		return c;
	}
	private function set_border(v:Bool) {
		if (border != v) {
			var s = component.style;
			if (border = v) {
				s.border = "1px solid " + Lib.rgbf(borderColor, 1);
			} else s.border = "0";
			__applySize(3);
		}
		return v;
	}
	private function set_borderColor(c:Int) {
		if (borderColor != c) {
			borderColor = c;
			if (border) component.style.border = "1px solid " + Lib.rgbf(c, 1);
		}
		return c;
	}
	private function get_defaultTextFormat():TextFormat {
		return __textFormat.clone();
	}
	private function set_defaultTextFormat(f:TextFormat):TextFormat {
		// defaultTextFormat updates take place next time the text is changed.
		__textFormat.merge(f);
		__textFormatSync = false;
		return f;
	}
	private function get_textColor():UInt {
		return __textFormat.color;
	}
	private function set_textColor(c:UInt):UInt {
		// Unlike defaultTextFormat changes, textColor is applied instantly by Flash.
		__textFormat.color = c;
		__applyTextFormat();
		return c;
	}
	public function setTextFormat(v:TextFormat, ?f:Int, ?l:Int) {
		// Soon[-ish].
	}
	//}
	//{
	private function __applyType(v:Bool) {
		var c:Element = component;
		var s:String = text;
		if (__editable = v) {
			var e:TextAreaElement = cast Lib.jsNode(multiline ? "textarea" : "input");
			e.value = s;
			e.maxLength = maxChars > 0 ? maxChars : 2147483647;
			var s:CSSStyleDeclaration = e.style;
			s.border = "0";
			s.padding = "0";
			s.background = "transparent";
			c.appendChild(__field = e);
		} else {
			c.removeChild(__field);
			__field = null;
		}
	}
	private function __applyTextFormat() {
		__textFormatSync = true;
		var f:TextFormat = __textFormat;
		var s:CSSStyleDeclaration = (__editable ? __field : component).style;
		__fontStyle = s.font = f.get_fontStyle();
		s.lineHeight = "1.25";
		s.textAlign = f.align;
		s.fontWeight = f.bold ? "bold" : "";
		s.fontStyle = f.italic ? "italic" : "";
		s.textDecoration = f.underline ? "underline" : "";
		s.color = Lib.rgbf(f.color, 1);
	}
	private function __applyText(s:String) {
		__text = s;
		if (__editable) {
			__field.value = s;
		} else if (untyped component.innerText == null) {
			component.innerHTML = StringTools.replace(StringTools.htmlEscape(s), "\n", "<br>");
		} else untyped component.innerText = s;
		__applyAutoSize();
	}
	/**
	 * Updates component dimensions.
	 * @param	m	mode flags (1: width, 2: height)
	 */
	private function __applySize(m:Int) {
		var s:CSSStyleDeclaration = component.style;
		var e:Bool = __editable;
		var fs:CSSStyleDeclaration = e ? __field.style : null;
		// for (n in [1, 2]):
		var n:Int = 1;
		while (n < 4) {
			if ((m & n) != 0) {
				var f:Float = (n == 1) ? __width : __height;
				// use textfield's width for single-line autosized field:
				if (n == 1 && __autoSize >= 0 && !wordWrap) f = null;
				// determine CSS value:
				var v:String;
				if (f != null) {
					if (border) f -= 1;
					f -= padding2;
					v = f + "px";
				} else v = "";
				// set:
				if (n == 1) {
					s.width = v;
					if (e) fs.width = v;
				} else {
					s.height = v;
					if (e) fs.height = v;
				}
			}
			n <<= 1;
		}
	}
	//}
	private inline function get_length():Int return text.length;
	private function get_text():String {
		return __editable ? __field.value : __text;
	}
	private function set_text(s:String):String {
		if (text != s) __applyText(s);
		if (!__textFormatSync) __applyTextFormat();
		return s;
	}
	public inline function appendText(s:String):Void {
		text += s;
	}
	public function setSelection(v:Int, o:Int):Void {
		if (__editable) {
			__field.setSelectionRange(v, o);
		}
	}
	public function drawToSurface(cnv:js.html.CanvasElement, ctx:js.html.CanvasRenderingContext2D,
	?mtx:flash.geom.Matrix, ?ctr:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode,
	?clipRect:flash.geom.Rectangle, ?smoothing:Bool):Void {
		// Not that good at the moment.
		ctx.save();
		ctx.fillStyle = component.style.color;
		ctx.font = __fontStyle;
		ctx.textBaseline = "top";
		ctx.textAlign = __textFormat.align;
		ctx.fillText(text, 0, 0);
		ctx.restore();
	}
	//{ Component size
	override private function get_width():Float {
		if (__autoSize < 0) {
			return __width;
		} else {
			return get_textWidth();
		}
	}
	override private function get_height():Float {
		if (__autoSize < 0) {
			return __height;
		} else {
			// todo: consider border and 1.5px pad
			return get_textHeight();
		}
	}
	override private function set_width(v:Float):Float {
		if (__width != v) {
			__width = v;
			__applySize(1);
		}
		return v;
	}
	override private function set_height(v:Float):Float {
		if (__height != v) {
			__height = v;
			__applySize(2);
		}
		return v;
	}
	//}
	//{ Text measuring
	private function __measurePre():DivElement {
		// Copies style and text into helper element
		var o:DivElement = Lib.jsHelper();
		o.setAttribute("style", component.getAttribute("style"));
		// strip styles that interfere:
		var s = o.style;
		if (!wordWrap) s.width = "";
		s.height = "";
		s.paddingTop = "";
		s.paddingBottom = "";
		s.borderTop = "";
		s.borderBottom = "";
		//
		o.innerHTML = component.innerHTML;
		return o;
	}
	private function __measurePost(o:DivElement):Void {
		// Clears previously set syle and text on given element.
		o.setAttribute("style", "");
		o.innerHTML = "";
	}
	private function get_textWidth():Float {
		if (stage == null) {
			var o = __measurePre(),
				r = o.clientWidth;
			__measurePost(o);
			return r;
		}
		return component.clientWidth;
	}
	private function get_textHeight():Float {
		if (stage == null) {
			var o = __measurePre(),
				r = o.clientHeight;
			__measurePost(o);
			return r;
		}
		return component.clientHeight;
	}
	private function get_numLines():Int {
		var n = Math.round(textHeight / (defaultTextFormat.size * 1.25));
		return n < 1 ? 1 : n;
	}
	//}
	// Meta
	private function __applyAutoSize() {
		var f = __autoSize;
		var s = component.style;
		if (f >= 0 && !__editable) {
			if (f > 0) {
				s.left = ((__width - get_textWidth()) * f / 2) + "px";
			} else s.left = "";
			if (!wordWrap) s.width = "";
			s.height = "";
		} else {
			s.left = "";
			__applySize(3);
		}
	}
	private function set_autoSize(v:String):String {
		if (autoSize != v) {
			var i:Int;
			switch (autoSize = v) {
			#if (haxe_ver >= 3.2)
			// todo: bugs??
			case "LEFT": i = 0;
			case "CENTER": i = 1;
			case "RIGHT": i = 2;
			#else
			case TextFieldAutoSize.LEFT: i = 0;
			case TextFieldAutoSize.CENTER: i = 1;
			case TextFieldAutoSize.RIGHT: i = 2;
			#end
			default: i = -1;
			}
			__autoSize = i;
			__applyAutoSize();
		}
		return v;
	}
	private function set_type(s:String):String {
		// Currently will cause event listener loss.
		// Is someone crazy enough to switch type mid-run though?
		var v:Bool = (s == TextFieldType.INPUT);
		if (v != __editable) __applyType(v);
		return s;
	}
	private function set_multiline(v:Bool):Bool {
		if (multiline != v) {
			multiline = v;
			if (__editable) __applyType(true);
		}
		return v;
	}
	private function set_maxChars(v:Int):Int {
		if (maxChars != v) {
			maxChars = v;
			if (__editable) __field.maxLength = v > 0 ? v : 2147483647;
		}
		return v;
	}
	private function set_selectable(v:Bool):Bool {
		if (selectable != v) {
			var s = component.style,
				q = (selectable = v) ? null : "none";
			Lib.setCSSProperty(s, "-webkit-touch-callout", q); // mobile webkit
			Lib.setCSSProperty(s, "cursor", v ? "" : "default");
			Lib.setCSSProperties(s, "user-select", q, 0x2F);
			// older IEs. They don't support HTML5 though, so why would this even be here...
			// component.setAttribute("unselectable", v ? null : "on"); // older IEs
		}
		return v;
	}
	private function set_wordWrap(v:Bool):Bool {
		if (wordWrap != v) {
			var s = (wordWrap = v) ? "normal" : "nowrap";
			component.style.whiteSpace = s;
			if (__editable) __field.style.whiteSpace = s;
		}
		return v;
	}
	override public function giveFocus():Void {
		(__editable ? __field : component).focus();
	}
	// selection:
	private function get_selectionBeginIndex():Int return __editable ? __field.selectionStart : 0;
	private function get_selectionEndIndex():Int return __editable ? __field.selectionEnd : 0;
	private function set_selectionBeginIndex(v:Int):Int {
		if (__editable && __field.selectionStart != v) {
			__field.selectionStart = v;
		}
		return v;
	}
	private function set_selectionEndIndex(v:Int):Int {
		if (__editable && __field.selectionEnd != v) {
			__field.selectionEnd = v;
		}
		return v;
	}
	private function get_selectedText():String {
		if (__editable) {
			var a:Int = __field.selectionStart,
				b:Int = __field.selectionEnd,
				c:Int;
			if (b < a) { c = a; a = b; b = c; }
			return __field.value.substring(a, b);
		}
		return null;
	}
	// event target overrides:
	override public function hitTestLocal(x:Float, y:Float, p:Bool, ?v:Bool):Bool {
		return hitTestVisible(v) && x >= 0 && y >= 0 && x < width && y < height;
	}
	override public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, weak:Bool = false):Void {
		var o = component;
		if (__editable) component = __field;
		super.addEventListener(type, listener, useCapture, priority, weak);
		if (__editable) component = o;
	}
	override public function removeEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false):Void {
		var o = component;
		if (__editable) component = __field;
		super.removeEventListener(type, listener, useCapture);
		if (__editable) component = o;
	}
}
#end