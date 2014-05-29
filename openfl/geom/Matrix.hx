/// Redirects `openfl.geom.Matrix` to `flash.geom.Matrix` (OpenFL2 feature)
package openfl.geom;
#if js
typedef Matrix = flash.geom.Matrix;
#end
