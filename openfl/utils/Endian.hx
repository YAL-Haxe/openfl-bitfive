/// Redirects `openfl.utils.Endian` to `flash.utils.Endian` (OpenFL2 feature)
package openfl.utils;
#if js
typedef Endian = flash.utils.Endian;
#end
