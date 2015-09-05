package openfl.errors;
#if js
class IOError extends Error {
	public function new(message:String = "") {
		super(message);
	}
}
#end