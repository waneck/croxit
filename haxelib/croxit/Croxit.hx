package croxit;
import croxit.core.Loader;

class Croxit 
{
	public static var OrientationPortrait = 1;
	public static var OrientationPortraitUpsideDown = 2;
	public static var OrientationLandscapeRight = 3;
	public static var OrientationLandscapeLeft = 4;
	public static var OrientationFaceUp = 5;
	public static var OrientationFaceDown = 6;
	
	public static var shouldRotateInterface(default, set_shouldRotateInterface):Int->Bool;
	
	private static function set_shouldRotateInterface(v:Int->Bool):Int->Bool
	{
		_set_should_rotate(v);
		return shouldRotateInterface = v;
	}
	
	public static function init():Void
	{
		_init();
	}
	
	public static function initAndStart(homePage:String, requestHandler:Void->Void):Void
	{
		_init_and_start(homePage, requestHandler);
	}
	
	public static function start(homePage:String, requestHandler:Void->Void)
	{
		_start(homePage, requestHandler);
	}
	
	public static function hide():Void
	{
		_hide();
	}
	
	public static function show():Void
	{
		_show();
	}
	
	public static function close():Void
	{
		_close();
	}
	
	public static function setErrorHandler(errorHandler:Error->String->Void)
	{
		_setErrorHandler(function(num, msg) errorHandler(Type.createEnumIndex(Error, num), msg));
	}
	
	public static function setAllowExternal(v:Bool):Void
	{
		_set_allow_external(v);
	}
	
	public static function callJS(js:String):String
	{
		return _call_js(js);
	}
	
	private static var _show = Loader.load("ngap_show", 0);
	private static var _hide = Loader.load("ngap_hide", 0);
	private static var _init = Loader.load("ngap_init", 0);
	private static var _set_should_rotate = Loader.load("ngap_set_should_autorotate", 1);
	private static var _start = Loader.load("ngap_start", 2);
	private static var _close = Loader.load("ngap_stop", 0);
	private static var _setErrorHandler = Loader.load("ngap_set_error_handler", 1);
	private static var _init_and_start = Loader.load("ngap_init_and_start", 2);
	private static var _set_allow_external = Loader.load("ngap_set_allow_external", 1);
	private static var _call_js = Loader.load("ngap_call_js", 1);
}