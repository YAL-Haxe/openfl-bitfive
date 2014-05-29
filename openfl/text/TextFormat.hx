/// Redirects `openfl.text.TextFormat` to `flash.text.TextFormat` (OpenFL2 feature)
package openfl.text;
#if js
typedef TextFormat = flash.text.TextFormat;
#end
