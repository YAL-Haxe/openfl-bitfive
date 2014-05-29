/// Redirects `openfl.text.Font` to `flash.text.Font` (OpenFL2 feature)
package openfl.text;
#if js
typedef Font = flash.text.Font;
#end
