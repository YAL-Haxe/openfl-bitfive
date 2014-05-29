/// Redirects `openfl.display.LineScaleMode` to `flash.display.LineScaleMode` (OpenFL2 feature)
package openfl.display;
#if js
typedef LineScaleMode = flash.display.LineScaleMode;
#end
