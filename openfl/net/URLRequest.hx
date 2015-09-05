package flash.net;

#if js

import flash.utils.ByteArray;

class URLRequest {
	//
	public var contentType:String;
	public var data:Dynamic;
	public var method:String;
	public var requestHeaders:Array<URLRequestHeader>;
	public var url:String;
	//
	public function new(inURL:String = null) {
		if (inURL != null) url = inURL;
		//
		requestHeaders = [];
		method = URLRequestMethod.GET;
		contentType = null; // "application/x-www-form-urlencoded";
	}
	
	
	public function formatRequestHeaders():Array<URLRequestHeader> {
		
		var res = requestHeaders;
		if (res == null) res = [];
		
		if (method == URLRequestMethod.GET || data == null) return res;
		
		if (Std.is(data, String) || Std.is(data, ByteArray)) {
			(res = res.copy()).push(new URLRequestHeader(
				"Content-Type",
				contentType != null ? contentType : "application/x-www-form-urlencoded"
			));
		}
		return res;
	}
}
#end