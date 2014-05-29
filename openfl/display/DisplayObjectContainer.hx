/// Redirects `openfl.display.DisplayObjectContainer` to `flash.display.DisplayObjectContainer` (OpenFL2 feature)
package openfl.display;
#if js
typedef DisplayObjectContainer = flash.display.DisplayObjectContainer;
#end
