/// Redirects `openfl.net.FileReference` to `flash.net.FileReference` (OpenFL2 feature)
package openfl.net;
#if js
typedef FileReference = flash.net.FileReference;
#end
