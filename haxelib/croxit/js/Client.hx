package croxit.js;

#if js

/**
 *  Basic JavaScript Client API
 **/
class Client
{
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
		untyped js.Lib.document.addEventListener("deviceready", fn, false);
	}
}

#else

#error "Not available on server platforms"

#end