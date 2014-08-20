package croxit.js;
import haxe.Timer;

#if js

/**
 *  Basic JavaScript Client API
 **/
class Client
{
	static var deviceReady = [];

	static function __init__()
	{
		var __deviceReadyCalled = false;
		var window = #if haxe3 js.Browser.window #else js.Lib.window #end;
		var document:Dynamic = #if haxe3 js.Browser.document #else js.Lib.document #end;
		window.onload = function(_) {
			Timer.delay(function() {
				if (!__deviceReadyCalled)
				{
					__deviceReadyCalled = true;
					untyped __js__("
					var evt = document.createEvent('Event');
					evt.initEvent('deviceready', true, true);
					document.dispatchEvent(evt)");
					while (deviceReady.length > 0)
						deviceReady.pop()();
				}
			}, 500);
		};

		if (document.addEventListener)
		{
			document.addEventListener("deviceready", function() {
				if (__deviceReadyCalled) trace("Device ready was already called!");
				__deviceReadyCalled = true;
				while (deviceReady.length > 0)
					deviceReady.pop()();
			}, false);
		}
	}

	public static var baseDir(default, null):String;
	public static var writableDir(default, null):Null<String>;

	/**
	 *  Sends a message to the server
	 **/
	public static function send(protocol:String, msg:String, ?cback:Dynamic->Void):Void
	{
		throw "Error: Trying to send content before device is ready";
	}

	/**
	 *  Called when the device is ready for the JavaScript API to work correctly
	 **/
	public static function onDeviceReady(fn:Void->Void):Void
	{
		deviceReady.push(fn);
	}
}

#else

#error "Not available on server platforms"

#end
