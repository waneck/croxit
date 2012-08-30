package croxit;

/**
 *  This class should replace Sys.print / Sys.println calls in a normal Haxe web application,
 *  in order to allow the content to be redirected to the WebView output.
 **/
class Output
{
	/**
	 *  Adds to the HTML content to be presented on the web view
	 **/
	public static function print(str:Dynamic):Void
	{
#if iphone
		croxit.Web.print(str);
#else
		Sys.print(str);
#end
	}
	
	/**
	 *  Adds to the HTML content to be presented on the web view
	 **/
	public static function println(str:Dynamic):Void
	{
		print(str + "\n");
	}
	
	/**
	 *  Forces the redirection of traces to the Web View output
	 **/
	public static function redirectTraces():Void
	{
		haxe.Log.trace = function (v:Dynamic, ?infos:haxe.PosInfos):Void
		{
			println(infos.fileName+":"+infos.lineNumber+": "+v);
		};
	}
}