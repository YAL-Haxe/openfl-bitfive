package flash.net;
import flash.Lib;
#if js
class URLVariables implements Dynamic {
	//
	public function new(?o:String) {
		if (o != null) decode(o);
	}
	//
	public function decode(s:String):Void {
		//
		inline function _arrayOfString(v:Dynamic):Array<String> return cast v;
		//
		var o:Int = 0, i:Int = -1, l:Int = s.length, e:Int = 0, k:String, v:String, c:Dynamic;
		while (o < l) {
			// find next locations of "&" and "=":
			i = s.indexOf("&", o);
			if (i < 0) i = l;
			e = s.indexOf("=", o);
			// key-value pairs must contain the equals "=" sign:
			if (e == -1 || e > i) Lib.error(2101, "Error #2101: The String passed to URLVariables.decode() must be a URL-encoded query string containing name/value pairs.");
			// get key-value:
			k = s.substring(o, e);
			v = s.substring(e + 1, i);
			// determine new value:
			if (Reflect.hasField(this, k)) {
				// flash behaviour: values are stacked into arrays
				c = Reflect.field(this, k);
				if (Std.is(c, Array)) {
					_arrayOfString(c).push(v);
				} else c = [c, v];
			} else c = v;
			// store and proceed:
			Reflect.setField(this, k, c);
			o = i + 1;
		}
	}
	//
	public function toString():String {
		//
		inline function _arrayOfString(v:Dynamic):Array<String> return cast v;
		//
		var r:String = "",
			o:Array<String> = Reflect.fields(this),
			i:Int = -1, l:Int = o.length, k:String, v:Dynamic;
		while (++i < l) {
			if (i > 0) r += "&";
			r += StringTools.urlEncode(k = o[i]) + "=";
			if (Std.is(v = Reflect.field(this, k), Array)) {
				r += _arrayOfString(v).join('&$k=');
			} else r += Std.string(v);
		}
		return r;
	}
}
#end
