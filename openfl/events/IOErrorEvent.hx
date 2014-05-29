/// Redirects `openfl.events.IOErrorEvent` to `flash.events.IOErrorEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef IOErrorEvent = flash.events.IOErrorEvent;
#end
