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
		new JQuery("#contents").html("<p>The button was clicked!</p>");
		AsyncConnection.connect().camera.takePicture.call([croxit.camera.CameraSource.Camera]);
	}
	
	private static function readyMain():Void
	{
		//we'll create a new remoting context on the JS side
		//and name it "js"
		AsyncConnection.addObject("js", new ClientContext());
		new JQuery("#contents").html("<p>The device is ready to take requests!</p>");
	}
}

@:keep class ClientContext
{
	public function new()
	{
		
	}
	
	public function printText(txt:String)
	{
		new JQuery("#contents").html("<p>" + txt + "</p>");
	}
	
	public function showImages(imgs:Array<String>)
	{
		new JQuery("#contents").html("");
		for (img in imgs)
			new JQuery("#contents").append("<p><img src=\"" + img + "\" /></p>");
	}
}