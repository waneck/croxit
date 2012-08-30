package croxit.core;
#if neko
import neko.Lib;
import neko.Sys;
import neko.io.Process;
#elseif cpp
import cpp.Lib;
import cpp.Sys;
import cpp.io.Process;
#end
 

class Loader
{
	
	private static var moduleInit = false;
	private static var moduleName = "";
	
	
	#if (iphone || android)
		
		
		public static function load(func:String, args:Int):Dynamic
		{
			return Lib.load("croxit", func, args);
		}
		
		
		public static function loadExt(lib:String, func:String, args:Int):Dynamic
		{
			return Lib.load(lib, func, args);
		}
		
	#else
	
		static public function findHaxeLib(inLib:String)
		{
			try
			{
				var proc = new Process("haxelib", ["path", inLib]);
				if (proc != null)
				{
					var stream = proc.stdout;
					try
					{
						while(true)
						{
							var s = stream.readLine();
							if (s.substr(0, 1) != "-")
							{
								stream.close();
								proc.close();
								loaderTrace("Found haxelib " + s);
								return s;
							}
						}
					}
					catch (e:Dynamic) { }
					stream.close();
					proc.close();
				}
			}
			catch (e:Dynamic) { }
			
			return "";
		}
		
		
		public static function load(func:String, args:Int):Dynamic
		{
			if (moduleInit)
			{
				return Lib.load(moduleName, func, args);
			}

			moduleInit = true;
			moduleName = "croxit";
			
			// Look in current directory first (for installed apps)
			var result:Dynamic = tryLoad("./croxit", func, args);
			if (result == null)
				result = tryLoad(".\\croxit", func, args);
			
			// Try standard neko path (NEKOPATH variable, system path/library paths)
			if (result == null)
				result = tryLoad("croxit", func, args);
			// Try haxelib
			if (result == null)
			{
				var slash = (sysName().substr(7).toLowerCase() == "windows") ? "\\" : "/";
				var haxelib = findHaxeLib("croxit");
				if (haxelib != "")
				{
					result = tryLoad(haxelib + slash + "ndll" + slash + sysName() + slash + "croxit", func, args);
					// Try haxelib64 ...
					
					if (result == null)
						result = tryLoad(haxelib + slash + "ndll" + slash + sysName() + "64" + slash + "croxit", func, args);
				}
			}
			
			loaderTrace("Result : " + result );
			
			#if neko
			loadNekoAPI();
			#end
			
			return result;
		}
		
		private static var libs = new Hash();
		
		public static function loadExt(lib:String, func:String, args:Int):Dynamic
		{
			if (libs.exists(lib))
			{
				return Lib.load(libs.get(lib), func, args);
			}

			var moduleName = lib;
			function tryLoad(inName:String, func:String, args:Int):Dynamic
			{
				try
				{
					var result =  Lib.load(inName, func, args);
					if (result != null)
					{
						loaderTrace("Got result " + inName);
						moduleName = inName;
						return result;
					}
				}
				catch (e:Dynamic)
				{
					loaderTrace("Failed to load : " + inName);
				}
				return null;
			}
			
			// Look in current directory first (for installed apps)
			var result:Dynamic = tryLoad("./" + lib, func, args);
			if (result == null)
				result = tryLoad(".\\" + lib, func, args);
			
			// Try standard neko path (NEKOPATH variable, system path/library paths)
			if (result == null)
				result = tryLoad(lib, func, args);
			// Try haxelib
			if (result == null)
			{
				var slash = (sysName().substr(7).toLowerCase() == "windows") ? "\\" : "/";
				var haxelib = findHaxeLib("croxit");
				if (haxelib != "")
				{
					result = tryLoad(haxelib + slash + "ndll" + slash + sysName() + slash + lib, func, args);
					// Try haxelib64 ...
					
					if (result == null)
						result = tryLoad(haxelib + slash + "ndll" + slash + sysName() + "64" + slash + lib, func, args);
				}
			}
			
			libs.set(lib, moduleName);
			
			loaderTrace("Result : " + result );
			
			#if neko
			if (!moduleInit)
				loadNekoAPI();
			#end
			
			return result;
		}
		
		
		#if neko
		public static function loadNekoAPI()
		{
			var init =  load("neko_init", 5);
			if (init != null)
			{
				loaderTrace("Found nekoapi @ " + moduleName );
				init(function(s) return new String(s), function(len:Int) { var r = []; if (len > 0) r[len - 1] = null; return r; }, null, true, false);
			}
			else
				throw("Could not find NekoAPI interface.");
		}
		#end
		
		
		public static function loaderTrace(inStr:String)
		{
			// Problems with initialization order in cpp...
			#if cpp
			var get_env = Lib.load("std", "get_env", 1);
			var debug = (get_env("NGAP_LOAD_DEBUG") != null);
			#else
			var debug = (Sys.getEnv("NGAP_LOAD_DEBUG")!=null);
			#end
			
			if (debug)
				Lib.println(inStr);
		}
		
		
		static function sysName()
		{
			// Problems with initialization order in cpp...
			#if cpp
			var sys_string = Lib.load("std", "sys_string", 0);
			return sys_string();
			#else
			return Sys.systemName();
			#end
		}
		
		
		public static function tryLoad(inName:String, func:String, args:Int):Dynamic
		{
			try
			{
				var result =  Lib.load(inName, func, args);
				if (result != null)
				{
					loaderTrace("Got result " + inName);
					moduleName = inName;
					return result;
				}
			}
			catch (e:Dynamic)
			{
				loaderTrace("Failed to load : " + inName);
			}
			return null;
		}
		
	#end
	
}