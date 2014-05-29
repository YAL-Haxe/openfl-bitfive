/// Redirects `openfl.media.SoundTransform` to `flash.media.SoundTransform` (OpenFL2 feature)
package openfl.media;
#if js
typedef SoundTransform = flash.media.SoundTransform;
#end
