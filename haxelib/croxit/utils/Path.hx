package croxit.utils;

class Path 
{
	private var _dirs:Array<String>;
	public var file(default, null):Null<String>;
	public var extension(default, null):Null<String>;
	public var isAbsolute(default, null):Bool;
	
	public function dirs()
	{
		return _dirs.iterator();
	}
	
	/**
	 * Sandboxed will determine if we shall eliminate special characters from the path location
	 * Normally if we receive the path from an untrusted source, sandboxed should be on. If we are dealing with
	 * the client's filesystem and the source is trusted (e.g. config file or client's own machine input), sandboxed
	 * may be off.
	 */
	private var sandboxed:Bool;
	private var sandboxLevel:Int;
	private var separator:String;
	
	private function new()
	{
		
	}
	
	public static function make(path:String, ?sandboxed = true, ?sandboxLevel = 0) 
	{
		var npath = path;
		var me = new Path();
		me.sandboxed = sandboxed;
		
		var c1 = path.indexOf("/");
		var c2 = path.indexOf("\\");
		
		me.separator = "/";
		if ( c2 > 0 && (c1 < 0 || c2 < c1) )
		{
			me.separator = "\\";
			path = StringTools.replace(path, "\\", "/");
		}
		
		//check if is absolute
		me.isAbsolute = false;
		me._dirs = path.split("/");
		
		if (me._dirs[0].length == 0)
		{
			me.isAbsolute = true;
		} else {
			var dirRegex = ~/([A-Za-z]:)/;
			if (dirRegex.match(me._dirs[0]))
			{
				if (dirRegex.matched(1) == me._dirs[0])
				{
					me._dirs[0] = me._dirs[0].toUpperCase();
					me.isAbsolute = true;
				} else {
					throw "Invalid path: '" + npath + "'";
				}
			}
		}
		
		var file = me._dirs.pop();
		if (file != null)
		{
			var cp = file.lastIndexOf(".");
			if( cp != -1 ) {
				me.extension = file.substr(cp+1);
				me.file = file.substr(0,cp);
			} else {
				me.extension = null;
				me.file = file;
			}
		}
		
		var i = 0;
		var newDirs = [];
		var check = null;
		
		if (sandboxed) check = ~/([0-9A-Za-z%\-_\.:]*)/;
		
		for (dir in me._dirs)
		{
			if (dir.length == 0 && i == 0)
			{
				newDirs.push("");
			} else {
				if (dir.charCodeAt(0) == ".".code)
				{
					if (dir.length == 1)
						continue;
					
					if (dir == "..")
					{
						newDirs.pop();
						if (--sandboxLevel < 0 && sandboxed)
							throw "'" + npath + "' is outside of the sandbox path";
					}
					continue;
				} else {
					sandboxLevel++;
				}
				
				if (sandboxed && (!check.match(dir) || check.matched(1) != dir))
				{
					throw "Invalid path: '" + npath + "'";
				}
				
				newDirs.push(dir);
			}
			
			i++;
		}
		
		me.sandboxLevel = sandboxLevel;
		me._dirs = newDirs;
		
		return me;
	}
	
	public function add(path:Path, ?allowAbsolute:Bool=false):Path
	{
		if (path.isAbsolute)
		{
			if (allowAbsolute)
				return path;
			else
				throw "'" + path.toString() + "' is outside of the sandbox path";
		}
		
		var dirs = this._dirs.copy();
		if (file != null)
		{
			var f = file;
			if (extension != null)
			{
				f += "." + extension;
			}
			
			dirs.push(f);
		}
		
		for (dir in path._dirs)
		{
			dirs.push(dir);
		}
		
		var ret = new Path();
		ret._dirs = dirs;
		ret.file = path.file;
		ret.extension = path.extension;
		ret.isAbsolute = isAbsolute;
		ret.separator = separator;
		ret.sandboxed = sandboxed;
		//sandboxLevel todo
		
		return ret;
	}
	
	public function withoutFile():Path
	{
		var ret = new Path();
		ret._dirs = this._dirs;
		ret.isAbsolute = this.isAbsolute;
		ret.separator = this.separator;
		ret.sandboxed = this.sandboxed;
		ret.sandboxLevel = this.sandboxLevel;
		
		return ret;
	}
	
	public function toString():String
	{
		var buf = new StringBuf();
		if (_dirs.length > 0)
		{
			buf.add(_dirs.join(separator));
			buf.add(separator);
		}
		
		if (file != null)
		{
			buf.add(file);
			if (extension != null)
			{
				buf.add(".");
				buf.add(extension);
			}
		}
		
		return buf.toString();
	}
}