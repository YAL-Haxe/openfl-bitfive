package openfl.display;
#if js
import openfl.display.DisplayObject;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

class Loader extends Sprite implements ILoader {
	//
	public var content(default, null):DisplayObject;
	public var contentLoaderInfo(default, null):LoaderInfo;
	//
	private var mImage:BitmapData;
	private var mShape:Shape;
	//
	public function new() {
		super();
		contentLoaderInfo = LoaderInfo.create(this);
	}
	
	public function load(request:URLRequest, context:Dynamic = null):Void {
		var extension = "", i;
		//i = request.url.lastIndexOf(".");
		var parts = request.url.split(".");
		
		if (parts.length > 0) {
			extension = parts[parts.length - 1].toLowerCase();
		}
		var url = request.url;
		//
		var p = url.lastIndexOf(".");
		if (p < 0) throw 'Extension must be specified, got "$url"';
		var ct:String, bt:Bool = true;
		//
		var ext = url.substring(p + 1);
		switch (ext) {
		case "swf": ct = "application/x-shockwave-flash";
		case "png": ct = "image/png";
		case "gif": ct = "image/gif";
		case "jpg", "jpeg":
			bt = false;
			ct = "image/jpeg";
		default: throw 'Unrecognized extension "$ext" in "$url"';
		}
		untyped contentLoaderInfo.url = url;
		untyped contentLoaderInfo.contentType = ct;
		
		mImage = new BitmapData(0, 0, bt);
		
		try {
			
			contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoad, false/*, 2147483647*/);
			mImage.nmeLoadFromFile(request.url, contentLoaderInfo);
			content = new Bitmap(mImage);
			Reflect.setField(contentLoaderInfo, "content", this.content);
			addChild(content);
			
		} catch(e:Dynamic) {
			
			trace("Error " + e);
			var evt = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			evt.currentTarget = this;
			contentLoaderInfo.dispatchEvent(evt);
			return;
			
		}
		
		if (mShape == null) {
			
			mShape = new Shape();
			addChild(mShape);
			
		}
		
	}
	
	public function loadBytes(buffer:ByteArray):Void {
		
		try {
			
			contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoad, false/*, 2147483647*/);
			
			BitmapData.loadFromBytes(buffer, null, function(bmd:BitmapData):Void {
				
				content = new Bitmap(bmd);
				Reflect.setField(contentLoaderInfo, "content", this.content);
				addChild(content);
				var evt = new Event(Event.COMPLETE);
				evt.currentTarget = this;
				contentLoaderInfo.dispatchEvent(evt);
				
			});
			
		} catch(e:Dynamic) {
			
			trace("Error " + e);
			var evt = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			evt.currentTarget = this;
			contentLoaderInfo.dispatchEvent(evt);
			
		}
		
	}
	
	private function handleLoad(e:Event):Void {
		e.currentTarget = this;
		//content.nmeInvalidateBounds();
		//content.nmeRender(null, null);
		contentLoaderInfo.removeEventListener(Event.COMPLETE, handleLoad);
	}
}
#end