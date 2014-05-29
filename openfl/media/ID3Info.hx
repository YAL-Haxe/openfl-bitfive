/// Redirects `openfl.media.ID3Info` to `flash.media.ID3Info` (OpenFL2 feature)
package openfl.media;
#if js
typedef ID3Info = flash.media.ID3Info;
#end
