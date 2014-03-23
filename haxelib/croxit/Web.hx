package croxit;
#if haxe3
import haxe.ds.StringMap in Hash;
#end

#if false
import haxe.io.Bytes;

extern class Web
{
	/**
	 * Croxit will return true for isModNeko, as it emulates a web server
	 */
	public static var isModNeko(get_isModNeko, null) : Bool;

	/**
		It will always return false for modTora, as it doesn't support the Tora api (yet)
	 */
	public static var isTora(default, null) : Bool;

	/**
		Sets the main entry point function used to handle requests. Setting it back to null will make croxit call the main function as the handler
	 */
	public static function cacheModule( f : Void -> Void ) : Void;

	/**
		In the case of croxit, it won't do anything
	 */
	public static function flush() : Void;

	/**
		NOT IMPLEMENTED
	 */
	public static function getAuthorization() : { user : String, pass : String };

	/**
		Retrieve a emulated request header value.
	 */
	public static function getClientHeader( k : String ) : String;

	public static function getClientHeaders() : List<{ value : String, header : String }>;

	/**
		Always returns 127.0.0.16 for Croxit clients.
		It doesn't return the standard 127.0.0.1 so there is a difference with default localhost testing. 127.0.0.16 is a standard loopack IP also.
	 */
	public static function getClientIP() : String;

	/**
		Returns an hashtable of all Cookies sent by the client. Modifying the hashtable will not modify the cookie, use setCookie instead.
	 */
	public static function getCookies() : Hash<String>;

	/**
		Set a Cookie value in the HTTP headers. Same remark as setHeader. You may have to apply StringTools.urlEncode your value to prevent issues on retrieval.
	 */
	public static function setCookie( key : String, value : String, ?expire : Date, ?domain : String, ?path : String, ?secure : Bool ) : Void;

	/**
		Get the current script directory in the local filesystem.
	 */
	public static function getCwd() : String;

	/**
		Will always return "localapphost" for Croxit
	 */
	public static function getHostName() : String;

	/**
		Get the HTTP method used by the client. This api requires Neko 1.7.1+
	 */
	public static function getMethod() : String;

	/**
		Returns an Array of Strings built using GET / POST values. If you have in your URL the parameters a=foo;a=hello;a5=bar;a3=baz then neko.Web.getParamValues("a") will return "foo","hello",null,"baz",null,"bar"
		Also, if you send checkboxes with name "myname[]", multiple checkbox values are available as getParamValues("myname")
	 */
	public static function getParamValues( param : String ) : Array<String>;

	/**
		Returns the GET and POST parameters.
	 */
	public static function getParams() : Hash<String>;

	/**
		Returns all the GET parameters String
	 */
	public static function getParamsString() : String;

	/**
		Returns all the POST data.
	 */
	public static function getPostData() : String;

	/**
		Returns the original request URL (before any server internal redirections)
	 */
	public static function getURI() : String;

	/**
		Write a message into the web server log file. This api requires Neko 1.7.1+
	 */
	public static function logMessage( v : String ) : Void;

	/**
	 * NOT IMPLEMENTED
		Parse the multipart data. Call onPart when a new part is found with the part name and the filename if present and onData when some part data is readed.
		You can this way directly save the data on hard drive in the case of a file upload.
	 */
	public static function parseMultipart( onPart : String -> String -> Void, onData : Bytes -> Int -> Int -> Void ) : Void;

	/**
		Get the multipart parameters as an hashtable. The data cannot exceed the maximum size specified. NOT IMPLEMENTED
	 */
	public static function getMultipart( maxSize : Int ) : Hash<String>;

	/**
		Tell the client to redirect to the given url.
	 */
	public static function redirect( url : String ) : Void;

	/**
	 * NOT IMPLEMENTED
		Set an output header value. If some data have been printed, the headers have already been sent so this will raise an exception.
	 */
	public static function setHeader( h : String, v : String ) : Void;

	/**
	 * NOT IMPLEMENTED
		Set the HTTP return code. Same remark as setHeader.
	 */
	public static function setReturnCode( r : Int ) : Void;
}

#elseif iphone
typedef Web = croxit.core.targets.base.Web;

#elseif cpp
typedef Web = cpp.Web;

#elseif neko
typedef Web = neko.Web;

#elseif php
typedef Web = php.Web;

#end
