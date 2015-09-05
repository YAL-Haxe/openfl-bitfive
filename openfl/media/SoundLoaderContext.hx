package flash.media;
#if js
class SoundLoaderContext {
	//
	public var bufferTime:Float;
	public var checkPolicyFile:Bool;
	//
	public function new(bufferTime:Float = 0, checkPolicyFile:Bool = false) {
		this.bufferTime = bufferTime;
		this.checkPolicyFile = checkPolicyFile;
	}
}
#end