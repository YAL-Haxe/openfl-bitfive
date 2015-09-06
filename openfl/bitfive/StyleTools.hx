package openfl.bitfive;

import js.html.CSSStyleDeclaration;

class StyleTools {
	
	/**
	 * Sets a CSS property with no priority parameter requirement.
	 * @param	self
	 * @param	name
	 * @param	value	
	 */
	public static inline function setPropertyNp(self:CSSStyleDeclaration, name:String, ?value:String) {
		self.setProperty(name, value, null);
	}
	
	/**
	 * Sets a CSS property and the given vendor-specific prefixed versions.
	 * @param	self
	 * @param	name
	 * @param	value
	 * @param	flags	{ 1: (no prefix), 2: webkit, 4: 
	 */
	public static function setProperties(self:CSSStyleDeclaration, name:String, ?value:String, flags:Int = 0x1f) {
		inline function proc(flag:Int, prefix:String) {
			if (cast (flags & flag)) setPropertyNp(self, prefix + name, value);
		}
		proc(0x01, "");
		proc(0x02, "-webkit-");
		proc(0x04, "-moz-");
		proc(0x08, "-ms-");
		proc(0x10, "-o-");
		proc(0x20, "-khtml-");
	}
}