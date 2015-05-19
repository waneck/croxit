import croxit.js.Client;
import js.JQuery;
import croxit.remoting.AsyncConnection;

class JSMain
{
	
	public static function main()
	{
		//all croxit-specific interaction is only safe to be used
		//after deviceReady event
		Client.onDeviceReady(readyMain);
	}
	
	@:keep public static function buttonClicked()
	{
		new JQuery("#contents").append("<p>The button was clicked!</p>");
		AsyncConnection.connect().cpp.getCount.call([], function(count) {
			//by the time this is called, the server will already have called printSomeText function
			new JQuery("#contents").append("<p>The client just got the count from the server: " + count + "</p>");
		});
	}
	
	private static function readyMain():Void
	{
		//we'll create a new remoting context on the JS side
		//and name it "js"
		AsyncConnection.addObject("js", new ClientContext());
		new JQuery("#contents").append("<p>The device is ready to take requests!</p>");
	}
}

@:keep class ClientContext
{
	public function new()
	{
		
	}
	
	public function printSomeText()
	{
		new JQuery("#contents").append("<p>ClientContext.printSomeText() was called from the server!</p>");
	}
}