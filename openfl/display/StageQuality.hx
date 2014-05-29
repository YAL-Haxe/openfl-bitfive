/// Redirects `openfl.display.StageQuality` to `flash.display.StageQuality` (OpenFL2 feature)
package openfl.display;
#if js
typedef StageQuality = flash.display.StageQuality;
#end
