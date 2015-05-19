import croxit.Web;
import croxit.Output;

class Main
{
	
	public static function main()
	{
		//since index.html exists, this function won't be called until the user clicks in the links at the bottom
		//when he clicks, this function will be called and Web.getURI() will return the address of the clicked linked
		
		//BEWARE that the link in the .html file MUST be relative (e.g. no /page1 links), while we will receive absolute
		//links in response.
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