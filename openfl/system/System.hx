/// Redirects `openfl.system.System` to `flash.system.System` (OpenFL2 feature)
package openfl.system;
#if js
typedef System = flash.system.System;
#end
