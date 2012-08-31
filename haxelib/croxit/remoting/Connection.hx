package croxit.remoting;
import haxe.remoting.Context;
import haxe.Unserializer;
#if iphone
import croxit.core.Events;
import croxit.Croxit;
import haxe.Serializer;

#end

#if !js
//js can only call asynchronously

class Connection
{
	static var __ctx:Context = new Context();
	
	/**
	 *  Adds an object to the current remoting context
	 **/
	public static function addObject(name:String, obj:Dynamic, rec:Bool=false):Void
	{
		__ctx.addObject(name, obj, rec);
	}
	
	/**
	 *  Sets current remoting context
	 **/
	public static function setContext(ctx:Context):Void
	{
		__ctx = ctx;
	}
	
	/**
	 *  Provides a compatibility with Neko's HttpConnection:
	   *  For Croxit targets, this is equivalent to using setContext, and will always return false
	   *  For Web targets, it will handle the remoting request if possible,
	   *    and will return if the request was succesfully handled.
	 **/
	public static function handleRequest(?ctx:Context):Bool
	{
		#if iphone
		if (ctx != null)
			setContext(ctx);
		
		return false;
		
		#else
		return haxe.remoting.HttpConnection.handleRequest( (ctx != null) ? ctx : __ctx );
		
		#end
	}
	
	#if iphone
	public static function connect():haxe.remoting.Connection
	{
		return new Cnx([]);
	}
	
	private static function __init__():Void
	{
		Events.addHandler("cxconnect", doConnection);
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
	
	#end
}

#if iphone
private class Cnx implements haxe.remoting.Connection
{
	var __path : Array<String>;
	
	function new(path) : Void 
	{
		this.__path = path;
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
}

#end

#end