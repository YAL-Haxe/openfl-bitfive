/// Redirects `openfl.display.SpreadMethod` to `flash.display.SpreadMethod` (OpenFL2 feature)
package openfl.display;
#if js
typedef SpreadMethod = flash.display.SpreadMethod;
#end
