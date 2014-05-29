/// Redirects `openfl.display.CapsStyle` to `flash.display.CapsStyle` (OpenFL2 feature)
package openfl.display;
#if js
typedef CapsStyle = flash.display.CapsStyle;
#end
