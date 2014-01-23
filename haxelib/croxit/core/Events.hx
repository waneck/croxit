package croxit.core;
import croxit.core.Loader;
#if haxe3
import haxe.ds.StringMap in Hash;
#end

class Events
{
	private static var events(get_events, null):Hash<Array<Dynamic>>;
	private static var activateEvents(get_activateEvents, null):Hash<Array<Bool->Void>>;

	private static function get_events()
	{
		return (events == null) ? (events = new Hash()) : events;
	}

	private static function get_activateEvents()
	{
		return (activateEvents == null) ? (activateEvents = new Hash()) : activateEvents;
	}

	private static function dispatchEvent(name:String, args:Array<Dynamic>):Void
	{
		var fns = events.get(name);

		if (args == null) args = [];
		if (fns != null)
			for (fn in fns)
			{
				Reflect.callMethod(null, fn, args);
			}
	}

	private static function hasHandlers(name:String):Bool
	{
		return events.exists(name);
	}

	static function __init__() : Void
	{
		var setEvHandler = Loader.load("ngap_set_global_event_handler", 1);
		if (setEvHandler == null)
			trace("WARNING: No event handler found. Events will be ignored");
		else
		{
			setEvHandler(dispatchEvent);
			var setActivateHandler = Loader.load("ngap_set_activate_event_handler", 1);
			if (setActivateHandler == null)
				trace("WARNING: No activate handler found. Events might not work correctly");
			else
				setActivateHandler(activateEvent);
		}

	}

	private static function activateEvent(eventName:String, add:Bool, fn:Bool->Void):Void
	{
		var ae = activateEvents.get(eventName);
		if (ae == null)
		{
			if (!add)
				return;
			ae = [];
			activateEvents.set(eventName, ae);
		}

		if (add)
		{
			ae.push(fn);
		} else {
			ae.remove(fn);
		}
	}


	public static function addHandler(eventName:String, handler:Dynamic):Void
	{
		var evArr = events.get(eventName);
		if (evArr == null)
		{
			var ae = activateEvents.get(eventName);
			if (ae != null)
				for (ae in ae) ae(true);
			evArr = [];
			events.set(eventName, evArr);
		}

		evArr.remove(handler);
		evArr.push(handler);
	}

	public static function removeHandler(eventName:String, handler:Dynamic):Void
	{
		var evArr = events.get(eventName);
		if (evArr != null)
		{
			if (evArr.remove(handler))
			{
				if (evArr.length == 0)
				{
					events.remove(eventName);
					var ae = activateEvents.get(eventName);
					if (ae != null)
						for (ae in ae) ae(false);
				}
			}
		}
	}

}
