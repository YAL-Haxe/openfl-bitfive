/// Redirects `openfl.display.JointStyle` to `flash.display.JointStyle` (OpenFL2 feature)
package openfl.display;
#if js
typedef JointStyle = flash.display.JointStyle;
#end
