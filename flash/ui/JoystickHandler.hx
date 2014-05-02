package flash.ui;
#if js
import flash.display.Stage;
import js.Browser;
import js.html.Gamepad;
import js.html.GamepadList;
import openfl.events.JoystickEvent;

/**
 * No support for balls and hats yet.
 * HTML5 Gamepad API requires to push button on the gamepad to set it to active state.
 * If you're using Firefox, open about:config and set dom.gamepad.enabled and dom.gamepad.non_standard_events.enabled to true
 * To allow Firefox handle input from your gamepad.
 */
class JoystickHandler
{
	public var stage:Stage;
	public var isSupported(get, null):Bool;
	public var gamepadsList:GamepadList;
	public var gamepadsCount(get, null):Int;
	public var joysticksList:Array<Joystick>;
	
	public function new(stage:Stage) {
		this.stage = stage;
		
		var isFirefox:Bool = Browser.navigator.userAgent.indexOf("Firefox") > -1;
		
		if (isFirefox) gamepadsList = Browser.navigator.getGamepads();
		else gamepadsList = untyped navigator.webkitGetGamepads();
		
		joysticksList = [for (i in 0...4) {
			id: i,
			gamepad: (i > gamepadsCount - 1)?null:gamepadsList[i],
			prevButtons: [for (j in 0...12) 0],
			buttons: [for (j in 0...12) 0],
			prevAxes: [for (j in 0...7) 0],
			axes: [for(j in 0...7) 0]
		}];
		
		stage.addEventListener(flash.events.Event.ENTER_FRAME, function(e) {
			if (!isFirefox) gamepadsList = untyped navigator.webkitGetGamepads();
			if (gamepadsList == null) return;
			for (v in joysticksList) {
				v.gamepad = (v.id > gamepadsCount - 1)?null:gamepadsList[v.id];
				if (v.gamepad == null) continue;
				
				// buttons
				var n = v.gamepad.buttons.length;
				var p = v.buttons.copy();
				for (i in 0...n) {
					if (!isFirefox) v.buttons[i] = v.gamepad.buttons[i];
					else v.buttons[i] = untyped v.gamepad.buttons[i].value;
					
					if (v.buttons[i] == 1 && v.prevButtons[i] == 0) {
						var event = new JoystickEvent(JoystickEvent.BUTTON_DOWN, false, false, v.gamepad.index, i);
						event.axis = v.gamepad.axes;
						if (stage.hasEventListener(JoystickEvent.BUTTON_DOWN)) stage.dispatchEvent(event);
					}
					if (v.buttons[i] == 0 && v.prevButtons[i] == 1) {
						var event = new JoystickEvent(JoystickEvent.BUTTON_UP, false, false, v.gamepad.index, i);
						event.axis = v.gamepad.axes;
						if (stage.hasEventListener(JoystickEvent.BUTTON_UP)) stage.dispatchEvent(event);
					}
				}
				v.prevButtons = p;
				
				// axes
				var n = v.gamepad.axes.length;
				var p = v.axes.copy();
				for (i in 0...n) {
					v.axes[i] = Math.round(v.gamepad.axes[i]);
					
					if (v.axes[i] != v.prevAxes[i]) {
						var event = new JoystickEvent(JoystickEvent.AXIS_MOVE, false, false, v.gamepad.index, i);
						event.axis = v.axes;
						stage.dispatchEvent(event);
					}
				}
				v.prevAxes = p;
			}
		});
		
		// Firefox
		Browser.window.addEventListener("gamepadconnected", function(e) {
			var g:Gamepad = untyped e.gamepad;
			if (stage.hasEventListener(JoystickEvent.DEVICE_ADDED)) stage.dispatchEvent(new JoystickEvent(JoystickEvent.DEVICE_ADDED, false, false, g.index));
			updateList(g);
		});
		
		Browser.window.addEventListener("gamepaddisconnected", function(e) {
			var g:Gamepad = untyped e.gamepad;
			if (stage.hasEventListener(JoystickEvent.DEVICE_REMOVED)) stage.dispatchEvent(new JoystickEvent(JoystickEvent.DEVICE_REMOVED, false, false, g.index));
			updateList(g);
		});
	}
	
	private function updateList(g:Gamepad) {
		gamepadsList = untyped navigator.getGamepads() || navigator.webkitGetGamepads();
		joysticksList[g.index].gamepad = g;
	}
	
	private function get_isSupported():Bool {
		return untyped navigator.getGamepads || !!navigator.webkitGetGamepads || !!navigator.webkitGamepads;
	}
	
	inline private function get_gamepadsCount():Int {
		if (gamepadsList == null) return 0;
		return gamepadsList.length;
	}
}

typedef Joystick = {
	id:Int,
	gamepad:Gamepad,
	prevButtons:Array<Float>,
	buttons:Array<Float>,
	prevAxes:Array<Float>,
	axes:Array<Float>
}
#end