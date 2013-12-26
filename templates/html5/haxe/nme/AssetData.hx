package nme;


import openfl.Assets;


class AssetData {
	//
	public static var className:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var library:Map<String, LibraryType> = new Map<String, LibraryType>();
	public static var path:Map<String, String> = new Map<String, String>();
	public static var type:Map<String, AssetType> = new Map<String, AssetType>();
	//
	private static var initialized:Bool = false;
	
	public static function initialize ():Void {
		if (!initialized) {
			::if (assets != null)::::foreach assets::::if (type == "font")::className.set ("::id::", nme.NME_::flatName::);
			::else::path.set("::id::", "::resourceName::");
			::end::type.set("::id::", "::type::".toUpperCase());
			::end::::end::
			::if (libraries != null)::::foreach libraries::library.set ("::name::", "::type::");
			::end::::end::
			initialized = true;
		}
	}
}

::foreach assets::::if (type == "font")::class NME_::flatName:: extends flash.text.Font { }
::end::::end::
