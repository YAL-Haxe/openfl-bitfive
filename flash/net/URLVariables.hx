package flash.net;
#if js
class URLVariables implements Dynamic {
	//
	public function new(inEncoded:String = null) {
		
		if (inEncoded != null) {
			
			decode(inEncoded);
			
		}
		
	}
	//
	public function decode(inVars:String):Void {
		// todo: possibly get rid of ridiculous use of arrays here.
		var fields = Reflect.fields(this);
		
		for (f in fields) {
			
			Reflect.deleteField(this, f);
			
		}
		
		var fields = inVars.split(";").join("&").split("&");
		
		for (f in fields) {
			
			var eq = f.indexOf("=");
			
			if (eq > 0) {
				
				Reflect.setField(this, StringTools.urlDecode(f.substr(0, eq)), StringTools.urlDecode(f.substr(eq + 1)));
				
			} else if (eq != 0) {
				
				Reflect.setField(this, StringTools.urlDecode(f), "");
				
			}
			
		}
		
	}
	//
	public function toString():String {
		var r:String = "",
			o:Array<String> = Reflect.fields(this),
			i:Int = 0;
		for (f in o) {
			r += ((i++ != 0) ? "&" : "") + StringTools.urlEncode(f)
			+ "=" + StringTools.urlEncode(Reflect.field(this, f));
		}
		return r;
	}
	
	
}


#end