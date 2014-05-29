/// Redirects `openfl.display.StageDisplayState` to `flash.display.StageDisplayState` (OpenFL2 feature)
package openfl.display;
#if js
typedef StageDisplayState = flash.display.StageDisplayState;
#end
