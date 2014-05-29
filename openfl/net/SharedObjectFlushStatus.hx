/// Redirects `openfl.net.SharedObjectFlushStatus` to `flash.net.SharedObjectFlushStatus` (OpenFL2 feature)
package openfl.net;
#if js
typedef SharedObjectFlushStatus = flash.net.SharedObjectFlushStatus;
#end
