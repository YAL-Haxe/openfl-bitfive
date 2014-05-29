/// Redirects `openfl.events.TextEvent` to `flash.events.TextEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef TextEvent = flash.events.TextEvent;
#end
