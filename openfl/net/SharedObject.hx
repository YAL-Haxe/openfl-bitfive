/// Redirects `openfl.net.SharedObject` to `flash.net.SharedObject` (OpenFL2 feature)
package openfl.net;
#if js
typedef SharedObject = flash.net.SharedObject;
#end
