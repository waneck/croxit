package croxit.utils;

#if !haxe3
typedef Bond = hsl.haxe.Bond;
#else
interface Bond
{
	public function destroy():Void;
}

class BaseBond<T> implements Bond
{
	public var next:BaseBond<T>;
	public var last:BaseBond<T>;

	public var value(default,null):T;

	public function new(val)
	{
		this.value = val;
	}

	public function destroy()
	{
		this.value = null;
		var next = this.next,
		    last = this.last;
		if (last != null)
		{
			last.next = next;
		}
		if (next != null)
		{
			next.last = last;
		}
		this.next = null;
		this.last = null;
	}
}
#end
