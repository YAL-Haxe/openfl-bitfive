/// Redirects `openfl.media.SoundChannel` to `flash.media.SoundChannel` (OpenFL2 feature)
package openfl.media;
#if js
typedef SoundChannel = flash.media.SoundChannel;
#end
