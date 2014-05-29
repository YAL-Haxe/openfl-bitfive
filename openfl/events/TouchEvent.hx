/// Redirects `openfl.events.TouchEvent` to `flash.events.TouchEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef TouchEvent = flash.events.TouchEvent;
#end
