/// Redirects `openfl.text.TextFieldAutoSize` to `flash.text.TextFieldAutoSize` (OpenFL2 feature)
package openfl.text;
#if js
typedef TextFieldAutoSize = flash.text.TextFieldAutoSize;
#end
