/// Redirects `openfl.ui.JoystickHandler` to `flash.ui.JoystickHandler` (OpenFL2 feature)
package openfl.ui;
#if js
typedef JoystickHandler = flash.ui.JoystickHandler;
#end
