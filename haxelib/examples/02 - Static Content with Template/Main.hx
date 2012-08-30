import croxit.Web;
import croxit.Output;

class Main
{
	
	public static function main()
	{
		switch(Web.getURI())
		{
			case "/page1":
				Output.println("These are the page 1's contents! <a href=\"index.html\">Go Back!</a>");
			case "/page2":
				Output.println("These are the page 2's contents! <a href=\"index.html\">Go Back!</a>");
			default:
				Output.println("Unrecognized " + Web.getURI() + "! <a href=\"index.html\">Go Back!</a>");
		}
	}
	
}