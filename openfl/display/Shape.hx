/// Redirects `openfl.display.Shape` to `flash.display.Shape` (OpenFL2 feature)
package openfl.display;
#if js
typedef Shape = flash.display.Shape;
#end
