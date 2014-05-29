/// Redirects `openfl.media.SoundLoaderContext` to `flash.media.SoundLoaderContext` (OpenFL2 feature)
package openfl.media;
#if js
typedef SoundLoaderContext = flash.media.SoundLoaderContext;
#end
