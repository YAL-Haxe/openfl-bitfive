package openfl;
#if !macro


//import format.display.MovieClip;
import haxe.Unserializer;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.text.Font;
import flash.utils.ByteArray;

#if (tools && !display)
import nme.AssetData;
#end

#if swf
import format.swf.lite.SWFLite;
#if !js
import format.SWF;
#end
#end

#if xfl
import format.XFL;
#end


/**
 * Modification over OpenFL class for HTML5/bitfive-specific optimizations.
 */
class Assets {
	//
	public static var cachedBitmapData:Map<String, BitmapData> = new Map<String, BitmapData>();
	public static var id(get, null):Array<String>;
	public static var library(get, null):Map<String, LibraryType>;
	public static var path(get, null):Map<String, String>;
	public static var type(get, null):Map<String, AssetType>;
	
	#if (swf && !js) private static var cachedSWFLibraries = new Map<String, SWF>(); #end
	#if swf private static var cachedSWFLiteLibraries = new Map<String, SWFLite>(); #end
	#if xfl private static var cachedXFLLibraries = new Map<String, XFL>(); #end
	private static var initialized = false;
	
	private static function initialize():Void {
		if (!initialized) {
			#if (tools && !display)
			AssetData.initialize();
			#end
			initialized = true;
		}
	}
	
	/**
	 * Gets an instance of an embedded bitmap
	 * @usage		var bitmap = new Bitmap(Assets.getBitmapData("image.jpg"));
	 * @param	id		The ID or asset path for the bitmap
	 * @param	useCache		(Optional) Whether to use BitmapData from the cache(Default: true)
	 * @return		A new BitmapData object
	 */
	public static function getBitmapData(id:String, useCache:Bool = true):BitmapData {
		initialize();
		#if (tools && !display)
		var t:Map<String, AssetType> = AssetData.type,
			c:Map<String, BitmapData> = cachedBitmapData,
			r:BitmapData, b:Bitmap
			#if (swf||xfl)
			, i:Int, ln:String, sn:String, lt:Map<String, LibraryType>
			#end;
		if (t.exists(id) && t.get(id) == AssetType.IMAGE) {
			if (!c.exists(id)) {
				#if js
				b = cast ApplicationMain.loaders.get(AssetData.path.get(id)).contentLoaderInfo.content;
				r = b.bitmapData.clone();
				#elseif flash
				r = cast Type.createInstance(AssetData.className.get(id), [])
				#else // natives
				r = BitmapData.load(AssetData.path.get(id));
				#end
				if (useCache) cachedBitmapData.set(id, r);
				return r;
			} else return cachedBitmapData.get(id).clone();
		} #if (swf || xfl) // not even needed otherwise?
		else if ((i = id.indexOf(":")) > -1) {
			ln = id.substr(0, i);
			sn = id.substr(i + 1);
			lt = AssetData.library;
			//
			if (lt.exists(ln)) {
			#if swf
				#if !js
				if (lt.get(ln) == LibraryType.SWF) return getSWFLibrary(ln).getBitmapData(sn);
				#end
				if (lt.get(ln) == LibraryType.SWF_LITE)
					return getSWFLiteLibrary(libraryName).getBitmapData(symbolName);
			#end
			#if xfl
				if (lt.get(ln) == LibraryType.XFL) return getXFLLibrary(ln).getBitmapData(sn);
			#end
			} else flash.Lib.trace('Asset library "$ln" not found.');
		} #end else flash.Lib.trace('BitmapData "$id" not found.');
		#end
		return null;
	}
	
	
	/**
	 * Gets an instance of an embedded binary asset
	 * @usage		var bytes = Assets.getBytes("file.zip");
	 * @param	id		The ID or asset path for the file
	 * @return		A new ByteArray object
	 */
	public static function getBytes(id:String):ByteArray {
		
		initialize();
		
		#if (tools && !display)
		
		if (AssetData.type.exists(id)) {
			
			#if flash
			
			return Type.createInstance(AssetData.className.get(id), []);
			
			#elseif js

			var bytes:ByteArray = null;
			var data = ApplicationMain.urlLoaders.get(AssetData.path.get(id)).data;
			if (Std.is(data, String)) {
				var bytes = new ByteArray();
				bytes.writeUTFBytes(data);
			} else if (Std.is(data, ByteArray)) {
				bytes = cast data;
			} else {
				bytes = null;
			}

			if (bytes != null) {
				bytes.position = 0;
				return bytes;
			} else {
				return null;
			}
			
			#else
			
			return ByteArray.readFile(AssetData.path.get(id));
			
			#end
			
		} else {
			
			trace("[openfl.Assets] There is no String or ByteArray asset with an ID of \"" + id + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	
	
	/**
	 * Gets an instance of an embedded font
	 * @usage		var fontName = Assets.getFont("font.ttf").fontName;
	 * @param	id		The ID or asset path for the font
	 * @return		A new Font object
	 */
	public static function getFont(id:String):Font {
		
		initialize();
		
		#if (tools && !display)
		
		if (AssetData.type.exists(id) && AssetData.type.get(id) == AssetType.FONT) {
			
			#if (flash || js)
			
			return cast(Type.createInstance(AssetData.className.get(id), []), Font);
			
			#else
			
			return new Font(AssetData.path.get(id));
			
			#end
			
		} else {
			
			trace("[openfl.Assets] There is no Font asset with an ID of \"" + id + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	
	
	#if swf
	/**
	 * Gets an instance of a library MovieClip
	 * @usage		var movieClip = Assets.getMovieClip("library:BouncingBall");
	 * @param	id		The library and ID for the MovieClip
	 * @return		A new Sound object
	 */
	public static function getMovieClip(id:String):MovieClip {
		
		initialize();
		
		#if (tools && !display)
		
		var libraryName = id.substr(0, id.indexOf(":"));
		var symbolName = id.substr(id.indexOf(":") + 1);
		
		if (AssetData.library.exists(libraryName)) {
			
			#if swf
			#if !js
			if (AssetData.library.get(libraryName) == LibraryType.SWF) {
				
				return getSWFLibrary (libraryName).createMovieClip (symbolName);
				
			}
			#end
			
			if (AssetData.library.get(libraryName) == LibraryType.SWF_LITE) {
				
				return getSWFLiteLibrary (libraryName).createMovieClip (symbolName);
				
			}
			#end
			
			#if xfl
			if (AssetData.library.get(libraryName) == LibraryType.XFL) {
				
				return getXFLLibrary (libraryName).createMovieClip (symbolName);
				
			}
			#end
			
		} else {
			
			trace("[openfl.Assets] There is no asset library named \"" + libraryName + "\"");
			
		}
		
		#end
		
		return null;
		
	}
	#end
	
	
	/**
	 * Gets an instance of an embedded sound
	 * @usage		var sound = Assets.getSound("sound.wav");
	 * @param	id		The ID or asset path for the sound
	 * @return		A new Sound object
	 */
	public static function getSound(id:String):Sound {
		
		initialize();
		
		#if (tools && !display)
		
		if (AssetData.type.exists(id)) {
			
			var type = AssetData.type.get(id);
			
			if (type == AssetType.SOUND || type == AssetType.MUSIC) {
				
				#if flash
				
				return cast(Type.createInstance(AssetData.className.get(id), []), Sound);
				
				#elseif js
				
				return new Sound(new URLRequest(AssetData.path.get(id)));
				
				#else
				
				return new Sound(new URLRequest(AssetData.path.get(id)), null, type == MUSIC);
				
				#end
				
			}
			
		}
		
		trace("[openfl.Assets] There is no Sound asset with an ID of \"" + id + "\"");
		
		#end
		
		return null;
		
	}
	
	
	#if swf
	#if !js
	private static function getSWFLibrary (libraryName:String):SWF {
		
		if (!cachedSWFLibraries.exists (libraryName)) {
			
			cachedSWFLibraries.set (libraryName, new SWF (getBytes("libraries/" + libraryName + ".swf")));
			
		}
		
		return cachedSWFLibraries.get (libraryName);
		
	}
	#end
	
	
	private static function getSWFLiteLibrary (libraryName:String):SWFLite {
		
		if (!cachedSWFLiteLibraries.exists(libraryName)) {
			
			var unserializer = new Unserializer (getText ("libraries/" + libraryName + ".dat"));
			unserializer.setResolver (cast { resolveEnum: resolveEnum, resolveClass: resolveClass });
			cachedSWFLiteLibraries.set (libraryName, unserializer.unserialize());
			
		}
		
		return cachedSWFLiteLibraries.get (libraryName);
		
	}
	#end
	
	
	/**
	 * Gets an instance of an embedded text asset
	 * @usage		var text = Assets.getText("text.txt");
	 * @param	id		The ID or asset path for the file
	 * @return		A new String object
	 */
	public static function getText(id:String):String {
		
		var bytes = getBytes(id);
		
		if (bytes == null) {
			
			return null;
			
		} else {
			
			return bytes.readUTFBytes(bytes.length);
			
		}
		
	}
	
	
	#if xfl
	private static function getXFLLibrary (libraryName:String):XFL {
		
		if (!cachedXFLLibraries.exists (libraryName)) {
				
			cachedXFLLibraries.set (libraryName, Unserializer.run (getText ("libraries/" + libraryName + "/" + libraryName + ".dat")));
			
		}
		
		return cachedXFLLibraries.get (libraryName);
		
	}
	#end
	
	
	//public static function loadBitmapData(id:String, handler:BitmapData -> Void, useCache:Bool = true):BitmapData
	//{
		//return null;
	//}
	//
	//
	//public static function loadBytes(id:String, handler:ByteArray -> Void):ByteArray
	//{	
		//return null;
	//}
	//
	//
	//public static function loadText(id:String, handler:String -> Void):String
	//{
		//return null;
	//}
	
	
	private static function resolveClass (name:String):Class <Dynamic> {
		
		name = StringTools.replace(name, "native.", "flash.");
		name = StringTools.replace(name, "browser.", "flash.");
		return Type.resolveClass(name);
		
	}
	
	
	private static function resolveEnum (name:String):Enum <Dynamic> {
		
		name = StringTools.replace(name, "native.", "flash.");
		name = StringTools.replace(name, "browser.", "flash.");
		#if flash
		var value = Type.resolveEnum(name);
		if (value != null) {
			return value;
		} else {
			return cast Type.resolveClass (name);
		}
		#else
		return Type.resolveEnum(name);
		#end
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private static function get_id():Array<String> {
		
		initialize ();
		
		var ids = [];
		
		#if (tools && !display)
		
		for (key in AssetData.type.keys ()) {
			
			ids.push (key);
			
		}
		
		#end
		
		return ids;
		
	}
	
	
	private static function get_library():Map<String, LibraryType> {
		
		initialize ();
		
		#if (tools && !display)
		
		return AssetData.library;
		
		#else
		
		return new Map<String, LibraryType> ();
		
		#end
		
	}
	
	
	private static function get_path():Map<String, String> {
		
		initialize ();
		
		#if ((tools && !display) && !flash)
		
		return AssetData.path;
		
		#else
		
		return new Map<String, String> ();
		
		#end
		
	}
	
	
	private static function get_type():Map<String, AssetType> {
		
		initialize ();
		
		#if (tools && !display)
		
		return AssetData.type;
		
		#else
		
		return new Map<String, AssetType> ();
		
		#end
		
	}
	
	
}

abstract AssetType(String) {
	@:extern public static inline var BINARY:AssetType = "BINARY";
	@:extern public static inline var FONT:AssetType = "FONT";
	@:extern public static inline var IMAGE:AssetType = "IMAGE";
	@:extern public static inline var MUSIC:AssetType = "MUSIC";
	@:extern public static inline var SOUND:AssetType = "SOUND";
	@:extern public static inline var TEXT:AssetType = "TEXT";
	//
	public inline function new(s:String) this = s;
	@:to public inline function toString():String return this;
	@:from public static inline function fromString(s:String) return new AssetType(s);
}

abstract LibraryType(String) {
	@:extern public static inline var SWF:AssetType = "SWF";
	@:extern public static inline var SWF_LITE:AssetType = "SWF_LITE";
	@:extern public static inline var XFL:AssetType = "XFL";
	//
	public inline function new(s:String) this = s;
	@:to public inline function toString():String return this;
	@:from public static inline function fromString(s:String) return new LibraryType(s);
}


#else // macro


import haxe.io.Bytes;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.Serializer;
import sys.io.File;


class Assets {
	
	
	macro public static function embedBitmap ():Array<Field> {
		
		var fields = embedData (":bitmap");
		
		if (fields != null) {
			
			var constructor = macro { 
				
				super(width, height, transparent, fillRGBA);
				
				#if html5
				
				var currentType = Type.getClass (this);
				
				if (preload != null) {
					
					_nmeTextureBuffer.width = Std.int (preload.width);
					_nmeTextureBuffer.height = Std.int (preload.height);
					rect = new flash.geom.Rectangle (0, 0, preload.width, preload.height);
					setPixels(rect, preload.getPixels(rect));
					nmeBuildLease();
					
				} else {
					
					var byteArray = flash.utils.ByteArray.fromBytes (haxe.Resource.getBytes(resourceName));
					
					if (onload != null && !Std.is (onload, Bool)) {
						
						nmeLoadFromBytes(byteArray, null, onload);
						
					} else {
						
						nmeLoadFromBytes(byteArray);
						
					}
					
				}
				
				#else
				
				var byteArray = flash.utils.ByteArray.fromBytes (haxe.Resource.getBytes (resourceName));
				__loadFromBytes (byteArray);
				
				#end
				
			};
			
			var args = [ { name: "width", opt: false, type: macro :Int, value: null }, { name: "height", opt: false, type: macro :Int, value: null }, { name: "transparent", opt: true, type: macro :Bool, value: macro true }, { name: "fillRGBA", opt: true, type: macro :Int, value: macro 0xFFFFFFFF } ];
			
			#if html5
			args.push ({ name: "onload", opt: true, type: macro :Dynamic, value: null });
			fields.push ({ kind: FVar(macro :flash.display.BitmapData, null), name: "preload", doc: null, meta: [], access: [ APublic, AStatic ], pos: Context.currentPos() });
			#end
			
			fields.push ({ name: "new", access: [ APublic ], kind: FFun({ args: args, expr: constructor, params: [], ret: null }), pos: Context.currentPos() });
			
		}
		
		return fields;
		
	}
	
	
	private static function embedData (metaName:String):Array<Field> {
		
		var classType = Context.getLocalClass().get();
		var metaData = classType.meta.get();
		var position = Context.currentPos();
		var fields = Context.getBuildFields();
		
		for (meta in metaData) {
			
			if (meta.name == metaName) {
				
				if (meta.params.length > 0) {
					
					switch (meta.params[0].expr) {
						
						case EConst(CString(filePath)):
							
							var path = Context.resolvePath (filePath);
							var bytes = File.getBytes (path);
							var resourceName = "NME_" + metaName + "_" + (classType.pack.length > 0 ? classType.pack.join ("_") + "_" : "") + classType.name;
							
							Context.addResource (resourceName, bytes);
							
							var fieldValue = { pos: position, expr: EConst(CString(resourceName)) };
							fields.push ({ kind: FVar(macro :String, fieldValue), name: "resourceName", access: [ APrivate, AStatic ], pos: position });
							
							return fields;
							
						default:
						
					}
					
				}
				
			}
			
		}
		
		return null;
		
	}
	
	
	macro public static function embedFile ():Array<Field> {
		var r:Array<Field> = embedData(":file");
		/* add
		public function new(size:Int = 0):Void {
			super();
			#if html5
			nmeFromBytes(haxe.Resource.getBytes(resourceName));
			#else
			__fromBytes(haxe.Resource.getBytes(resourceName));
			#end
		}
		to class data output from embedData: */
		if (r != null) r.push( {
			pos: Context.currentPos(),
			access: [APublic],
			name: "new",
			kind: FFun( {
				params: [],
				args: [{
					name: "size",
					opt: true,
					type: macro :Int,
					value: macro 0
				}],
				ret: null,
				expr: macro {
					super();
					#if html5
					nmeFromBytes(haxe.Resource.getBytes(resourceName));
					#else
					__fromBytes(haxe.Resource.getBytes(resourceName));
					#end
				},
			}),
		});
		return r;
	}
	
	
	macro public static function embedFont ():Array<Field> {
		// see you later!
		return Context.getBuildFields();
	}
	
	
	macro public static function embedSound ():Array<Field> {
		
		var fields = embedData (":sound");
		
		if (fields != null) {
			
			#if (!html5) // CFFILoader.h(248) : NOT Implemented:api_buffer_data
			
			var constructor = macro { 
				
				super();
				
				var byteArray = flash.utils.ByteArray.fromBytes (haxe.Resource.getBytes(resourceName));
				loadCompressedDataFromByteArray(byteArray, byteArray.length, forcePlayAsMusic);
				
			};
			
			var args = [ { name: "stream", opt: true, type: macro :flash.net.URLRequest, value: null }, { name: "context", opt: true, type: macro :flash.media.SoundLoaderContext, value: null }, { name: "forcePlayAsMusic", opt: true, type: macro :Bool, value: macro false } ];
			fields.push ({ name: "new", access: [ APublic ], kind: FFun({ args: args, expr: constructor, params: [], ret: null }), pos: Context.currentPos() });
			
			#end
			
		}
		
		return fields;
		
	}
	
	
}


#end