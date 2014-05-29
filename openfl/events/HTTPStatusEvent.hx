/// Redirects `openfl.events.HTTPStatusEvent` to `flash.events.HTTPStatusEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef HTTPStatusEvent = flash.events.HTTPStatusEvent;
#end
