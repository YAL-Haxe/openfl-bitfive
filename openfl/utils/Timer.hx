/// Redirects `openfl.utils.Timer` to `flash.utils.Timer` (OpenFL2 feature)
package openfl.utils;
#if js
typedef Timer = flash.utils.Timer;
#end
