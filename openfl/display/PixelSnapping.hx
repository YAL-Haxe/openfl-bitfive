/// Redirects `openfl.display.PixelSnapping` to `flash.display.PixelSnapping` (OpenFL2 feature)
package openfl.display;
#if js
typedef PixelSnapping = flash.display.PixelSnapping;
#end
