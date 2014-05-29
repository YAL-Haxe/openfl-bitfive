/// Redirects `openfl.events.IEventDispatcher` to `flash.events.IEventDispatcher` (OpenFL2 feature)
package openfl.events;
#if js
typedef IEventDispatcher = flash.events.IEventDispatcher;
#end
