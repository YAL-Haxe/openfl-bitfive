/// Redirects `openfl.display.BlendMode` to `flash.display.BlendMode` (OpenFL2 feature)
package openfl.display;
#if js
typedef BlendMode = flash.display.BlendMode;
#end
