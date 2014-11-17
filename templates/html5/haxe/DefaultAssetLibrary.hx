package;

import haxe.Timer;
import haxe.Unserializer;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.text.Font;
import openfl.utils.ByteArray;

class DefaultAssetLibrary extends openfl.AssetLibrary {
	public var className(default, null) = new Map<String, Dynamic>();
	public var path(default, null) = new Map<String, String>();
	public var type(default, null) = new Map<String, AssetType>();
	
	private var lastModified:Float;
	private var timer:Timer;
	
	public function new() {
		super();
		::if (assets != null)::// register assets:
		::foreach assets::::if (embed)::add("::id::", $$upper(::type::)::if (resourceName != id)::, "::resourceName::"::end::);
		::end::::end::::end:://
	}
	::if (assets != null)::
	private function add(id:String, t:AssetType, ?p:String) {
		type.set(id, t);
		path.set(id, p != null ? p : id);
	}
	
	override public function getPath(id:String):String {
		return path.get(id);
	}
	
	override public function exists(id:String, t:AssetType):Bool {
		var r = type.get(id);
		if (r != null) {
			if (r == t || t == null) return true;
			switch (t) {
			case AssetType.SOUND: return r == AssetType.MUSIC;
			case AssetType.MUSIC: return r == AssetType.SOUND;
			case AssetType.BINARY: return true;
			default: return false;
			}
		}
		return false;
	}
	
	override public function getBitmapData(id:String):BitmapData {
		var q:Loader = ApplicationMain.loaders.get(path.get(id));
		var b:Bitmap = cast q.contentLoaderInfo.content;
		return b.bitmapData;
	}
	
	override public function getFont(id:String):Font {
		// not yet.
		return null;
	}
	
	override public function getSound(id:String):Sound {
		return new Sound(new URLRequest(path.get(id)));
	}
	
	override public function getMusic(id:String):Sound {
		return new Sound(new URLRequest(path.get(id)));
	}
	
	override public function getBytes(id:String):ByteArray {
		var r:ByteArray = null;
		var d = ApplicationMain.urlLoaders.get(path.get(id)).data;
		if (Std.is(d, String)) {
			(r = new ByteArray()).writeUTFBytes(cast d);
		} else if (Std.is(d, ByteArray)) {
			r = cast d;
		} else r = null;
		if (r != null) {
			r.position = 0;
			return r;
		} else return null;
	}
	
	override public function getText(id:String):String {
		var r:ByteArray = null;
		var d = ApplicationMain.urlLoaders.get(path.get(id)).data;
		if (Std.is(d, String)) {
			return cast d;
		} else if (Std.is(d, ByteArray)) {
			r = cast d;
			r.position = 0;
			return r.readUTFBytes(r.length);
		} else return null;
	}
	
	override public function list(t:AssetType):Array<String> {
		var r:Array<String> = [];
		for (id in type.keys()) {
			if (t == null || exists(id, t)) r.push(id);
		}
		return r;
	}
	
	override public function loadBitmapData(id:String, h:BitmapData->Void):Void {
		if (path.exists(id)) {
			var r = new Loader();
			var f:Event->Void = null;
			f = function(e:Event) {
				r.contentLoaderInfo.removeEventListener(Event.COMPLETE, f);
				var b:Bitmap = cast e.currentTarget.content;
				h(b.bitmapData);
				b = null; f = null; r = null;
			};
			r.addEventListener(Event.COMPLETE, f);
			r.load(new URLRequest(path.get(id)));
		} else h(getBitmapData(id));
	}
	
	override public function loadFont(id:String, h:Font->Void):Void {
		h(getFont(id));
	}
	
	override public function loadSound(id:String, h:Sound->Void):Void {
		h(getSound(id));
	}
	
	override public function loadMusic(id:String, h:Sound->Void):Void {
		h(getMusic(id));
	}
	
	override public function loadBytes(id:String, h:ByteArray->Void):Void {
		if (path.exists(id)) {
			var r = new URLLoader();
			var f:Event->Void = null;
			f = function(e:Event) {
				r.removeEventListener(Event.COMPLETE, f);
				var b = new ByteArray();
				b.writeUTFBytes(e.currentTarget.data);
				b.position = 0;
				h(b);
				b = null; f = null; r = null;
			};
			r.addEventListener(Event.COMPLETE, f);
		} else h(getBytes(id));
	}
	
	override public function loadText(id:String, h:String->Void):Void {
		if (path.exists(id)) {
			var r = new URLLoader();
			var f:Event->Void = null;
			f = function(e:Event) {
				r.removeEventListener(Event.COMPLETE, f);
				h(e.currentTarget.data);
				f = null; r = null;
			};
			r.addEventListener(Event.COMPLETE, f);
		} else h(getText(id));
	}
	::end::
}
