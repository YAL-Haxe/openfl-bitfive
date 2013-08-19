package flash.display;
#if js
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.ByteArray;

class Loader extends Sprite {
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
		
		var transparent = true;
		
		untyped {
			
			// set properties on the LoaderInfo object
			contentLoaderInfo.url = request.url;
			contentLoaderInfo.contentType = switch (extension) {
				
				case "swf": "application/x-shockwave-flash";
				case "jpg", "jpeg": transparent = false; "image/jpeg";
				case "png": "image/png";
				case "gif": "image/gif";
				default: ""; throw "Unrecognized file " + request.url;
				
			}
			
		}
		
		mImage = new BitmapData(0, 0, transparent);
		
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