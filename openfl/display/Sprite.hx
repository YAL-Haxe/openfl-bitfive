/// Redirects `openfl.display.Sprite` to `flash.display.Sprite` (OpenFL2 feature)
package openfl.display;
#if js
typedef Sprite = flash.display.Sprite;
#end
