import croxit.Web;
import croxit.Output;

class Main
{
	
	public static function main()
	{
		//let's add our remoting handler to the server context
		//we'll name it 'cpp'
		croxit.remoting.Connection.addObject("cpp", new ServerContext());
		
		//and we'll output some content
		Output.println(
			'<html><head>
				<script type="text/javascript" src="js.js"></script>
			</head><body>
				<div id="contents"></div>
				<input type="button" onClick="JSMain.buttonClicked()" value="Click me" />
			</body></html>');
	}
	
}

class ServerContext
{
	//Unlike some web-servers, we can save state by using static variables.
	private static var count:Int = 0;
	
	public function new()
	{
		
	}
	
	public function getCount()
	{
		var ret = count++;
		//before returning the value, we will call a function in the JavaScript context
		croxit.remoting.Connection.connect().js.printSomeText.call([]);
		
		return ret;
	}
}