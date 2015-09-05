package openfl.net;
#if js
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.errors.IOError;
import openfl.events.SecurityErrorEvent;
import openfl.utils.ByteArray;
import js.html.ArrayBuffer;
import js.html.EventTarget;
import js.html.XMLHttpRequest;
import js.Browser;
import js.Lib;


class URLLoader extends EventDispatcher implements IURLLoader {
	
	
	public var bytesLoaded:Int;
	public var bytesTotal:Int;
	public var data:Dynamic;
	public var dataFormat(default, set):URLLoaderDataFormat;
	private function set_dataFormat(v:URLLoaderDataFormat):URLLoaderDataFormat {
		// Handle lack of ArrayBuffer support:
		dataFormat = (v == URLLoaderDataFormat.BINARY && untyped (window.ArrayBuffer == null))
			? URLLoaderDataFormat.TEXT : v;
		return dataFormat;
	}
	
	
	public function new(request:URLRequest = null) {
		super();
		//
		bytesLoaded = bytesTotal = 0;
		dataFormat = URLLoaderDataFormat.TEXT;
		//
		if (request != null) load(request);
	}
	
	
	public function close():Void {
		
	}
	
	// Overriden in requestURL()
	private dynamic function getData():Dynamic return null;
	
	public function load(request:URLRequest):Void {
		requestUrl(request.url, request.method, request.data, request.formatRequestHeaders());
	}
	
	
	private function registerEvents(subject:EventTarget):Void {
		var self = this;
		if (untyped __js__("typeof XMLHttpRequestProgressEvent") != __js__('"undefined"')) {
			subject.addEventListener("progress", onProgress, false);
		}
		
		untyped subject.onreadystatechange = function() if (subject.readyState == 4) {
			var s:Null<Int>;
			// try to pull status from 
			try {
				s = subject.status;
			} catch (_:Dynamic) {
				s = null;
			}
			
			// dispatch status event:
			if (s != null) self.onStatus(s);
			
			// error handling:
			if (s == null)
				self.onError("Failed to connect or resolve host");
			else if (s >= 200 && s < 400)
				self.onData(subject.response);
			else if (s == 12029)
				self.onError("Failed to connect to host");
			else if (s == 12007)
				self.onError("Unknown host");
			else if (s == 0) {
				self.onError("Unable to make request (may be blocked due to cross-domain permissions)");
				self.onSecurityError("Unable to make request (may be blocked due to cross-domain permissions)");
			} else self.onError("Http Error #" + subject.status);
		};
	}
	
	
	private function requestUrl(url:String, method:String, data:Dynamic, requestHeaders:Array<URLRequestHeader>):Void {
		var xmlHttpRequest:XMLHttpRequest = untyped __new__("XMLHttpRequest");
		// assign new data getter:
		getData = function() return xmlHttpRequest.response != null
			? xmlHttpRequest.response : xmlHttpRequest.responseText;
		// 
		registerEvents(cast xmlHttpRequest);
		var uri:Dynamic = "";
		
		if (Std.is(data, ByteArray)) {
			var data:ByteArray = cast data;
			uri = dataFormat == URLLoaderDataFormat.BINARY
				? data.nmeGetBuffer() : data.readUTFBytes(data.length);
		} else if (Std.is(data, URLVariables)) {
			var data:URLVariables = cast data;
			for (p in Reflect.fields(data)) {
				if (uri.length != 0) uri += "&";
				uri += StringTools.urlEncode(p) + "="
					+ StringTools.urlEncode(Reflect.field(data, p));
			}
		} else if (data != null) uri = data.toString();
		
		try {
			if (method == "GET" && uri != null && uri != "") {
				var question = url.split("?").length <= 1;
				xmlHttpRequest.open(method, url + (if (question) "?" else "&") + uri, true);
				uri = "";
			} else xmlHttpRequest.open(method, url, true);
		} catch(e:Dynamic) {
			onError(e.toString());
			return;
		}
		// switch response type if needed:
		if (dataFormat == URLLoaderDataFormat.BINARY) {
			#if (haxe_ver >= 3.2)
			xmlHttpRequest.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
			#else
			xmlHttpRequest.responseType = "arraybuffer";
			#end
		}
		// set request headers:
		for (header in requestHeaders) {
			xmlHttpRequest.setRequestHeader(header.name, header.value);
		}
		//
		xmlHttpRequest.send(uri);
		onOpen();
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function onData(_):Void {
		// getData() sometimes returns empty strings. Need to investigate.
		var v:Dynamic = untyped _ ? _ : getData(), e:Event;
		// parse response accordingly:
		this.data =
			dataFormat == URLLoaderDataFormat.BINARY
			? ByteArray.nmeOfBuffer(v)
			: Std.string(v);
		// dispatch an event:
		e = new Event(Event.COMPLETE);
		e.currentTarget = this;
		dispatchEvent(e);
	}
	
	private function onError(msg:String):Void {
		var e = new IOErrorEvent(IOErrorEvent.IO_ERROR);
		e.text = msg;
		e.currentTarget = this;
		dispatchEvent(e);
	}
	
	private function onOpen():Void {
		var e = new Event(Event.OPEN);
		e.currentTarget = this;
		dispatchEvent(e);
	}
	
	private function onProgress(event:XMLHttpRequestProgressEvent):Void {
		var e = new ProgressEvent(ProgressEvent.PROGRESS);
		e.currentTarget = this;
		e.bytesLoaded = event.loaded;
		e.bytesTotal = event.total;
		dispatchEvent(e);
	}
	
	private function onSecurityError(msg:String):Void {
		var evt = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR);
		evt.text = msg;
		evt.currentTarget = this;
		dispatchEvent(evt);
	}
	
	private function onStatus(status:Int):Void {
		var e = new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, status);
		e.currentTarget = this;
		dispatchEvent(e);
	}
}
typedef XMLHttpRequestProgressEvent = Dynamic;
#end