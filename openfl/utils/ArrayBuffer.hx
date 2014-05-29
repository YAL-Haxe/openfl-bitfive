/// Redirects `openfl.utils.ArrayBuffer` to `flash.utils.ArrayBuffer` (OpenFL2 feature)
package openfl.utils;
#if js
typedef ArrayBuffer = flash.utils.ArrayBuffer;
#end
