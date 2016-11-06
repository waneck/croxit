package croxit.core.targets.base;
import croxit.core.Loader;
import croxit.utils.Path;
import haxe.io.Bytes;

#if iphone
@:sourceFile("./../../../../../native-project/native/iPhone/croxit.mm")
extern class NativeProject {
}
#end

@:cppFileCode('
extern "C" { int croxit_register_prims(); }

int do_register_croxit_prims() {
  return croxit_register_prims();
}
')
class Web
{
	/**
	 * Croxit will return true for isModNeko, as it emulates a web server
	 */
	public static var isModNeko(get_isModNeko, null) : Bool;

	private static function get_isModNeko():Bool
	{
		return true;
	}

	/**
		It will always return false for modTora, as it doesn't support the Tora api (yet)
	 */
	public static var isTora(default, null) : Bool;

	/**
		Sets the main entry point function used to handle requests. Setting it back to null will make croxit call the main function as the handler
	 */
	public static function cacheModule( f : Void -> Void ) : Void
	{
		_cache_module(f);
	}

	/**
		In the case of croxit, it won't do anything
	 */
	public static function flush() : Void
	{
		//do nothing
	}

	/**
		NOT IMPLEMENTED
	 */
	public static function getAuthorization() : { user : String, pass : String }
	{
		return null;
	}

	/**
		Retrieve a emulated request header value.
	 */
	public static function getClientHeader( k : String ) : String
	{
		return switch(k.toLowerCase())
		{
			case "host": "localapphost";
			case "user-agent": null;// TODO System.getUserAgent();
			case "referer": null;
			default: null;
		}
	}

	public static function getClientHeaders() : List<{ value : String, header : String }>
	{
		throw "not implemented";
		return null;
	}

	/**
		Always returns 127.0.0.16 for Croxit clients.
		It doesn't return the standard 127.0.0.1 so there is a difference with default localhost testing. 127.0.0.16 is a standard loopack IP also.
	 */
	public static function getClientIP() : String
	{
		return "127.0.0.16";
	}

	private static var allCookies:Map<String, Map<String, String>> = new Map();

	/**
		Returns an hashtable of all Cookies sent by the client. Modifying the hashtable will not modify the cookie, use setCookie instead.
	 */
	public static function getCookies() : Map<String, String>
	{

		var ret = new Map();
		function add(h:Map<String, String>)
		{
			for (k in h.keys())
			{
				ret.set(k, h.get(k));
			}
		}

		var curUri = Path.make(getURI(), true);

		var acc = "";
		for (dir in curUri.dirs())
		{
			acc += dir + "/";
			var cookies = allCookies.get(acc);
			if (cookies != null)
					add(cookies);
		}

		return ret;
	}

	/**
		Set a Cookie value in the HTTP headers. Same remark as setHeader. You may have to apply StringTools.urlEncode your value to prevent issues on retrieval.
	 */
	public static function setCookie( key : String, value : String, ?expire : Date, ?domain : String, ?path : String, ?secure : Bool ) : Void
	{
		if (path == null) path = "/";
		path = Path.make(path, true).toString();
		if (path.charCodeAt(path.length - 1) != '/'.code) path += '/';

		var cookies = allCookies.get(path);
		if (cookies == null)
		{
			cookies = new Map();
			allCookies.set(path, cookies);
		}

		cookies.set(key, value);
	}

	/**
		Get the current script directory in the local filesystem.
	 */
	public static function getCwd() : String
	{
#if iphone
		return _get_cwd();
#else
		return Sys.getCwd();
#end
	}

	/**
		Will always return "localapphost" for Croxit
	 */
	public static function getHostName() : String
	{
		return "localapphost";
	}

	/**
		Get the HTTP method used by the client. This api requires Neko 1.7.1+
	 */
	public static function getMethod() : String
	{
		return _get_method();
	}

	/**
		Returns an Array of Strings built using GET / POST values. If you have in your URL the parameters a=foo;a=hello;a5=bar;a3=baz then neko.Web.getParamValues("a") will return "foo","hello",null,"baz",null,"bar"
		Also, if you send checkboxes with name "myname[]", multiple checkbox values are available as getParamValues("myname")
	 */
	public static function getParamValues( param : String ) : Array<String>
	{
		//from neko.Web source code
		var reg = new EReg("^"+param+"(\\[|%5B)([0-9]*?)(\\]|%5D)=(.*?)$", "");
		var res = new Array<String>();
		var explore = function(data:String){
			if (data == null || data.length == 0)
				return;
			for (part in data.split("&")){
				if (reg.match(part)){
					var idx = reg.matched(2);
					var val = StringTools.urlDecode(reg.matched(4));
					if (idx == "")
						res.push(val);
					else
						res[Std.parseInt(idx)] = val;
				}
			}
		}
		explore(StringTools.replace(getParamsString(), ";", "&"));
		explore(getPostData());
		if (res.length == 0)
			return null;
		return res;
	}

	/**
		Returns the GET and POST parameters.
	 */
	public static function getParams() : Map<String, String>
	{
		var params = new Map();
		for (v in getParamsString().split("&"))
		{
			var vals = v.split("=");
			params.set(StringTools.urlDecode(vals[0]), StringTools.urlDecode(vals[1]));
		}

		for (v in getPostData().split("&"))
		{
			var vals = v.split("=");
			params.set(StringTools.urlDecode(vals[0]), StringTools.urlDecode(vals[1]));
		}

		return params;
	}

	/**
		Returns all the GET parameters String
	 */
	public static function getParamsString() : String
	{
		return _get_params();
	}

	/**
		Returns all the POST data.
	 */
	public static function getPostData() : String
	{
		return _post_params();
	}

	/**
		Returns the original request URL (before any server internal redirections)
	 */
	public static function getURI() : String
	{
		var ret = Path.make(_get_uri()).toString();
		if (ret.length == 0 || ret.charCodeAt(0) != '/'.code)
			return "/" + ret;
		return ret;
	}

	/**
		Write a message into the web server log file. This api requires Neko 1.7.1+
	 */
	public static function logMessage( v : String ) : Void
	{
		if (_log != null)
		{
			_log(Std.string(v));
		} else {
			#if cpp
			var v:Dynamic = v;
			untyped __global__.__hxcpp_println(v);
			#elseif neko
			untyped __dollar__print(v,"\n");
			#end
		}
	}

	public static function print(str:Dynamic)
	{
		if (Std.is(str, StringBuf)) {
			_print((str : StringBuf).toString());
		} else {
			_print(Std.string(str));
		}
	}

	/**
	 * NOT IMPLEMENTED
		Parse the multipart data. Call onPart when a new part is found with the part name and the filename if present and onData when some part data is readed.
		You can this way directly save the data on hard drive in the case of a file upload.
	 */
	public static function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void
	{
		throw "NOT IMPLEMENTED";
	}

	/**
		Get the multipart parameters as an hashtable. The data cannot exceed the maximum size specified. NOT IMPLEMENTED
	 */
	public static function getMultipart( maxSize : Int ) : Map<String, String>
	{
		throw "Not Implemented";
		return null;
	}

	/**
		Tell the client to redirect to the given url.
	 */
	public static function redirect( url : String ) : Void
	{
		_redirect(url);
	}

	/**
	 * NOT IMPLEMENTED
		Set an output header value. If some data have been printed, the headers have already been sent so this will raise an exception.
	 */
	public static function setHeader( h : String, v : String ) : Void
	{
		switch (h.toLowerCase())
		{
			case "content-type":
				var vs = v.split(";");
				_set_mime(StringTools.trim(vs[0]));

				var enc = vs[1];
				if (enc != null)
				{
					_set_encoding(StringTools.trim(enc.split("=")[1]));
				}
			default:
				throw "NOT IMPLEMENTED";
		}
	}

	/**
	 * NOT IMPLEMENTED
		Set the HTTP return code. Same remark as setHeader.
	 */
	public static function setReturnCode( r : Int ) : Void
	{
		//throw "NOT IMPLEMENTED";
	}

	private static var _cache_module = Loader.load("cx_cache_module", 1);
	private static var _get_method = Loader.load("cx_method", 0);
	private static var _get_params = Loader.load("cx_get_params", 0);
	private static var _post_params = Loader.load("cx_post_params", 0);
	private static var _get_uri = Loader.load("cx_uri", 0);
	private static var _redirect = Loader.load("cx_redirect", 1);
	private static var _print = Loader.load("cx_print", 1);
	private static var _set_mime = Loader.load("cx_set_mime", 1);
	private static var _set_encoding = Loader.load("cx_set_encoding", 1);
#if iphone
	private static var _get_cwd = Loader.load("cx_get_cwd", 0);
	private static var _log = Loader.load("cx_log", 1);
#end
}
