/// Redirects `openfl.events.MouseEvent` to `flash.events.MouseEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef MouseEvent = flash.events.MouseEvent;
#end
