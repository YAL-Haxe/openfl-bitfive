/// Redirects `openfl.display.StageScaleMode` to `flash.display.StageScaleMode` (OpenFL2 feature)
package openfl.display;
#if js
typedef StageScaleMode = flash.display.StageScaleMode;
#end
