/// Redirects `openfl.geom.Point` to `flash.geom.Point` (OpenFL2 feature)
package openfl.geom;
#if js
typedef Point = flash.geom.Point;
#end
