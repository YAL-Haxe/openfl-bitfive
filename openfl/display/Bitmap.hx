/// Redirects `openfl.display.Bitmap` to `flash.display.Bitmap` (OpenFL2 feature)
package openfl.display;
#if js
typedef Bitmap = flash.display.Bitmap;
#end
