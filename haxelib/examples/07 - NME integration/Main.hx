import croxit.Web;

/**
 *  This example shows how to use the croxit-nme plugin. 
 **/
class Main
{
	
	public static function main()
	{
		switch(Web.getURI())
		{
			case "/nmeStart":
				//we'll open the NME window if the url == /nmeStart
				croxit.nme.NME.start(1024,768,Ball.init);
			default:
				//Otherwise display link
				croxit.Output.println(
					'<html><body>
						<a href="nmeStart">Start NME</a><br />
					</body></html>');
		}
	
		
	}
	
}

class Ball extends nme.display.Sprite
{
	static var isInit = false;
	public static function init()
	{
		if (!isInit)
		{
			var b = new Ball();
			
			b.addEventListener(flash.events.MouseEvent.CLICK, function (_) {
				nekogap.plugins.nme.NME.stop();
				trace("stopped");
			});
			nme.Lib.current.addChild(b);
			
			isInit = true;
		}
		
		//haxe.Timer.delay(function() {trace("CLOSING"); nekogap.plugins.nme.NME.stop();}, 1000);
	}
	
	public function new():Void
	{
		super();
		this.graphics.beginFill(0xFF00FF);
		this.graphics.drawCircle(0,0,500);
		this.graphics.endFill();
		
		this.addEventListener(flash.events.Event.ENTER_FRAME, enterFrame);
		
	}
	
	private function enterFrame(_):Void
	{
		if (this.y >= nme.Lib.current.stage.stageHeight)
		{
			this.y = 0;
		}
		
		this.y += 10;
	}
}