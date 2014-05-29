/// Redirects `openfl.utils.ByteArray` to `flash.utils.ByteArray` (OpenFL2 feature)
package openfl.utils;
#if js
typedef ByteArray = flash.utils.ByteArray;
#end
