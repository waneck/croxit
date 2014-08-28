package croxit.utils;

#if !haxe3
typedef Signaler<T> = hsl.haxe.Signaler<T>;
#else
interface Signaler<T>
{
	public var subject(default, null):{};
	public function bindVoid(listener:Void -> Void):Bond;
	public function bind(listener:T -> Void):Bond;
	public function unbind(listener:T -> Void):Void;
	public function unbindVoid(listener:Void->Void):Void;
	public function dispatch(?data:T):Void;
}
#end
