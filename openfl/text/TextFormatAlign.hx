/// Redirects `openfl.text.TextFormatAlign` to `flash.text.TextFormatAlign` (OpenFL2 feature)
package openfl.text;
#if js
typedef TextFormatAlign = flash.text.TextFormatAlign;
#end
