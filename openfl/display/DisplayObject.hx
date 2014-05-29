/// Redirects `openfl.display.DisplayObject` to `flash.display.DisplayObject` (OpenFL2 feature)
package openfl.display;
#if js
typedef DisplayObject = flash.display.DisplayObject;
#end
