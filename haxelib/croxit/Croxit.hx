package croxit;
import croxit.core.Loader;
import croxit.core.Errors;

/**
 *  This is the main Croxit manager, and is used to manipulate the main WebView context.
 **/
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
	
	/**
	 *  Only initializes a webview, without setting a request handler nor a home page
	 **/
	public static function init():Void
	{
		_init();
	}
	
	/**
	 *  Initializes and starts with the home page passed as a parameter.
	 *  The request handler is the main function to be called each time a request to a non-existing 
	 **/
	public static function initAndStart(homePage:String, requestHandler:Void->Void):Void
	{
		_init_and_start(homePage, requestHandler);
	}
	
	/**
	 *  Starts the webview with the home page and request handler passed as paremeters
	 **/
	public static function start(homePage:String, requestHandler:Void->Void)
	{
		_start(homePage, requestHandler);
	}
	
	/**
	 *  Hides the main webview
	 **/
	public static function hide():Void
	{
		_hide();
	}
	
	/**
	 *  Shows the main webview
	 **/
	public static function show():Void
	{
		_show();
	}
	
	/**
	 *  Closes the main webview
	 **/
	public static function close():Void
	{
		_close();
	}
	
	/**
	 *  Sets a handler for any webview-related errors
	 **/
	public static function setErrorHandler(errorHandler:Error->String->Void)
	{
		_setErrorHandler(function(num, msg) errorHandler(Type.createEnumIndex(Error, num), msg));
	}
	
	/**
	 *  Sets if the web view should allow external (non-local) addresses
	 **/
	public static function setAllowExternal(v:Bool):Void
	{
		_set_allow_external(v);
	}
	
	/**
	 *  Calls a JavaScript string inside the main webview.
	 *  This is only guaranteed to work after the request is complete (e.g. inside an event / remoting handler)
	 **/
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