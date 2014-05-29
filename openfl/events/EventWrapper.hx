/// Redirects `openfl.events.EventWrapper` to `flash.events.EventWrapper` (OpenFL2 feature)
package openfl.events;
#if js
typedef EventWrapper = flash.events.EventWrapper;
#end
