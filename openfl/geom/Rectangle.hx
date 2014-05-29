/// Redirects `openfl.geom.Rectangle` to `flash.geom.Rectangle` (OpenFL2 feature)
package openfl.geom;
#if js
typedef Rectangle = flash.geom.Rectangle;
#end
