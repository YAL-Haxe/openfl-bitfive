/// Redirects `openfl.errors.ArgumentError` to `flash.errors.ArgumentError` (OpenFL2 feature)
package openfl.errors;
#if js
typedef ArgumentError = flash.errors.ArgumentError;
#end
