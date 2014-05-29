/// Redirects `openfl.errors.IOError` to `flash.errors.IOError` (OpenFL2 feature)
package openfl.errors;
#if js
typedef IOError = flash.errors.IOError;
#end
