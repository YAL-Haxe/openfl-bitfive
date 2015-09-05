package openfl;
#if !macro


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.Lib;
import openfl.media.Sound;
import openfl.net.URLRequest;
import openfl.text.Font;
import openfl.utils.ByteArray;
import haxe.Unserializer;


/**
 * <p>The Assets class provides a cross-platform interface to access 
 * embedded images, fonts, sounds and other resource files.</p>
 * 
 * <p>The contents are populated automatically when an application
 * is compiled using the OpenFL command-line tools, based on the
 * contents of the *.nmml project file.</p>
 * 
 * <p>For most platforms, the assets are included in the same directory
 * or package as the application, and the paths are handled
 * automatically. For web content, the assets are preloaded before
 * the start of the rest of the application. You can customize the 
 * preloader by extending the <code>NMEPreloader</code> class,
 * and specifying a custom preloader using <window preloader="" />
 * in the project file.</p>
 */
@:access(openfl.AssetLibrary) class Assets {
	
	
	public static var cache:AssetCache = new AssetCache ();
	public static var libraries (default, null) = new Map <String, AssetLibrary> ();
	
	private static var initialized = false;
	
	/**
	 * Handles id "parsing" and library retrieval that is commonly used in local methods here.
	 * @param	id	Asset ID
	 * @param	f	function(libraryName, symbolName, libraryReference)
	 */
	@:extern private static inline function getInline(id:String, f:String->String->AssetLibrary->Void) {
		// A small note on how the following 4 lines of code work (reused across the file).
		// Asset IDs can be provided in format "library:symbol".
		// "ln" is library name. If ID does not contain a ":", .substring call with length -1
		// yields an empty string.
		// "sn" is symbol name. If ID does not contain a ":", .substr call gets 0, which is the
		// whole string.
		// "lr" is library reference. getLibrary returns default library if given an empty string.
		var i = id.indexOf(":");
		var ln = id.substring(0, i);
		var sn = id.substring(i + 1);
		var lr = getLibrary(ln);
		if (lr != null) {
			f(ln, sn, lr);
		} else Lib.trace('[openfl.Assets] There is no asset library named "$ln"');
	}
	
	public static function exists (id:String, ?type:AssetType):Bool {
		initialize();
		var r:Bool = false;
		#if (tools && !display)
		if (type == null) type = BINARY;
		getInline(id, function(ln, sn, lr) {
			r = (lr != null && lr.exists(sn, type));
		});
		#end
		return r;
	}
	
	/**
	 * Gets an instance of an embedded bitmap
	 * @usage	var bitmap = new Bitmap(Assets.getBitmapData("image.jpg"));
	 * @param	id	The ID or asset path for the bitmap
	 * @param	useCache	(Optional) Whether to use BitmapData from the cache(Default: true)
	 * @return	A new BitmapData object
	 */
	public static function getBitmapData (id:String, useCache:Bool = true):BitmapData {
		initialize();
		var r:BitmapData = null;
		#if (tools && !display)
		var c:AssetCache, b:BitmapData;
		// pick up from cache, if possible:
		if (useCache && (c = cache).enabled && c.bitmapData.exists(id)
		&& isValidBitmapData(b = cache.bitmapData.get(id))) return b;
		//
		getInline(id, function(ln, sn, lr) {
			if (lr.exists(sn, IMAGE)) {
				r = lr.getBitmapData(sn);
				if (useCache) {
					if (c.enabled) c.bitmapData.set(id, r);
				} else r = r.clone();
			} else Lib.trace('[openfl.Assets] There is no BitmapData asset with an ID of "$sn"');
		});
		#end
		return r;
	}
	
	
	/**
	 * Gets an instance of an embedded binary asset
	 * @usage	var bytes = Assets.getBytes("file.zip");
	 * @param	id	The ID or asset path for the file
	 * @return	A new ByteArray object
	 */
	public static function getBytes(id:String):ByteArray {
		initialize();
		var r:ByteArray = null;
		#if (tools && !display)
		getInline(id, function(ln, sn, lr) {
			if (lr.exists(sn, BINARY)) {
				if (lr.isLocal(sn, BINARY)) {
					r = lr.getBytes(sn);
				} else Lib.trace('[openfl.Assets] Binary asset "$id" exists, but only asynchronously');
			} else Lib.trace('[openfl.Assets] There is no binary asset with an id of "$sn"');
		});
		#end
		return r;
	}
	
	
	/**
	 * Gets an instance of an embedded font
	 * @usage	var fontName = Assets.getFont("font.ttf").fontName;
	 * @param	id	The ID or asset path for the font
	 * @return	A new Font object
	 */
	public static function getFont(id:String, useCache:Bool = true):Font {
		initialize();
		var r:Font = null;
		#if (tools && !display)
		if (useCache && cache.enabled && cache.font.exists(id)) {
			return cache.font.get(id);
		}
		getInline(id, function(ln, sn, lr) {
			if (lr.exists(sn, FONT)) {
				if (lr.isLocal(sn, FONT)) {
					r = lr.getFont(sn);
					if (useCache && cache.enabled) cache.font.set(id, r);
				} else Lib.trace('[openfl.Assets] Font asset "$id" exists, but only asynchronously');
			} else Lib.trace('[openfl.Assets] There is no font asset with an id of "$sn"');
		});
		#end
		return r;
	}
	
	
	private static function getLibrary(name:String):AssetLibrary {
		return libraries.get(name == null || name == "" ? "default" : name);
	}
	
	
	/**
	 * Gets an instance of a library MovieClip
	 * @usage	var movieClip = Assets.getMovieClip("library:BouncingBall");
	 * @param	id	The library and ID for the MovieClip
	 * @return	A new MovieClip object
	 */
	public static function getMovieClip (id:String):MovieClip {
		initialize();
		var r:MovieClip = null;
		#if (tools && !display)
		getInline(id, function(ln, sn, lr) {
			if (lr.exists(sn, MOVIE_CLIP)) {
				if (lr.isLocal(sn, MOVIE_CLIP)) {
					r = lr.getMovieClip(sn);
				} else Lib.trace('[openfl.Assets] MovieClip asset "$id" exists, but only asynchronously');
			} else Lib.trace('[openfl.Assets] There is no MovieClip asset with an ID of "$id"');
		});
		#end
		return r;
	}
	
	
	/**
	 * Gets an instance of an embedded streaming sound
	 * @usage	var sound = Assets.getMusic("sound.ogg");
	 * @param	id	The ID or asset path for the music track
	 * @return	A new Sound object
	 */
	public static function getMusic (id:String, useCache:Bool = true):Sound {
		initialize();
		var r:Sound = null;
		#if (tools && !display)
		if (useCache && cache.enabled && cache.sound.exists (id)) {
			var s:Sound = cache.sound.get(id);
			if (isValidSound(s)) return s;
		}
		getInline(id, function(ln, sn, lr) {
			if (lr.exists(sn, MUSIC)) {
				if (lr.isLocal(sn, MUSIC)) {
					r = lr.getMusic(sn);
					if (useCache && cache.enabled) cache.sound.set(id, r);
				} else Lib.trace('[openfl.Assets] Sound asset "$id" exists, but only asynchronously');
			} else Lib.trace('[openfl.Assets] There is no Sound asset with an ID of "$id"');
		});
		#end
		return r;
	}
	
	
	/**
	 * Gets the file path (if available) for an asset
	 * @usage	var path = Assets.getPath("image.jpg");
	 * @param	id	The ID or asset path for the asset
	 * @return	The path to the asset (or null)
	 */
	public static function getPath (id:String):String {
		initialize();
		var r:String = null;
		#if (tools && !display)
		getInline(id, function(ln, sn, lr) {
			if (lr.exists(sn, null)) {
				r = lr.getPath(sn);
			} else Lib.trace('[openfl.Assets] There is no asset with an ID of "$id"');
		});
		#end
		return r;
	}
	
	
	/**
	 * Gets an instance of an embedded sound
	 * @usage	var sound = Assets.getSound("sound.wav");
	 * @param	id	The ID or asset path for the sound
	 * @return	A new Sound object
	 */
	public static function getSound (id:String, useCache:Bool = true):Sound {
		initialize();
		var r:Sound = null;
		#if (tools && !display)
		if (useCache && cache.enabled && cache.sound.exists (id)) {
			var s:Sound = cache.sound.get(id);
			if (isValidSound(s)) return s;
		}
		getInline(id, function(ln, sn, lr) {
			if (lr.exists(sn, SOUND)) {
				if (lr.isLocal(sn, SOUND)) {
					r = lr.getMusic(sn);
					if (useCache && cache.enabled) cache.sound.set(id, r);
				} else Lib.trace('[openfl.Assets] Sound asset "$id" exists, but only asynchronously');
			} else Lib.trace('[openfl.Assets] There is no Sound asset with an ID of "$id"');
		});
		#end
		return r;
	}
	
	
	/**
	 * Gets an instance of an embedded text asset
	 * @usage	var text = Assets.getText("text.txt");
	 * @param	id	The ID or asset path for the file
	 * @return	A new String object
	 */
	public static function getText (id:String):String {
		initialize();
		var r:String = null;
		#if (tools && !display)
		getInline(id, function(ln, sn, lr) {
			if (lr.exists(sn, TEXT)) {
				if (lr.isLocal(sn, TEXT)) {
					r = lr.getText(sn);
				} else Lib.trace('[openfl.Assets] Text asset "$id" exists, but only asynchronously');
			} else Lib.trace('[openfl.Assets] There is no text asset with an id of "$sn"');
		});
		#end
		return r;
	}
	
	
	private static function initialize ():Void {
		if (!initialized) {
			#if (tools && !display)
			registerLibrary("default", new DefaultAssetLibrary());
			#end
			initialized = true;
		}
	}
	
	
	public static function isLocal(id:String, type:AssetType = null, useCache:Bool = true):Bool {
		initialize ();
		var r:Bool = false;
		#if (tools && !display)
		if (useCache && cache.enabled) {
			if (type == AssetType.IMAGE || type == null) {
				if (cache.bitmapData.exists (id)) return true;
			}
			if (type == AssetType.FONT || type == null) {
				if (cache.font.exists (id)) return true;
			}
			if (type == AssetType.SOUND || type == AssetType.MUSIC || type == null) {
				if (cache.sound.exists (id)) return true;
			}
		}
		getInline(id, function(ln, sn, lr) {
			r = lr.isLocal(sn, type);
		});
		#end
		return r;
	}
	
	
	private static inline function isValidBitmapData(bitmapData:BitmapData):Bool {
		return true;
	}
	
	
	private static inline function isValidSound(sound:Sound):Bool {
		return true;
	}
	
	public static function list(type:AssetType = null):Array<String> {
		initialize ();
		var r = [];
		for (o in libraries) {
			var m = o.list(type);
			if (m != null) r = r.concat(m);
		}
		return r;
	}
	
	
	public static function loadBitmapData (id:String, handler:BitmapData->Void, useCache:Bool = true):Void {
		initialize ();
		#if (tools && !display)
		if (useCache && cache.enabled && cache.bitmapData.exists(id)) {
			var b = cache.bitmapData.get(id);
			if (isValidBitmapData(b)) {
				handler(b);
				return;
			}
		}
		// Not the good part, but doing things the normal way currently (Nov 2014) results
		// in an extra inline function.
		var r:Bool = null;
		var sn2 = null, lr2 = null;
		getInline(id, function(ln, sn, lr) {
			if (r = lr.exists(sn, IMAGE)) {
				sn2 = sn;
				lr2 = lr;
			}
		});
		if (r != null) if (r) {
			if (useCache && cache.enabled) {
				lr2.loadBitmapData(sn2, function(b:BitmapData):Void {
					cache.bitmapData.set(id, b);
					handler(b);
				});
			} else lr2.loadBitmapData(sn2, handler);
			return;
		} else Lib.trace('[openfl.Assets] There is no BitmapData asset with an ID of "$id"');
		#end
		handler (null);
	}
	
	
	public static function loadBytes (id:String, handler:ByteArray->Void):Void {
		initialize();
		#if (tools && !display)
		var r:Bool = false;
		getInline(id, function(ln, sn, lr) {
			if (r = lr.exists(sn, BINARY)) {
				lr.loadBytes(sn, handler);
			} else Lib.trace('[openfl.Assets] There is no binary asset with an ID of "$id"');
		});
		if (r) return;
		#end
		handler(null);
	}
	
	
	public static function loadFont(id:String, handler:Font->Void, useCache:Bool = true):Void {
		initialize ();
		#if (tools && !display)
		if (useCache && cache.enabled && cache.font.exists(id)) {
			handler(cache.font.get(id));
			return;
		}
		var lr2 = null, sn2 = null, r = null;
		getInline(id, function(ln, sn, lr) {
			if (r = lr.exists(sn, FONT)) {
				lr2 = lr;
				sn2 = sn;
			}
		});
		if (r != null) if (r) {
			if (useCache && cache.enabled) {
				lr2.loadFont(sn2, function(o:Font):Void {
					cache.font.set(id, o);
					handler(o);
				});
			} else lr2.loadFont(sn2, handler);
			return;
		} else Lib.trace('[openfl.Assets] There is no font asset with an ID of "$id"');
		#end
		handler(null);
	}
	
	
	public static function loadLibrary(name:String, handler:AssetLibrary->Void):Void {
		initialize();
		#if (tools && !display)
		var data = getText('libraries/$name.dat');
		if (data != null && data != "") {
			var unserializer = new Unserializer(data);
			unserializer.setResolver (cast { resolveEnum: resolveEnum, resolveClass: resolveClass });
			
			var library:AssetLibrary = unserializer.unserialize();
			libraries.set(name, library);
			library.load(handler);
		} else Lib.trace ("[openfl.Assets] There is no asset library named \"" + name + "\"");
		#end
	}
	
	
	public static function loadMusic(id:String, handler:Sound->Void, useCache:Bool = true):Void {
		initialize ();
		#if (tools && !display)
		if (useCache && cache.enabled && cache.sound.exists (id)) {
			var sound = cache.sound.get (id);
			if (isValidSound (sound)) {
				handler (sound);
				return;
			}
		}
		var lr2 = null, sn2 = null, r = null;
		getInline(id, function(ln, sn, lr) {
			if (r = lr.exists(sn, MUSIC)) {
				lr2 = lr;
				sn2 = sn;
			}
		});
		if (r != null) if (r) {
			if (useCache && cache.enabled) {
				lr2.loadMusic(sn2, function(s:Sound):Void {
					cache.sound.set(id, s);
					handler(s);
				});
			} else lr2.loadMusic(sn2, handler);
			return;
		} else Lib.trace('[openfl.Assets] There is no sound asset with an ID of "$id"');
		#end
		handler(null);
	}
	
	
	public static function loadMovieClip(id:String, handler:MovieClip->Void):Void {
		initialize ();
		#if (tools && !display)
		var r:Bool = false;
		getInline(id, function(ln, sn, lr) {
			if (r = lr.exists(sn, MOVIE_CLIP)) {
				lr.loadMovieClip(sn, handler);
			} else Lib.trace('[openfl.Assets] There is no MovieClip asset with an ID of "$id"');
		});
		if (r) return;
		#end
		handler(null);
	}
	
	
	public static function loadSound(id:String, handler:Sound->Void, useCache:Bool = true):Void {
		initialize ();
		#if (tools && !display)
		if (useCache && cache.enabled && cache.sound.exists (id)) {
			var sound = cache.sound.get (id);
			if (isValidSound (sound)) {
				handler (sound);
				return;
			}
		}
		var lr2 = null, sn2 = null, r = null;
		getInline(id, function(ln, sn, lr) {
			if (r = lr.exists(sn, SOUND)) {
				lr2 = lr;
				sn2 = sn;
			}
		});
		if (r != null) if (r) {
			if (useCache && cache.enabled) {
				lr2.loadSound(sn2, function(s:Sound):Void {
					cache.sound.set(id, s);
					handler(s);
				});
			} else lr2.loadSound(sn2, handler);
			return;
		} else Lib.trace('[openfl.Assets] There is no sound asset with an ID of "$id"');
		#end
		handler(null);
	}
	
	
	public static function loadText(id:String, handler:String -> Void):Void {
		initialize();
		#if (tools && !display)
		var r:Bool = false;
		getInline(id, function(ln, sn, lr) {
			if (r = lr.exists(sn, TEXT)) {
				lr.loadText(sn, handler);
			} else Lib.trace('[openfl.Assets] There is no text asset with an ID of "$id"');
		});
		if (r) return;
		#end
		handler(null);		
	}
	
	
	public static function registerLibrary(name:String, library:AssetLibrary):Void {
		if (libraries.exists(name)) unloadLibrary (name);
		libraries.set(name, library);
	}
	
	
	private static function resolveClass(name:String):Class<Dynamic> {
		return Type.resolveClass(name);
	}
	
	
	private static function resolveEnum(name:String):Enum<Dynamic> {
		var value = Type.resolveEnum (name);
		return value;
	}
	
	
	public static function unloadLibrary(name:String):Void {
		initialize();
		#if (tools && !display)
		for (key in cache.bitmapData.keys()) {
			if (key.substring(0, key.indexOf(":")) == name) {
				cache.bitmapData.remove(key);
			}
		}
		// need to clean-up other cache types too?
		libraries.remove(name);
		#end
	}
}


class AssetLibrary {
	public function new() { }
	public function exists(id:String, type:AssetType):Bool return false;
	public function getBitmapData(id:String):BitmapData return null;
	public function getBytes(id:String):ByteArray return null;
	public function getText(id:String):String return null;
	public function getFont(id:String):Font return null;
	public function getMovieClip(id:String):MovieClip return null;
	public function getMusic(id:String):Sound return getSound (id);
	public function getPath(id:String):String return null;
	public function getSound(id:String):Sound return null;
	public function isLocal(id:String, type:AssetType):Bool return true;
	//
	public function list(type:AssetType):Array<String> return null;
	private function load(h:AssetLibrary->Void):Void h(this);
	public function loadBitmapData(id:String, h:BitmapData->Void):Void h(getBitmapData(id));
	public function loadBytes(id:String, h:ByteArray->Void):Void h(getBytes(id));
	public function loadText(id:String, h:String->Void):Void h(getText(id));
	public function loadFont(id:String, h:Font->Void):Void h(getFont(id));
	public function loadMovieClip(id:String, h:MovieClip->Void):Void h(getMovieClip(id));
	public function loadMusic(id:String, handler:Sound->Void):Void handler(getMusic(id));
	public function loadSound(id:String, handler:Sound->Void):Void handler(getSound(id));
}


class AssetCache {
	public var bitmapData:Map<String, BitmapData>;
	public var font:Map<String, Font>;
	public var sound:Map<String, Sound>;
	public var enabled(get, set):Bool;
	private function get_enabled() return __enabled;
	private function set_enabled(v) return __enabled = v;
	private var __enabled:Bool = true;
	
	public function new() {
		bitmapData = new Map<String, BitmapData>();
		font = new Map<String, Font>();
		sound = new Map<String, Sound>();
	}
	
	public function clear(?prefix:String):Void {
		if (prefix == null) {
			bitmapData = new Map<String, BitmapData>();
			font = new Map<String, Font>();
			sound = new Map<String, Sound>();
		} else {
			for (key in bitmapData.keys()) {
				if (StringTools.startsWith(key, prefix)) bitmapData.remove(key);
			}
			for (key in font.keys()) {
				if (StringTools.startsWith(key, prefix)) font.remove(key);
			}
			for (key in sound.keys()) {
				if (StringTools.startsWith(key, prefix)) sound.remove(key);
			}
		}
	}
	
	public function getBitmapData(id:String):BitmapData return bitmapData.get(id);
	public function getFont(id:String):Font return font.get(id);
	public function getSound(id:String):Sound return sound.get(id);
	
	public function hasBitmapData(id:String):Bool return bitmapData.exists(id);
	public function hasFont(id:String):Bool return font.exists(id);
	public function hasSound(id:String):Bool return sound.exists(id);
	
	public function removeBitmapData(id:String):Bool return bitmapData.remove(id);
	public function removeFont(id:String):Bool return font.remove(id);
	public function removeSound(id:String):Bool return sound.remove(id);
	
	public function setBitmapData(id:String, v:BitmapData):Void bitmapData.set(id, v);
	public function setFont(id:String, v:Font):Void font.set(id, v);
	public function setSound(id:String, v:Sound):Void sound.set(id, v);
}


class AssetData {
	public var id:String;
	public var path:String;
	public var type:AssetType;
	public function new () { }
}


enum AssetType {
	BINARY;
	FONT;
	IMAGE;
	MOVIE_CLIP;
	MUSIC;
	SOUND;
	TEMPLATE;
	TEXT;
}


#else // start macro:


import haxe.io.Bytes;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.Serializer;
import sys.io.File;


class Assets {
	/// handles openfl.display.BitmapData metadata
	macro public static function embedBitmap ():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields(),
			path:String = getMeta(":bitmap"),
			mpos:Position = null,
			b64:String = null;
		if (path != null) {
			mpos = getMetaPos(":bitmap");
			var data:Bytes = getBytes(path);
			if (data != null) {
				b64 = "data:image/" + getExtension(path) + ";base64," + toBase64(data);
			} else Context.warning("Failed to load " + path, mpos);
		}
		if (path != null) {
			// private static var image:ImageElement;
			fields.push({
				name: "image",
				access: [APrivate, AStatic],
				kind: FVar(macro:js.html.Image),
				pos: mpos
			});
			// private static function preload():Void { ... }
			fields.push({
				name: "preload",
				access: [APrivate, AStatic],
				kind: FFun({
					args: [],
					ret: null,
					expr: macro {
						var o:js.html.Image = untyped document.createElement("img");
						ApplicationMain.loadEmbed(image = o);
						o.src = $v{b64};
					}, params: []
				}), pos: mpos
			});
			// private static function __init__():Void preload();
			fields.push({
				name: "__init__",
				access: [APrivate, AStatic],
				kind: FFun({
					args: [],
					ret: null,
					expr: macro {
						preload();
					}, params: []
				}), pos: mpos
			});
			/* public function new():Void {
				 * var o:ImageElement = image;
				 * super(o.width, o.height, true, 0);
				 * __context.drawImage(o, 0, 0);
			 * }
			 */
			fields.push({
				name: "new",
				access: [APublic],
				kind: FFun({
					args: [
						makeArg("width", macro:Int, false),
						makeArg("height", macro:Int, false),
						makeArg("transparent", macro:Bool, true),
						makeArg("color", macro:Int, true),
					], ret: null,
					expr: macro {
						var o:js.html.ImageElement = image;
						super(o.width, o.height, true, 0);
						__context.drawImage(o, 0, 0);
					}, params: []
				}), pos: mpos
			});	
		}
		
		return fields;
		
	}
	
	/// Creates a FunctionArg typedef.
	private static function makeArg(o:String, ?t:ComplexType, z:Bool = true, ?v:Expr):FunctionArg {
		return { name: o, opt: z, type: t, value: v };
	}
	
	/// Returns file contents as haxe.io.Bytes (or null if it does not exist)
	private static function getBytes(p:String):Bytes {
		try {
			return File.getBytes(Context.resolvePath(p));
		} catch (_:Dynamic) { return null; }
	}
	
	/// Returns file extension (without preceding dot)
	private static function getExtension(p:String):String {
		var i:Int = p.lastIndexOf(".");
		return i >= 0 ? p.substring(i + 1) : "";
	}
	
	/// 
	private static function getMeta(o:String):String {
		for (v in Context.getLocalClass().get().meta.get())
		if (v.name == o && v.params.length > 0)
		switch (v.params[0].expr) {
		case EConst(CString(r)): return r;
		default:
		}
		return null;
	}
	
	///
	private static function getMetaPos(o:String):Position {
		for (v in Context.getLocalClass().get().meta.get())
		if (v.name == o && v.params.length > 0)
		return v.params[0].pos;
		return Context.currentPos();
	}
	
	/// Converts haxe.io.Bytes contents to URI-compliant base64 string.
	private static function toBase64(d:Bytes):String {
		var r:String, s:Serializer = new Serializer(), n:Int;
		s.serialize(d);
		r = s.toString();
		r = r.substring(r.indexOf(":") + 1);
		r = StringTools.replace(r, ":", "/");
		r = StringTools.replace(r, "%", "+");
		// padding:
		n = r.length;
		if (n & 3 != 0) r = StringTools.rpad(r, "=", n + (4 - (n & 3)));
		return r;
	}
	
	
	private static function embedData (metaName:String):Array<Field> {
		
		var classType = Context.getLocalClass().get();
		var metaData = classType.meta.get();
		var position = Context.currentPos();
		var fields = Context.getBuildFields();
		
		for (meta in metaData)
		if (meta.name == metaName && meta.params.length > 0)
		switch (meta.params[0].expr) {
		case EConst(CString(filePath)):
			
			var path = Context.resolvePath (filePath);
			var bytes = File.getBytes (path);
			var resourceName = "__ASSET__" + metaName + "_" + (classType.pack.length > 0 ? classType.pack.join ("_") + "_" : "") + classType.name;
			
			Context.addResource (resourceName, bytes);
			
			var fieldValue = {
				pos: position,
				expr: EConst(CString(resourceName))
			};
			fields.push( {
				kind: FVar(macro:String, fieldValue),
				name: "resourceName",
				access: [ APrivate, AStatic ],
				pos: position
			});
			
			return fields;
			
		default:
			
		}
		return null;
		
	}
	
	
	macro public static function embedFile ():Array<Field> {
		
		var fields = embedData (":file");
		
		if (fields != null) {
			
			var constructor = macro { 
				
				super();
				
				#if html5
				nmeFromBytes (haxe.Resource.getBytes (resourceName));
				#else
				__fromBytes (haxe.Resource.getBytes (resourceName));
				#end
				
			};
			
			var args = [ { name: "size", opt: true, type: macro :Int, value: macro 0 } ];
			fields.push ({ name: "new", access: [ APublic ], kind: FFun({ args: args, expr: constructor, params: [], ret: null }), pos: Context.currentPos() });
			
		}
		return fields;
		
	}
	
	
	macro public static function embedFont():Array<Field> {
		// Doesn't work like that.
		var fields = null;
		Context.warning("Embed fonts are not supported", Context.currentPos());
		return fields;
		
	}
	
	
	macro public static function embedSound ():Array<Field> {
		
		var fields = embedData (":sound");
		
		if (fields != null) {
			
			#if (!html5) // CFFILoader.h(248) : NOT Implemented:api_buffer_data
			
			var constructor = macro { 
				
				super();
				
				var byteArray = openfl.utils.ByteArray.fromBytes (haxe.Resource.getBytes(resourceName));
				loadCompressedDataFromByteArray(byteArray, byteArray.length, forcePlayAsMusic);
				
			};
			
			var args = [ { name: "stream", opt: true, type: macro :openfl.net.URLRequest, value: null }, { name: "context", opt: true, type: macro :openfl.media.SoundLoaderContext, value: null }, { name: "forcePlayAsMusic", opt: true, type: macro :Bool, value: macro false } ];
			fields.push ({ name: "new", access: [ APublic ], kind: FFun({ args: args, expr: constructor, params: [], ret: null }), pos: Context.currentPos() });
			
			#end
			
		}
		
		return fields;
		
	}
	
	
}


#end
