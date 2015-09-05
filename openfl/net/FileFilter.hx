package flash.net;
#if js
class FileFilter {
	public var description:String;
	public var extension:String;
	public var macType:String;
	public function new(d:String, x:String, ?m:String):Void {
		description = d;
		extension = x;
		macType = m;
	}
}
#end