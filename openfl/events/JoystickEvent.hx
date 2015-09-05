package openfl.events;
#if js
import openfl.events.Event;

class JoystickEvent extends Event
{
	@:extern inline static public var AXIS_MOVE:String = "axisMove";
	@:extern inline static public var BALL_MOVE:String = "ballMove";
	@:extern inline static public var BUTTON_DOWN:String = "buttonDown";
	@:extern inline static public var BUTTON_UP:String = "buttonUp";
	@:extern inline static public var HAT_MOVE:String = "hatMove";
	@:extern inline static public var DEVICE_ADDED:String = "deviceAdded";
	@:extern inline static public var DEVICE_REMOVED:String = "deviceRemoved";
	
	public var axis:Array<Float>;
	public var device:Int;
	public var id:Int;
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public var name:String; // not standardized
	
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, device:Int = 0, id:Int = 0, x:Float = 0, y:Float = 0, z:Float = 0) {
		super(type, bubbles, cancelable);
		this.device = device; this.id = id; this.x = x; this.y = y; this.z = z;
		axis = [x, y, z, 0, 0, 0];
		name = "";
	}
	
	override public function clone():Event {
		return new JoystickEvent(type, bubbles, cancelable, device, id, x, y, z);
	}
	
	public function toString():String {
		return "[JoystickEvent type=" + type + " bubbles=" + bubbles + " cancelable=" + cancelable + " device=" + device + " id=" + id + " x=" + x + " y=" + y + " z=" + z + "]";
	}
}
#end
