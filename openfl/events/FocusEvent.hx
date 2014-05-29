/// Redirects `openfl.events.FocusEvent` to `flash.events.FocusEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef FocusEvent = flash.events.FocusEvent;
#end
