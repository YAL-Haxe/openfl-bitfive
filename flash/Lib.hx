package flash;
#if js
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import js.Browser;
import js.html.CanvasElement;
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
	//
	static function __init__() {
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
		Browser.window.open(url.url, target);
	}
	//
	public static function jsNode(o:String):Element {
		var r:Element = Browser.document.createElement(o);
		r.style.position = 'absolute';
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
			Browser.document.body.appendChild((qStage = new Stage()).component);
		}
		return qStage;
	}
	// Utilities
	public static function requestAnimationFrame(handler:Dynamic) {
		untyped window.reqAnimFrame(handler);
	}
	public static function schedule(m:Void->Void):Void {
		schList[schLength++] = m;
	}
	/** Forms an RGBA string from 32-bit color integer */
	public static function rgba(color:Int):String {
		untyped { return 'rgba(' + ((color >> 16) & 0xFF)
			+ ',' + ((color >> 8) & 0xFF)
			+ ',' + (color & 0xFF)
			+ ',' + (((color >> 24) & 0xFF) / 255).toFixed(4)
			+ ')';
		}
	}
	/** Forms an RGBA string from 24-bit color and alpha value */
	public static function rgbf(color:Int, alpha:Float):String {
		untyped return "rgba(" + ((color >> 16) & 255)
			+ "," + ((color >> 8) & 255)
			+ "," + (color & 255)
			+ "," + alpha.toFixed(4) + ")";
	}
	/** Strictly JavaScript-specific cast for leaving decision to browser. */
	@:extern public static inline function bool(v:Dynamic):Bool {
		return cast v;
	}
}
#end