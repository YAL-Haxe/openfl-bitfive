/// Redirects `openfl.display.Stage` to `flash.display.Stage` (OpenFL2 feature)
package openfl.display;
#if js
typedef Stage = flash.display.Stage;
#end
