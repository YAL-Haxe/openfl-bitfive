/// Redirects `openfl.events.EventDispatcher` to `flash.events.EventDispatcher` (OpenFL2 feature)
package openfl.events;
#if js
typedef EventDispatcher = flash.events.EventDispatcher;
#end
