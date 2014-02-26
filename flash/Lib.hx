package flash;
#if js
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import js.html.CanvasElement;
import js.html.CSSStyleDeclaration;
import js.html.DivElement;
import js.html.Element;

class Lib {
	public static var current(get, null):MovieClip;
	public static var stage(get, null):Stage;
	//
	private static var qCurrent:MovieClip;
	private static var qStage:Stage;
	private static var qTimeStamp:Float = untyped __js__("Date.now() + 0");
	private static var qHelper:DivElement;
	public static var mouseX:Float = 0;
	public static var mouseY:Float = 0;
	//
	public static var schList:Array<Void->Void>;
	public static var schLength:Int;
	public static var mobile:Bool;
	//
	static function __init__() __init();
	static function __init() {
		var o:Dynamic;
		//
		schList = [];
		schLength = 0;
		// bind a "delay" method:
		untyped window.reqAnimFrame =
				window.requestAnimationFrame ||
				window.webkitRequestAnimationFrame ||
				window.mozRequestAnimationFrame ||
				window.oRequestAnimationFrame ||
				window.msRequestAnimationFrame ||
				function (o) {
					untyped window.setTimeout(o, 700 / Lib.frameRate, null);
				};
		// possibly bulky mobile browser detection (from detectmobilebrowsers.com):
		o = untyped navigator.userAgent || navigator.vendor || window.opera;
		mobile = untyped __js__("/(android|bb\\d+|meego).+mobile|avantgo|bada\\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od|ad)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i").test(o)
		|| __js__("/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\\-(n|u)|c55\\/|capi|ccwa|cdm\\-|cell|chtm|cldc|cmd\\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\\-s|devi|dica|dmob|do(c|p)o|ds(12|\\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\\-|_)|g1 u|g560|gene|gf\\-5|g\\-mo|go(\\.w|od)|gr(ad|un)|haie|hcit|hd\\-(m|p|t)|hei\\-|hi(pt|ta)|hp( i|ip)|hs\\-c|ht(c(\\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\\-(20|go|ma)|i230|iac( |\\-|\\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\\/)|klon|kpt |kwc\\-|kyo(c|k)|le(no|xi)|lg( g|\\/(k|l|u)|50|54|\\-[a-w])|libw|lynx|m1\\-w|m3ga|m50\\/|ma(te|ui|xo)|mc(01|21|ca)|m\\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\\-2|po(ck|rt|se)|prox|psio|pt\\-g|qa\\-a|qc(07|12|21|32|60|\\-[2-7]|i\\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\\-|oo|p\\-)|sdk\\/|se(c(\\-|0|1)|47|mc|nd|ri)|sgh\\-|shar|sie(\\-|m)|sk\\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\\-|v\\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\\-|tdg\\-|tel(i|m)|tim\\-|t\\-mo|to(pl|sh)|ts(70|m\\-|m3|m5)|tx\\-9|up(\\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\\-|your|zeto|zte\\-/i").test(o.substr(0,4));
	}
	@:extern public static inline function trace(v:Dynamic):Void {
		#if debug
		untyped if (console) console.log(v);
		#end
	}
	public static function getTimer():Int {
		return untyped ~~(__js__("Date.now()") - qTimeStamp);
	}
	public static function getURL(url:flash.net.URLRequest, ?target:String) {
		untyped window.open(url.url, target);
	}
	//
	public static function jsNode(o:String):Element {
		var r:Element = untyped document.createElement(o), s:js.html.CSSStyleDeclaration = r.style;
		s.position = 'absolute';
		switch (o) {
		case "canvas":
			// Disable accidental highlights (mostly in Firefox) for imagery
			Lib.setCSSProperty(s, "-webkit-touch-callout", "none"); // mobile webkit
			Lib.setCSSProperties(s, "user-select", "none", 0x2F);
		case "input", "textarea":
			// counter Webkit focus outline
			s.outline = "none";
		}
		return r;
	}
	public static function jsDiv():DivElement {
		return cast jsNode("div");
	}
	public static function jsCanvas():CanvasElement {
		return cast jsNode("canvas");
	}
	//
	public static function jsHelper():DivElement {
		if (qHelper == null) {
			var o = jsDiv();
			get_stage().component.appendChild(o);
			o.style.visibility = "hidden";
			#if debug
				o.setAttribute("node", "Lib.jsHelper");
			#end
			o.appendChild(qHelper = jsDiv());
		}
		return qHelper;
	}
	private static function get_current():MovieClip {
		if (qCurrent == null) {
			get_stage().addChild(qCurrent = new MovieClip());
		}
		return qCurrent;
	}
	private static function get_stage():Stage {
		if (qStage == null) {
			untyped document.body.appendChild((qStage = new Stage()).component);
		}
		return qStage;
	}
	
	// Utilities
	
	/// Gives you a new error! Yay! ... kind of.
	@:extern public static inline function error(id:Int, msg:String):Void {
		#if debug
		throw new flash.errors.Error(msg, id);
		#else
		throw id;
		#end
	}
	
	/// Mapping for earlier set method
	public static function requestAnimationFrame(handler:Dynamic) {
		untyped window.reqAnimFrame(handler);
	}
	
	/// Schedules function for execution at next ENTER_FRAME
	public static function schedule(m:Void->Void):Void {
		schList[schLength++] = m;
	}
	
	/// For parameter and default value handling, returns value or otherwise.
	@:extern public static inline function nz(value:Dynamic, otherwise:Dynamic):Dynamic {
		return (value != null ? value : otherwise);
	}
	
	/// Forms an RGBA string from 32-bit color integer
	public static function rgba(color:Int):String {
		untyped return 'rgba(' + ((color >> 16) & 0xFF)
			+ ',' + ((color >> 8) & 0xFF)
			+ ',' + (color & 0xFF)
			+ ',' + (((color >> 24) & 0xFF) / 255).toFixed(4)
			+ ')';
	}
	
	/// Forms an RGBA string from 24-bit color and alpha value
	public static function rgbf(color:Int, alpha:Float):String {
		untyped return "rgba(" + ((color >> 16) & 255)
			+ "," + ((color >> 8) & 255)
			+ "," + (color & 255)
			+ "," + alpha.toFixed(4) + ")";
	}
	
	/**
	 * Sets multiple properties in a style object with according prefixes.
	 * @param	o	CSSStyleDeclaration node
	 * @param	k	Property name
	 * @param	v	Value
	 * @param	?f	Flags (1:np, 2:webkit, 4:moz, 8:ms, 16:o, 32:khtml)
	 */
	public static function setCSSProperties(o:CSSStyleDeclaration, k:String, v:String, ?f:Int):Void {
		if (!bool(f)) f = 0x1f;
		if (bool(f &  1)) setCSSProperty(o, k, v);
		if (bool(f &  2)) setCSSProperty(o, k, "-webkit-" + v);
		if (bool(f &  4)) setCSSProperty(o, k, "-moz-" + v);
		if (bool(f &  8)) setCSSProperty(o, k, "-ms-" + v);
		if (bool(f & 16)) setCSSProperty(o, k, "-o-" + v);
		if (bool(f & 32)) setCSSProperty(o, k, "-khtml-" + v);
	}
	
	/**
	 * Shortcut for a two-argument .setProperty, since third argument is actually optional.
	 * @param	o	Style object
	 * @param	k	Property name
	 * @param	?v	Property value (optional)
	 */
	@:extern public static inline function setCSSProperty(o:CSSStyleDeclaration, k:String, ?v:String):Void {
		inline function _(q:CSSStyleDeclaration):Dynamic return cast q;
		untyped _(o).setProperty(k, v);
	}
	
	/// Strictly JavaScript-specific cast for leaving decision to browser.
	@:extern public static inline function bool(v:Dynamic):Bool {
		return cast v;
	}
}
#end