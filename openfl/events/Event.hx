/// Redirects `openfl.events.Event` to `flash.events.Event` (OpenFL2 feature)
package openfl.events;
#if js
typedef Event = flash.events.Event;
#end
