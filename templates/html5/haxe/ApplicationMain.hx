#if !macro
#if (openfl_html5 && !flambe)
import ::APP_MAIN_PACKAGE::::APP_MAIN_CLASS::;
import haxe.Resource;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLLoaderDataFormat;
import flash.Lib;
import js.html.AudioElement;

class ApplicationMain {

	private static var completed:Int;
	private static var preloader:::PRELOADER_NAME::;
	private static var total:Int;

	public static var loaders:Map <String, Loader>;
	public static var urlLoaders:Map <String, URLLoader>;
	private static var loaderStack:Array<String>;
	private static var urlLoaderStack:Array<String>;

	public static function main() {
		completed = 0;
		loaders = new Map <String, Loader>();
		urlLoaders = new Map <String, URLLoader>();
		total = 0;
		
		flash.Lib.current.loaderInfo = flash.display.LoaderInfo.create (null);
		
		::if (WIN_WIDTH == "0")::::if (WIN_HEIGHT == "0")::flash.Lib.preventDefaultTouchMove();
		::end::::end::// preloader:
		Lib.current.addChild(preloader = new ::PRELOADER_NAME::());
		preloader.onInit();
		
		// assets
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
					var instance = Type.createInstance (type, [ 0, 0, true, 0x00FFFFFF, bitmapClass_onComplete ]);
				}
			}
		}
		
		if (total != 0) {
			loaderStack = [];
			for (p in loaders.keys()) loaderStack.push(p);
			urlLoaderStack = [];
			for (p in urlLoaders.keys()) urlLoaderStack.push(p);
			//
			for (i in 0 ... 8) nextLoader();
		} else begin();
	}
	
	private static function nextLoader() {
		if (loaderStack.length != 0) {
			var p:String = loaderStack.shift(),
				o:Loader = loaders.get(p);
			o.contentLoaderInfo.addEventListener("complete", loader_onComplete);
			o.load(new URLRequest(p));
		} else if (urlLoaderStack.length != 0) {
			var p:String = urlLoaderStack.shift(),
				o:URLLoader = urlLoaders.get(p);
			o.addEventListener("complete", loader_onComplete);
			o.load(new URLRequest(p));
		}
	}
	
	private static function loadFile(p:String):Void {
		loaders.set(p, new Loader());
		total++;
	}
	
	private static function loadBinary(p:String):Void {
		var o:URLLoader = new URLLoader();
		o.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoaders.set(p, o);
		total++;
	}
	
	private static function loadSound(p:String):Void {
		var i:Int = p.lastIndexOf("."), c:Dynamic = untyped flash.media.Sound, s:String,
			o:AudioElement, f:Dynamic->Void = null, q:String = 'canplaythrough';
		if (i == -1) return;
		if (!c.canPlayType || !c.canPlayType(p.substr(i + 1))) return;
		if (!c.library) c.library = new Map<String, AudioElement>();
		s = p.substr(0, i) + ".mp3";
		if (c.library.exists(s)) return;
		total++;
		c.library.set(s, o = untyped __js__("new Audio(p)"));
		f = function(e) {
			o.removeEventListener(q, f);
			preloader.onUpdate(++completed, total);
			if (completed == total) begin();
		};
		o.addEventListener(q, f);
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
		if (Reflect.field(::APP_MAIN::, "main") == null) {
			var mainDisplayObj = Type.createInstance(DocumentClass, []);
			if (Std.is(mainDisplayObj, flash.display.DisplayObject))
				flash.Lib.current.addChild(cast mainDisplayObj);
		} else {
			Reflect.callMethod(::APP_MAIN::, Reflect.field (::APP_MAIN::, "main"), []);
		}
	}
}

@:build(DocumentClass.build())
class DocumentClass extends ::APP_MAIN:: {
	@:keep public function new() {
		super();
	}
}

#else
import ::APP_MAIN_PACKAGE::::APP_MAIN_CLASS::;

class ApplicationMain {
	public static function main() {
		if (Reflect.field(::APP_MAIN::, "main") == null) {
			Type.createInstance(::APP_MAIN::, []);
		} else {
			Reflect.callMethod(::APP_MAIN::, Reflect.field(::APP_MAIN::, "main"), []);
		}
	}
}
#end
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