#if !macro
import ::APP_MAIN_PACKAGE::::APP_MAIN_CLASS::;
import haxe.Resource;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.ILoader;
import flash.events.Event;
import flash.media.Sound;
import flash.net.IURLLoader;
import flash.net.URLRequest;
import flash.net.URLLoaderDataFormat;
import flash.Lib;
import js.html.Element;
import js.html.AudioElement;

class ApplicationMain {
	#if (openfl >= "2.1")
	public static var config:lime.app.Config = {
		antialiasing: Std.int(::WIN_ANTIALIASING::),
		background: Std.int(::WIN_BACKGROUND::),
		borderless: ::WIN_BORDERLESS::,
		depthBuffer: ::WIN_DEPTH_BUFFER::,
		fps: Std.int(::WIN_FPS::),
		fullscreen: ::WIN_FULLSCREEN::,
		height: Std.int(::WIN_HEIGHT::),
		orientation: "::WIN_ORIENTATION::",
		resizable: ::WIN_RESIZABLE::,
		stencilBuffer: ::WIN_STENCIL_BUFFER::,
		title: "::APP_TITLE::",
		vsync: ::WIN_VSYNC::,
		width: Std.int(::WIN_WIDTH::),
	};
	#end
	private static var completed:Int;
	private static var preloader:::if (PRELOADER_NAME != "")::::PRELOADER_NAME::::else::NMEPreloader::end::;
	private static var total:Int;

	public static var loaders:Map<String, ILoader>;
	public static var urlLoaders:Map<String, IURLLoader>;
	private static var loaderStack:Array<String>;
	private static var urlLoaderStack:Array<String>;
	// Embed data preloading
	@:noCompletion public static var embeds:Int;
	@:noCompletion public static function loadEmbed(o:Element) {
		embeds = (embeds != null ? embeds : 0) + 1;
		var f = null;
		f = function(_) {
			o.removeEventListener("load", f);
			if (--embeds == 0) preload();
		}
		o.addEventListener("load", f);
	}
	
	public static function main() {
		if (embeds == null || embeds == 0) preload();
	}

	private static function preload() {
		completed = 0;
		loaders = new Map<String, ILoader>();
		urlLoaders = new Map<String, IURLLoader>();
		total = 0;
		
		flash.Lib.current.loaderInfo = flash.display.LoaderInfo.create (null);
		
		::if (WIN_FPS != "0")::flash.Lib.stage.frameRate = ::WIN_FPS::;
		::end::::if (WIN_WIDTH == "0")::::if (WIN_HEIGHT == "0")::flash.Lib.preventDefaultTouchMove();
		::end::::end::// preloader:
		Lib.current.addChild(preloader = new ::if (PRELOADER_NAME != "")::::PRELOADER_NAME::::else::NMEPreloader::end::());
		preloader.onInit();
		
		// assets:
		::foreach assets::::if (type == "image")::loadFile("::resourceName::");
		::elseif (type == "binary")::loadBinary("::resourceName::");
		::elseif (type == "text")::loadBinary("::resourceName::");
		::elseif (type == "sound")::loadSound("::resourceName::");
		::elseif (type == "music")::loadSound("::resourceName::");
		::end::::end::
		// bitmaps:
		var resourcePrefix = "NME_:bitmap_";
		for (resourceName in Resource.listNames()) {
			if (StringTools.startsWith (resourceName, resourcePrefix)) {
				var type = Type.resolveClass(StringTools.replace (resourceName.substring(resourcePrefix.length), "_", "."));
				if (type != null) {
					total++;
					#if bitfive_logLoading
						flash.Lib.trace("Loading " + Std.string(type));
					#end
					var instance = Type.createInstance (type, [ 0, 0, true, 0x00FFFFFF, bitmapClass_onComplete ]);
				}
			}
		}
		
		if (total != 0) {
			loaderStack = [];
			for (p in loaders.keys()) loaderStack.push(p);
			urlLoaderStack = [];
			for (p in urlLoaders.keys()) urlLoaderStack.push(p);
			// launch 8 loaders at once:
			for (i in 0 ... 8) nextLoader();
		} else begin();
	}
	
	private static function nextLoader() {
		if (loaderStack.length != 0) {
			var p = loaderStack.shift(), o = loaders.get(p);
			#if bitfive_logLoading
				flash.Lib.trace("Loading " + p);
				o.contentLoaderInfo.addEventListener("complete", function(e) {
					flash.Lib.trace("Loaded " + p);
					loader_onComplete(e);
				});
			#else
				o.contentLoaderInfo.addEventListener("complete", loader_onComplete);
			#end
			o.load(new URLRequest(p));
		} else if (urlLoaderStack.length != 0) {
			var p = urlLoaderStack.shift(), o = urlLoaders.get(p);
			#if bitfive_logLoading
				flash.Lib.trace("Loading " + p);
				o.addEventListener("complete", function(e) {
					flash.Lib.trace("Loaded " + p);
					loader_onComplete(e);
				});
			#else
				o.addEventListener("complete", loader_onComplete);
			#end
			o.load(new URLRequest(p));
		}
	}
	
	private static function loadFile(p:String):Void {
		loaders.set(p, new flash.display.Loader());
		total++;
	}
	
	private static function loadBinary(p:String):Void {
		var o = new flash.net.URLLoader();
		o.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoaders.set(p, o);
		total++;
	}
	
	private static function loadSound(p:String):Void {
		return;
		var i:Int = p.lastIndexOf("."), // extension separator location
			c:Dynamic = untyped flash.media.Sound, // sound class
			s:String, // perceived sound filename (*.mp3)
			o:AudioElement, // audio node
			m:Bool = Lib.mobile,
			f:Dynamic->Void = null, // event listener
			q:String = "canplaythrough"; // preload event
		// not a valid sound path:
		if (i == -1) return;
		// wrong audio type:
		if (!c.canPlayType || !c.canPlayType(p.substr(i + 1))) return;
		// form perceived path:
		s = p.substr(0, i) + ".mp3";
		// already loaded?
		if (c.library.exists(s)) return;
		#if bitfive_logLoading
			flash.Lib.trace("Loading " + p);
		#end
		total++;
		c.library.set(s, o = untyped __js__("new Audio(p)"));
		f = function(_) {
			#if bitfive_logLoading
				flash.Lib.trace("Loaded " + p);
			#end
			if (!m) o.removeEventListener(q, f);
			preloader.onUpdate(++completed, total);
			if (completed == total) begin();
		};
		// do not auto-preload sounds on mobile:
		if (m) f(null); else o.addEventListener(q, f);
	}

	private static function begin():Void {
		preloader.addEventListener(Event.COMPLETE, preloader_onComplete);
		preloader.onLoaded();
	}
	
	private static function bitmapClass_onComplete(instance:BitmapData):Void {
		completed++;
		var classType = Type.getClass (instance);
		Reflect.setField(classType, "preload", instance);
		if (completed == total) begin();
	}

	private static function loader_onComplete(event:Event):Void {
		completed ++;
		preloader.onUpdate (completed, total);
		if (completed == total) begin();
		else nextLoader();
	}

	private static function preloader_onComplete(event:Event):Void {
		preloader.removeEventListener(Event.COMPLETE, preloader_onComplete);
		Lib.current.removeChild(preloader);
		preloader = null;
		if (untyped ::APP_MAIN::.main == null) {
			var o = new DocumentClass();
			if (Std.is(o, flash.display.DisplayObject)) Lib.current.addChild(cast o);
		} else untyped ::APP_MAIN::.main();
	}
}

@:build(DocumentClass.build())
class DocumentClass extends ::APP_MAIN:: {
	@:keep public function new() {
		super();
	}
}

#else // macro
import haxe.macro.Context;
import haxe.macro.Expr;

class DocumentClass {
	
	macro public static function build ():Array<Field> {
		var classType = Context.getLocalClass().get();
		var searchTypes = classType;
		while (searchTypes.superClass != null) {
			if(searchTypes.pack.length == 2
			&& searchTypes.pack[1] == "display"
			&& searchTypes.name == "DisplayObject") {
				var fields = Context.getBuildFields();
				var method = macro {
					return flash.Lib.current.stage;
				}
				fields.push( {
					name: "get_stage",
					access: [ APrivate, AOverride ],
					kind: FFun( {
						args: [],
						expr: method,
						params: [],
						ret: macro :flash.display.Stage
					}), pos: Context.currentPos() });
				return fields;
			}
			searchTypes = searchTypes.superClass.t.get();
		}
		return null;
	}
	
}
#end