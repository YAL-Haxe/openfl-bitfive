/// Redirects `openfl.display.Graphics` to `flash.display.Graphics` (OpenFL2 feature)
package openfl.display;
#if js
typedef Graphics = flash.display.Graphics;
#end
