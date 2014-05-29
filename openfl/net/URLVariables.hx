/// Redirects `openfl.net.URLVariables` to `flash.net.URLVariables` (OpenFL2 feature)
package openfl.net;
#if js
typedef URLVariables = flash.net.URLVariables;
#end
