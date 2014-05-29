/// Redirects `openfl.media.Sound` to `flash.media.Sound` (OpenFL2 feature)
package openfl.media;
#if js
typedef Sound = flash.media.Sound;
#end
