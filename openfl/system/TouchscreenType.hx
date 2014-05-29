/// Redirects `openfl.system.TouchscreenType` to `flash.system.TouchscreenType` (OpenFL2 feature)
package openfl.system;
#if js
typedef TouchscreenType = flash.system.TouchscreenType;
#end
