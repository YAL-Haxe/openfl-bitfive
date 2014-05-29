/// Redirects `openfl.events.KeyboardEvent` to `flash.events.KeyboardEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef KeyboardEvent = flash.events.KeyboardEvent;
#end
