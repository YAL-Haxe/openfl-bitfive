/// Redirects `openfl.display.LoaderInfo` to `flash.display.LoaderInfo` (OpenFL2 feature)
package openfl.display;
#if js
typedef LoaderInfo = flash.display.LoaderInfo;
#end
