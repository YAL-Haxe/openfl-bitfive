package flash.net;
#if (js && !display)
interface IURLLoader extends flash.events.IEventDispatcher {
	var bytesLoaded:Int;
	var bytesTotal:Int;
	var data:Dynamic;
	var dataFormat(default, null):URLLoaderDataFormat;
	function close():Void;
	function load(request:URLRequest):Void;
}
#end
