/// Redirects `openfl.ui.Mouse` to `flash.ui.Mouse` (OpenFL2 feature)
package openfl.ui;
#if js
typedef Mouse = flash.ui.Mouse;
#end
