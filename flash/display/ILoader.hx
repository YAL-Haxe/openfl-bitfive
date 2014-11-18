package flash.display;
#if (js && !display)
import flash.net.URLRequest;
import flash.utils.ByteArray;

interface ILoader {
	var content(default, null):DisplayObject;
	var contentLoaderInfo(default, null):LoaderInfo;
	function load(request:URLRequest, ?context:Dynamic):Void;
	function loadBytes(buffer:ByteArray):Void;
}
#end
