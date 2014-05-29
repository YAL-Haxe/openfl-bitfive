/// Redirects `openfl.ui.Multitouch` to `flash.ui.Multitouch` (OpenFL2 feature)
package openfl.ui;
#if js
typedef Multitouch = flash.ui.Multitouch;
#end
