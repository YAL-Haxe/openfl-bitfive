/// Redirects `openfl.geom.Transform` to `flash.geom.Transform` (OpenFL2 feature)
package openfl.geom;
#if js
typedef Transform = flash.geom.Transform;
#end
