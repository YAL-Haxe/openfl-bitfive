/// Redirects `openfl.text.FontStyle` to `flash.text.FontStyle` (OpenFL2 feature)
package openfl.text;
#if js
typedef FontStyle = flash.text.FontStyle;
#end
