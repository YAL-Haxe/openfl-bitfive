/// Redirects `openfl.net.URLRequestMethod` to `flash.net.URLRequestMethod` (OpenFL2 feature)
package openfl.net;
#if js
typedef URLRequestMethod = flash.net.URLRequestMethod;
#end
