/// Redirects `openfl.display.StageAlign` to `flash.display.StageAlign` (OpenFL2 feature)
package openfl.display;
#if js
typedef StageAlign = flash.display.StageAlign;
#end
