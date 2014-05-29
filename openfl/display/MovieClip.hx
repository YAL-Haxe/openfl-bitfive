/// Redirects `openfl.display.MovieClip` to `flash.display.MovieClip` (OpenFL2 feature)
package openfl.display;
#if js
typedef MovieClip = flash.display.MovieClip;
#end
