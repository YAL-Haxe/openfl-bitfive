package flash.display;
#if js
import flash.events.EventDispatcher;
import flash.events.EventWrapper;
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;
/**
 * 
 * @author YellowAfterlife
 */
class LoaderInfo extends EventDispatcher {
	public var bytes(default, null):ByteArray;
	public var bytesLoaded(default, null):Int;
	public var bytesTotal(default, null):Int;
	public var childAllowsParent(default, null):Bool;
	public var content(default, null):DisplayObject;
	public var contentType(default, null):String;
	public var frameRate(default, null):Float;
	public var height(default, null):Int;
	public var loader(default, null):ILoader;
	public var loaderURL(default, null):String;
	public var parameters(default, null):Dynamic<String>;
	public var parentAllowsChild(default, null):Bool;
	public var sameDomain(default, null):Bool;
	public var sharedEvents(default, null):IEventDispatcher;
	public var url(default, null):String;
	public var width(default, null):Int;
	//
	private function new() {
		super();
		bytesLoaded = bytesTotal = 0;
		childAllowsParent = true;
		parameters = { };
	}
	
	public static function create(?o:ILoader):LoaderInfo {
		var r = new LoaderInfo();
		if (o != null) r.loader = o; else r.url = "";
		return r;
	}
}
#end