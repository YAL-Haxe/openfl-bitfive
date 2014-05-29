/// Redirects `openfl.text.TextField` to `flash.text.TextField` (OpenFL2 feature)
package openfl.text;
#if js
typedef TextField = flash.text.TextField;
#end
