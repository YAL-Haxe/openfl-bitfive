/// Redirects `openfl.display.InterpolationMethod` to `flash.display.InterpolationMethod` (OpenFL2 feature)
package openfl.display;
#if js
typedef InterpolationMethod = flash.display.InterpolationMethod;
#end
