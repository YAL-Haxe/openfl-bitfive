/// Redirects `openfl.events.SecurityErrorEvent` to `flash.events.SecurityErrorEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef SecurityErrorEvent = flash.events.SecurityErrorEvent;
#end
