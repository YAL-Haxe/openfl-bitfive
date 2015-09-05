package flash.errors;
#if js

class Error {
	//
	public var errorID:Int;
	public var message:String;
	public var name:String;
	//
	public function new(message:String = "", id:Int = 0) {
		this.message = message;
		this.errorID = id;
	}
	
	public function getStackTrace():String {
		return haxe.CallStack.toString(haxe.CallStack.exceptionStack());
	}
	
	public function toString():String {
		return message != null ? message : "Error";
	}
}
#end