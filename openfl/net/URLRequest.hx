/// Redirects `openfl.net.URLRequest` to `flash.net.URLRequest` (OpenFL2 feature)
package openfl.net;
#if js
typedef URLRequest = flash.net.URLRequest;
#end
