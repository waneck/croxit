package croxit.utils;

#if !haxe3
typedef DirectSignaler<T> = hsl.haxe.DirectSignaler<T>;
#else
import croxit.utils.Bond;

class DirectSignaler<T> implements Signaler<T>
{
	public var subject(default,null):{};
	var rejectNullData:Bool;
	var voids:BaseBond<Void->Void>;
	var binds:BaseBond<T->Void>;

	public function new(subject,?rejectNullData=true)
	{
		this.subject = subject;
		this.rejectNullData = rejectNullData;
		this.voids = new BaseBond(null);
		this.binds = new BaseBond(null);
	}

	public function bindVoid(listener:Void -> Void):Bond
	{
		var x = new BaseBond(listener);
		var h = voids;
		x.last = h;
		if (h.next != null)
		{
			x.next = h.next;
		}
		h.next = x;

		return x;
	}

	public function bind(listener:T -> Void):Bond
	{
		var x = new BaseBond(listener);
		var h = binds;
		x.last = h;
		if (h.next != null)
		{
			x.next = h.next;
		}
		h.next = x;

		return x;
	}

	public function unbind(listener:T -> Void):Void
	{
		var cur = binds.next;
		while (cur != null)
		{
			if (Reflect.compareMethods(listener,cur.value))
			{
				cur.destroy();
				return;
			}
			cur = cur.next;
		}
	}

	public function unbindVoid(listener:Void->Void):Void
	{
		var cur = voids.next;
		while (cur != null)
		{
			if (Reflect.compareMethods(listener,cur.value))
			{
				cur.destroy();
				return;
			}
			cur = cur.next;
		}
	}

	public function dispatch(?val:T)
	{
		if (val == null && rejectNullData) throw "Null data passed";
		var cur = binds.next;
		while (cur != null)
		{
			cur.value(val);
			cur = cur.next;
		}
		var cur = voids.next;
		while (cur != null)
		{
			cur.value();
			cur = cur.next;
		}
	}
}
#end
