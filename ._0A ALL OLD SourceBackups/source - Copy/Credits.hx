package;
import flixel.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.addons.text.FlxTextField;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
/**
 * ...
 * @original code maker: bbpanzu
 */
class Credits extends MusicBeatState
{

	public static var finishedCredits:Bool = false;

	var kadeLogo:FlxSprite;
	
	public function new() 
	{
		super();
	}
	
	
	override function create() 
	{
		FlxG.autoPause = false;
		//here again cause the credits still autopause for some reason

		super.create();

		FlxG.sound.playMusic(Paths.music("songending/My_Sense_Of_Reality","shared"),1.5,false);

		kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('KadeEngineLogo'));
		kadeLogo.x -= kadeLogo.width / 2;
		kadeLogo.y -= kadeLogo.height / 2 + 100;
		kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
		kadeLogo.antialiasing = true;
		kadeLogo.alpha = 0.3;
		add(kadeLogo);
		new FlxTimer().start(0.083125, function(tmr:FlxTimer)
		{
			kadeLogo.alpha += 0.03125;
			if (kadeLogo.alpha < 1)
			{
				tmr.reset(0.083125);
			}
			else
			{
				if (FlxG.save.data.flashing)
				{
					FlxG.camera.flash(FlxColor.WHITE, 1);
				}
				remove(kadeLogo);
				bgColor = 0xFF0e1926;
				var mural:FlxSprite = new FlxSprite();
							mural.loadGraphic(Paths.image("ending_background", "preload"));
				mural.antialiasing = true;
				add(mural);

				var cred:FlxText = new FlxText(0,720,640,"",32);
				cred.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF0c0f24, 2);
				cred.alignment = "center";
				cred.scrollFactor.set(1,1);
				var daCreds:String = Assets.getText(Paths.txt("data/credits"));
		
		
				var title:FlxTextFormat = new FlxTextFormat(0xFFffd200, true, false);
	
				var header:FlxTextFormat = new FlxTextFormat(0xFF61c8ff, false,false);
		
				var footnote:FlxTextFormat = new FlxTextFormat(0xFFaddbda, false,true,0);
		
				cred.applyMarkup(
					daCreds,
					[new FlxTextFormatMarkerPair(title, "@"),
					new FlxTextFormatMarkerPair(header, "^"),
					new FlxTextFormatMarkerPair(footnote, "#")
			
			
			
					]
				);
				cred.screenCenter(FlxAxes.X);
				add(cred);
		
				mural.scale.y = mural.scale.x = 1280 / mural.width;
				mural.updateHitbox();
				FlxTween.tween(FlxG.camera.scroll, {y: (mural.height - 720)}, (FlxG.sound.music.length / 1000) - 9, {ease:FlxEase.linear,onComplete:GTFO});
			}			
		});
	}
	
	public function GTFO(e:FlxTween):Void{
			
		
        if (PlayState.isStoryMode && FlxG.save.data.scoreScreen)
        {
			finishedCredits = true;
            FlxG.switchState(new ResultsScreenAfter());
        }
        else 
        {
            FlxG.switchState(new StoryMenuState());
        }
		
	};
	
}