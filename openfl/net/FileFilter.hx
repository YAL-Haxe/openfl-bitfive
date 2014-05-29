/// Redirects `openfl.net.FileFilter` to `flash.net.FileFilter` (OpenFL2 feature)
package openfl.net;
#if js
typedef FileFilter = flash.net.FileFilter;
#end
