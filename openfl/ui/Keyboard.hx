/// Redirects `openfl.ui.Keyboard` to `flash.ui.Keyboard` (OpenFL2 feature)
package openfl.ui;
#if js
typedef Keyboard = flash.ui.Keyboard;
#end
