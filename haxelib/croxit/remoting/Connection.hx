package croxit.remoting;
import croxit.core.Events;
import haxe.remoting.Context;
import haxe.Unserializer;
import croxit.Croxit;
import haxe.Serializer;

#if !js
//js can only call asynchronously

class Connection implements haxe.remoting.Connection
{
	static var __ctx:Context = new Context();
	
	var __path : Array<String>;
	
	function new(path) : Void 
	{
		this.__path = path;
	}
	
	private static function __init__():Void
	{
		Events.addHandler("cxconnect", doConnection);
	}
	
	public function call( params : Array<Dynamic> ) : Dynamic
	{
		var s = new Serializer();
		s.serialize(__path);
		s.serialize(params);
		var p = s.toString();
		var ret = Croxit.callJS("croxit.remoting.AsyncConnection.doConnection('" + StringTools.replace(p, "'", "\\'") + "');");
		
		if (ret == null)
			return null;
		return Unserializer.run(ret);
	}
	
	public function resolve( name : String ) : haxe.remoting.Connection
	{
		var c = new Connection(__path.copy());
		c.__path.push(name);
		return c;
	}
	
	public static function connect():Connection
	{
		return new Connection([]);
	}
	
	public static function addObject(name:String, obj:Dynamic, ?rec):Void
	{
		__ctx.addObject(name, obj, rec);
	}
	
	public static function setContext(ctx:Context):Void
	{
		__ctx = ctx;
	}
	
	private static function doConnection(request:String):Void
	{
		var ctx = __ctx;
		var regex = ~/%23([\-\d]+)%23/;
		
		var id:Null<Int> = null;
		var s = new Serializer();
		if (!regex.match(request) || (id = Std.parseInt(regex.matched(1))) == null)
		{
			s.serializeException("Invalid request");
		} else {
			var req = regex.matchedRight();
			var u = new Unserializer(req);
			try
			{
				var path = u.unserialize();
				var args = u.unserialize();
				s.serialize(ctx.call(path, args));
			}
			
			catch(e:Dynamic) 
			{
				trace('exception found: ' + e);
				s.serializeException(e);
			}
		}
		
		if (id != null && id >= 0)
			Croxit.callJS('croxit.js.Client.doCall(' + id + ', "' + StringTools.replace(s.toString(), "'", "\\'") + '");');
	}
}

#end