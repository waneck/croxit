import croxit.Web;
import sys.FileSystem;
import croxit.Output;

#if cpp
import cpp.db.Sqlite;
#else
import sys.db.Sqlite;
#end

class Main
{
	
	public static function main()
	{
		//for mobile, we need to request a writable location, since
		//the assets folder is sometimes read-only
		var basePath = #if cpp croxit.system.Info.getWritablePath(AppData) #else Web.getCwd() #end;
		
		var path = basePath + "/db.db3";
		
		var exists = FileSystem.exists(path);
		var db = Sqlite.open(path);
		
		if (!exists)
		{
			//create the sqlite table
			db.request("CREATE TABLE Visits ( name TEXT UNIQUE, nvisits INTEGER );");
		}
		
		presentContent(db);
	}
	
	private static function presentContent(db):Void
	{
		//get params if any data was submitted
		var params = Web.getParams();
		
		var buf = new StringBuf();
		//create form data
		buf.add("<html><body>");
		buf.add('<form method="POST" action="">');
		buf.add('<input type="text" name="uname" value="');
			if (params.exists("uname"))
			{
				buf.add(params.get("uname"));
			} else {
				buf.add("Please enter your name");
			}
		buf.add('" /> <br />');
		buf.add('<input type="submit" value="Submit" /> <br />');
		
		//if name was entered
		if (params.exists("uname"))
		{
			var name = params.get("uname");
			buf.add("Hello, " + name + "! <br />");
			//see if entry exists
			var entry = db.request("SELECT * FROM Visits WHERE name=" + db.quote(name)).next();
			if (entry == null)
			{
				buf.add("This is your first time here!");
				db.request("insert into Visits (name, nvisits) VALUES ("+db.quote(name) + "," + 0 + ");");
			} else {
				db.request("update Visits SET nvisits = nvisits + 1");
				buf.add("You've visited here " + ++entry.nvisits + " times! </br>");
			}
		}
		
		buf.add("</form></body></html>");
		
		Output.print(buf);
	}
	
}