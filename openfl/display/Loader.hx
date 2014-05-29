/// Redirects `openfl.display.Loader` to `flash.display.Loader` (OpenFL2 feature)
package openfl.display;
#if js
typedef Loader = flash.display.Loader;
#end
