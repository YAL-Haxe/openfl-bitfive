package openfl.display;
#if js
class InteractiveObject extends DisplayObject {
	public var doubleClickEnabled:Bool;
	public var focusRect:Dynamic;
	public var mouseEnabled:Bool;
	public var tabEnabled:Bool;
	public var tabIndex:Int;
	
	public function new() {
		super();
		tabEnabled = false;
		tabIndex = 0;
		mouseEnabled = doubleClickEnabled = true;
	}
	public function giveFocus():Void {
		component.focus();
	}
}
#end