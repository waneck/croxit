package croxit.remoting;
import haxe.Unserializer;
import haxe.Serializer;
import haxe.remoting.Context;

//cpp can only call synchronously
#if js

class AsyncConnection implements haxe.remoting.AsyncConnection, implements Dynamic<haxe.remoting.AsyncConnection>
{
	static var __ctx:Context = new Context();
	
	var __data : { error : Dynamic -> Void, hasHandler:Bool };
	var __path : Array<String>;

	function new(data,path) {
		__data = data;
		__path = path;
	}

	public function resolve( name ) : haxe.remoting.AsyncConnection 
	{
		var c = new AsyncConnection(__data,__path.copy());
		c.__path.push(name);
		return c;
	}

	public function setErrorHandler(h) {
		__data.error = h;
		__data.hasHandler = true;
	}

	public function call( params : Array<Dynamic>, ?onResult : Dynamic -> Void ) 
	{
		if (__data.hasHandler || onResult != null)
		{
			var res = onResult;
			var error = __data.error;
			onResult = function(v:String)
			{
				try
				{
					var v = haxe.Unserializer.run(v);
					if (res != null)
						res(v);
				}
				
				catch(e:Dynamic)
				{
					if (error != null)
						error(e);
				}
			};
		}
		
		var s = new Serializer();
		s.serialize(__path);
		s.serialize(params);
		try
		{
			croxit.js.Client.send('cxconnect', s.toString(), onResult);
		}
		catch(e:Dynamic) { trace("error on " + e); }
	}

	public static function connect(url:String="/"):haxe.remoting.AsyncConnection
	{
		//TODO find a better way to detect the croxit environment
		if (croxit.js.Client.baseDir == null)
			return haxe.remoting.HttpAsyncConnection.urlConnect(url);
		else
			return new AsyncConnection({ error : function(e) untyped __js__("console.error")("(connection) " + e), hasHandler : false },[]);
	}
	
	public static function addObject(name:String, obj:Dynamic, ?rec):Void
	{
		__ctx.addObject(name, obj, rec);
	}
	
	public static function setContext(ctx:Context):Void
	{
		__ctx = ctx;
	}
	
	private static function doConnection(request:String):String
	{
		var ctx = __ctx;
		
		var s = new Serializer();
		var u = new Unserializer(request);
		try
		{
			var path = u.unserialize();
			var args = u.unserialize();
			s.serialize(ctx.call(path, args));
		}
		
		catch(e:Dynamic) 
		{
			s.serializeException(e);
		}
		
		return s.toString();
	}
}

#end