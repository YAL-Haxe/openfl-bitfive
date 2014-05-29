/// Redirects `openfl.net.URLLoader` to `flash.net.URLLoader` (OpenFL2 feature)
package openfl.net;
#if js
typedef URLLoader = flash.net.URLLoader;
#end
