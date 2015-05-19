class ApplicationMain
{
	
	public static function main()
	{
		//nme.Lib.setPackage("::APP_COMPANY::", "::APP_FILE::", "::APP_PACKAGE::", "::APP_VERSION::");
		/*::if (sslCaCert != "")::
			nme.net.URLLoader.initialize(nme.installer.Assets.getResourceName("::sslCaCert::"));
		::end::*/
		
		croxit.Croxit.shouldRotateInterface = function(orientation:Int):Bool
		{
			::if (WIN_ORIENTATION == "portrait")::
			if (orientation == croxit.Croxit.OrientationPortrait || orientation == croxit.Croxit.OrientationPortraitUpsideDown)
			{
				return true;
			}
			return false;
			::elseif (WIN_ORIENTATION == "landscape")::
			if (orientation == croxit.Croxit.OrientationLandscapeLeft || orientation == croxit.Croxit.OrientationLandscapeRight)
			{
				return true;
			}
			return false;
			::else::
			return true;
			::end::
		}
		
		croxit.Croxit.initAndStart(null, function()
			{
				::APP_MAIN::.main();
			}/*,
			::WIN_WIDTH::, ::WIN_HEIGHT::,
			::WIN_FPS::,
			::WIN_BACKGROUND::,
			(::WIN_HARDWARE:: ? nme.Lib.HARDWARE : 0) |
			(::WIN_RESIZEABLE:: ? nme.Lib.RESIZABLE : 0) |
			(::WIN_ANTIALIASING:: == 4 ? nme.Lib.HW_AA_HIRES : 0) |
			(::WIN_ANTIALIASING:: == 2 ? nme.Lib.HW_AA : 0),
			"::APP_TITLE::"*/
		);
		
	}
	
	
	public static function getAsset(inName:String):Dynamic
	{
		::foreach assets::
		if (inName == "::id::")
		{
			::if (type == "image")::
			return nme.Assets.getBitmapData ("::id::");
			::elseif (type=="sound")::
			return nme.Assets.getSound ("::id::");
			::elseif (type=="music")::
			return nme.Assets.getSound ("::id::");
			::elseif (type== "font")::
			return nme.Assets.getFont ("::id::");
			::else::
			return nme.Assets.getBytes ("::id::");
			::end::
		}
		::end::
		return null;
	}
	
}