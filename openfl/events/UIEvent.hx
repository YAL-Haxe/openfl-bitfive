package openfl.events;
#if js
import openfl.display.InteractiveObject;
/// Non-standard. Mouse and touch events are based on this.
class UIEvent extends Event {
	public var altKey(default, null):Bool;
	public var ctrlKey(default, null):Bool;
	public var shiftKey(default, null):Bool;
	// coordinates:
	public var localX:Float;
	public var localY:Float;
	public var stageX:Float;
	public var stageY:Float;
	//
	public var relatedObject:InteractiveObject;
}
#end