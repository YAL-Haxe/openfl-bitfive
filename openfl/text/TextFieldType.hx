/// Redirects `openfl.text.TextFieldType` to `flash.text.TextFieldType` (OpenFL2 feature)
package openfl.text;
#if js
typedef TextFieldType = flash.text.TextFieldType;
#end
