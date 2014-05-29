/// Redirects `openfl.events.TimerEvent` to `flash.events.TimerEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef TimerEvent = flash.events.TimerEvent;
#end
