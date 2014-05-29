/// Redirects `openfl.events.ErrorEvent` to `flash.events.ErrorEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef ErrorEvent = flash.events.ErrorEvent;
#end
