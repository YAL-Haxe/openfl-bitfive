/// Redirects `openfl.display.BitmapData` to `flash.display.BitmapData` (OpenFL2 feature)
package openfl.display;
#if js
typedef BitmapData = flash.display.BitmapData;
#end
