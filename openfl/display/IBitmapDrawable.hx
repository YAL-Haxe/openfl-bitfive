/// Redirects `openfl.display.IBitmapDrawable` to `flash.display.IBitmapDrawable` (OpenFL2 feature)
package openfl.display;
#if js
typedef IBitmapDrawable = flash.display.IBitmapDrawable;
#end
