package openfl.display;
#if js
class MovieClip extends Sprite implements Dynamic<Dynamic> {
	public var enabled:Bool;
	public var currentFrame(get, null):Int;
	public var framesLoaded(get, null):Int;
	public var totalFrames(get, null):Int;
	//
	private var qIndex:Int;
	private var qTotal:Int;
	//
	public function new() {
		super();
		enabled = true;
		qIndex = qTotal = 0;
		loaderInfo = LoaderInfo.create();
	}
	
	public function gotoAndPlay(v:Dynamic, ?o:String):Void { }
	public function gotoAndStop(v:Dynamic, ?o:String):Void { }
	public function nextFrame():Void { }
	public function play():Void { }
	public function prevFrame():Void { }
	public function stop():Void { }
	//
	private function get_currentFrame():Int { return qIndex; }
	private function get_framesLoaded():Int { return qTotal; }
	private function get_totalFrames():Int { return qTotal; }
}
#end