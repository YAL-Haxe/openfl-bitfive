/// Redirects `openfl.net.URLRequestHeader` to `flash.net.URLRequestHeader` (OpenFL2 feature)
package openfl.net;
#if js
typedef URLRequestHeader = flash.net.URLRequestHeader;
#end
