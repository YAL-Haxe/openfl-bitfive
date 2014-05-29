/// Redirects `openfl.system.Capabilities` to `flash.system.Capabilities` (OpenFL2 feature)
package openfl.system;
#if js
typedef Capabilities = flash.system.Capabilities;
#end
