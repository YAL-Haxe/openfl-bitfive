/// Redirects `openfl.events.ProgressEvent` to `flash.events.ProgressEvent` (OpenFL2 feature)
package openfl.events;
#if js
typedef ProgressEvent = flash.events.ProgressEvent;
#end
