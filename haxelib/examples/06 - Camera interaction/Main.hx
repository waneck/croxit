
import croxit.remoting.Connection;
import croxit.camera.CameraSource;
/**
 *  This example shows how to use the croxit-camera plugin. 
 **/
class Main
{
	
	public static function main()
	{
		//let's add our remoting handler to the server context
		//we'll name it 'camera'
		croxit.remoting.Connection.addObject("camera", new CameraContext());
	
		//and we'll output some content
		croxit.Output.println(
			'<html><head>
				<script type="text/javascript" src="js.js"></script>
			</head><body>
				<input type="button" onClick="JSMain.buttonClicked()" value="Click me" />
				<div id="contents"></div>
			</body></html>');
	}
	
}

class CameraContext
{
	public function new()
	{
		
	}
	
	public function takePicture(source:CameraSource):Void
	{
		croxit.camera.Camera.getPicture(source, function(result) {
			switch(result)
			{
			/**
			 *  Successfully retrieved an image
			 **/
			case Success(img):
				//always make image be on the correct orientation
				var oldimg = img;
				img = img.normalizeRotation();
				oldimg.dispose();
				
				var path = Std.random(10000) + "-" + Std.random(10000);
				var fullpath = croxit.system.Info.getWritablePath(TempCache) + "/" + path + ".png";
				
				sys.io.File.saveBytes(fullpath, img.getCompressed(PNG));
				var resized = img.resize(img.width / 5, img.height / 5);
				img.dispose();
				img = null;
				
				var thumbpath = croxit.system.Info.getWritablePath(TempCache) + "/thumb_" + path + ".png";
				sys.io.File.saveBytes(thumbpath, resized.getCompressed(PNG));
				
				Connection.connect().js.showImages.call([ ["file://" + fullpath, "file://" + thumbpath] ]);
			/**
			 *  User cancelled the dialogue
			 **/
			case UserCancelled:
				Connection.connect().js.printText.call(["User cancelled"]);
			/**
			 *  Another confliting dialogue is currently being displayed
			 **/
			case DeviceBusy:
				Connection.connect().js.printText.call(["Device busy"]);
			/**
			 *  CameraSource type is not available
			 **/
			case UnavailableSource:
				Connection.connect().js.printText.call(["Unavailable Source"]);
			/**
			 *  Custom error
			 **/
			case Error(msg):
				Connection.connect().js.printText.call(["ERROR: " + msg]);
			}
		});
	}
}