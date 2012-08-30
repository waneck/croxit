package croxit.js;

#if js

class Client
{
	public static var baseDir(default, null):String;
	public static var writableDir(default, null):Null<String>;
	
	public static function send(protocol:String, msg:String, ?cback:Dynamic->Void):Void
	{
		throw "Error: Trying to send content before device is ready";
	}
	
	public static function onDeviceReady(fn:Void->Void):Void
	{
		untyped js.Lib.document.addEventListener("deviceready", fn, false);
	}
}

#else

#error "Not available on server platforms"

#end