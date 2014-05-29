/// Redirects `openfl.utils.UInt` to `flash.utils.UInt` (OpenFL2 feature)
package openfl.utils;
#if js
typedef UInt = flash.utils.UInt;
#end
