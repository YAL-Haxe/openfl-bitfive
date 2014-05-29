/// Redirects `openfl.Lib` to `flash.Lib` (OpenFL2 feature)
package openfl;
#if js
typedef Lib = flash.Lib;
#end
