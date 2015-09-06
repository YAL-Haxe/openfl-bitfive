package openfl.bitfive;

import js.Browser.document;
import js.html.CanvasElement;
import js.html.Element;
import js.html.InputElement;
using openfl.bitfive.StyleTools;

class NodeTools {
	public static function createElement(tag:String):Element {
		var r = document.createElement(tag);
		r.style.position = "absolute";
		return r;
	}
	public static function createInputElement():InputElement {
		var r = document.createInputElement();
		var r_style = r.style;
		r_style.position = "absolute";
		// Remove the "outline" shown around the focused fields on some browsers:
		r_style.outline = "none";
		return r;
	}
	public static function createCanvasElement():CanvasElement {
		var r = document.createCanvasElement();
		var r_style = r.style;
		r_style.position = "absolute";
		// disable canvas selection indication from mouse/touch swiping:
		r_style.setPropertyNp("-webkit-touch-callout", "none");
		r_style.setProperties("user-select", "none", 0x3F);
		return r;
	}
}