/// Redirects `openfl.display.BitmapDataChannel` to `flash.display.BitmapDataChannel` (OpenFL2 feature)
package openfl.display;
#if js
typedef BitmapDataChannel = flash.display.BitmapDataChannel;
#end
