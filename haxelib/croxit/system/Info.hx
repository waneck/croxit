package croxit.system;
import croxit.core.Loader;

/**
 *  Miscellaneous system information
 **/
class Info
{

	private static var writableDocumentPath:Null<String>;
	private static var writableDataPath:Null<String>;
	private static var writableCachePath:Null<String>;
	
	/**
	 *  Resets all cookies / stored browser information
	 **/
	public static function resetBrowser():Void
	{
		untyped Web.allCookies = new Hash();
	}
	
	/**
	 *  Returns a writable path for an asset, if it exists.
	 *  
	 *  Otherwise, if the file exists in the non-writable 'www' folder,
	 *  it will copy to a writable place and return its path.
	 **/
	public static function getWritablePathOrCopy(relativePath:String, ?info:Null<PathInfo>):String
	{
		if (info == null) info = AppData;
		return _ngap_get_writable_path_or_write(relativePath, Type.enumIndex(info));
	}
	
	/**
	 *  Gets the writable base path
	 **/
	public static function getWritablePath(?info:Null<PathInfo>):String
	{
		if (info == null) info = AppData;
		switch(info)
		{
			case AppDocument:
				if (writableDocumentPath == null)
				{
					return writableDocumentPath = _ngap_get_writable_path(0) + "/";
				} else {
					return writableDocumentPath;
				}
			case AppData:
				if (writableDataPath == null)
				{
					return writableDataPath = _ngap_get_writable_path(1) + "/";
				} else {
					return writableDataPath;
				}
			case TempCache:
				if (writableCachePath == null)
				{
					return writableCachePath = _ngap_get_writable_path(2) + "/";
				} else {
					return writableCachePath;
				}
		}
		
	}
	
	static var _ngap_get_writable_path = Loader.load("ngap_get_writable_path", 1);
	static var _set_allow_external = Loader.load("ngap_set_allow_external", 1);
	static var _ngap_get_writable_path_or_write = Loader.load("ngap_get_writable_path_or_write", 2);
}

enum PathInfo
{
	AppDocument;
	AppData;
	TempCache;
}