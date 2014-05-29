/// Redirects `openfl.errors.Error` to `flash.errors.Error` (OpenFL2 feature)
package openfl.errors;
#if js
typedef Error = flash.errors.Error;
#end
