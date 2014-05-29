/// Redirects `openfl.text.FontType` to `flash.text.FontType` (OpenFL2 feature)
package openfl.text;
#if js
typedef FontType = flash.text.FontType;
#end
