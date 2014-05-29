/// Redirects `openfl.net.URLLoaderDataFormat` to `flash.net.URLLoaderDataFormat` (OpenFL2 feature)
package openfl.net;
#if js
typedef URLLoaderDataFormat = flash.net.URLLoaderDataFormat;
#end
