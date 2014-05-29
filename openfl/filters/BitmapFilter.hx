/// Redirects `openfl.filters.BitmapFilter` to `flash.filters.BitmapFilter` (OpenFL2 feature)
package openfl.filters;
#if js
typedef BitmapFilter = flash.filters.BitmapFilter;
#end
