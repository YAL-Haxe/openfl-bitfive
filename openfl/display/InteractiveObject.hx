/// Redirects `openfl.display.InteractiveObject` to `flash.display.InteractiveObject` (OpenFL2 feature)
package openfl.display;
#if js
typedef InteractiveObject = flash.display.InteractiveObject;
#end
