/// Redirects `openfl.text.AntiAliasType` to `flash.text.AntiAliasType` (OpenFL2 feature)
package openfl.text;
#if js
typedef AntiAliasType = flash.text.AntiAliasType;
#end
