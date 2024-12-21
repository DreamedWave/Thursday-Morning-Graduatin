package;

import openfl.Lib;
import openfl.Assets;
import Conductor.BPMChangeEvent;
//import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUIState;

/*enum MouseSupportType
{
	HOVER;
	SCROLL;
}*/

class MusicBeatMenu extends FlxUIState
{
	public var curKey:Int = 1;

	public var tipText:FlxText;
	public var tipTextBG:FlxSprite;
	public var camUI:FlxCamera;
	public var camLoad:FlxCamera;
	public var confirmSound:FlxFilteredSound;//to make it persist heehee
	//public var mouseHoverGrp:FlxTypedGroup<FlxObject>; //More robust Mouse Support'
	//public var hasMouseSupport:Bool = false;
	
	private var curStep:Int = -4;
	private var curBeat:Int = -1;
	private var curDecimalBeat:Float = -1;
	private var curDecimalStep:Float = -4;
	private var controls(get, never):Controls;

	public static var currentColor = 0;
	var skippedFrames = 0;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		TimingStruct.clearTimings();
		
		if (FlxG.save.data.pauseOnUnfocus && !FlxG.autoPause)
			FlxG.autoPause = true;
		if (!FlxG.save.data.pauseOnUnfocus && FlxG.autoPause)
			FlxG.autoPause = false;

		super.create();
	}

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0 , 0)
	];

	override function update(elapsed:Float)
	{
		#if !debug
		if (!FlxG.save.data.fullscreen && FlxG.fullscreen)
			FlxG.fullscreen = false;
		else if (FlxG.save.data.fullscreen && !FlxG.fullscreen)
			FlxG.fullscreen = true;
		#else
		if (FlxG.fullscreen)
			FlxG.fullscreen = false;
		#end

		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep >= 0)
				stepHit();
		}

		super.update(elapsed);

		//Bloat feature that I will probably remove
		if (FlxG.save.data.fpsRain)
		{
			if (skippedFrames >= 6)
			{
				if (currentColor >= array.length)
					currentColor = 0;
				(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
				currentColor++;
				skippedFrames = 0;
			}
			else
				skippedFrames++;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecimalBeat = curDecimalStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit:Float = 0;
		if (lastChange != null && lastChange.type == 'tween')
		{
			//please lord god, please work
			//FUCK YEA BABYYYYY IT WORKS!!!!!!!
			shit = ((Conductor.songPosition - FlxG.save.data.offset) - lastChange.songTime) / Conductor.stepCrochet;
		}
		else
			shit = ((Conductor.songPosition - FlxG.save.data.offset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecimalStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		if (FlxG.sound.music.playing && FlxG.save.data.weekUnlocked == 1 && !FreeplayState.freeplayMusicPlaying)
		{
			if (curBeat % 4 == 0)
				curKey += 1;
		}
		
		if (curKey > 4 || curKey < 1)
			curKey = 1;
	}
	
	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	public function splitTextIntoArray(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);
		var textRows:Array<String> = fullText.split('\n');
		var allTextsArray:Array<Array<String>> = [];

		for (i in textRows)
		{
			allTextsArray.push(i.split('--'));
		}

		return allTextsArray;
	}

	//More robust mouse support [WIP]
	/*public function addMouseSupport(?type:MouseSupportType = HOVER)
	{
		hasMouseSupport = true;

		switch (type)
		{
			case SCROLL:
				//do nada
			default: 
				//var topScroller:FlxSprite //add flx sprite that is the width of the screen and the height of the idk make it settable or something idk also the enum is prob unecessary ok i gotta gho now my laptop boutta die bye
		}
	}*/

	public function getTips(menuTipID:String = ''):String
	{
		var tip:String = '';
		
		switch (menuTipID)
		{
			case "MenuNav":
				tip = "[↑] [↓] or [MOUSE] - change selection.";
			case "MenuConfirm": 
				tip ="[ENTER] or [L. CLICK] - confirm selection.";
			case "MenuCancel":
				tip = "[ESC] or [R. CLICK] - go back.";
			case "MenuPrvNxtKeyboard":
				tip = "[←] [→] - change selection.";
			case "MenuPrvNxtMouse":
				tip = "[L. Click] - change selection.";
			case "MenuOptToggleKeyboard":
				tip = "[Enter] - toggle option.";
			case "MenuOptPrvNextKeyboard":
				tip = "[←] [→] - change option.";
			case "MenuPrvNxtDiff":
				tip = "[←] [→] or [MOUSE] - change difficulty.";
			case "MenuPrvNxtDiffKeys":
				tip = "[←] [→] - change difficulty.";
			case "MenuPrvNxtDiffMouse":
				tip = "[L. Click] - change difficulty.";
			case "MenuFrplyPrevSongKeyboard":
				tip = "[SHIFT] - preview song chart.";
			default:
				//there miiiight be a better way of doing this but like nah i aint gonna spend dev time on it cause like yhis wont really impact performance much
		}

		return tip;
	}

	public function setUpTips(initialTip:String = '', textPlacement:Int = 0)
	{
		if (tipText == null)
		{
			tipText = new FlxText(0, FlxG.height, Std.int((FlxG.width - 90)), '', 12);
			tipText.alpha = 0;
			tipText.scrollFactor.set();
			tipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, CENTER);
			tipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
			tipText.antialiasing = true;
			switch (initialTip)
			{
				case 'MainMenu':
					tipText.text = getTips('MenuNav') + '\n' + getTips('MenuCancel') + '   |   ' + getTips('MenuConfirm');
				case 'StoryMenu':
					tipText.text = getTips('MenuNav') + '   |   ' + getTips('MenuPrvNxtDiff') + '\n' + getTips('MenuCancel') + '        |        ' + getTips('MenuConfirm');
				case 'FreePlay':
					tipText.text = getTips('MenuNav') + '   |   ' + getTips('MenuPrvNxtDiffKeys') + '\n' + getTips('MenuCancel') + '      |      ' + getTips('MenuConfirm'); // + '   |   ' + getTips('MenuFrplyPrevSongKeyboard');
			}
			tipText.updateHitbox();
			tipText.screenCenter(X);

			tipTextBG = new FlxSprite(-30, FlxG.height).makeGraphic((Std.int((FlxG.width - 80))), Std.int(tipText.height * 2), 0xFF02001c);
			tipTextBG.alpha = 0;
			tipTextBG.scrollFactor.set();
			tipTextBG.screenCenter(X);

			add(tipTextBG);
			add(tipText);

			switch (textPlacement)
			{
				default:
					//Bottom Left (Default)
					FlxTween.tween(tipText,{alpha: 1, y: FlxG.height - tipText.height - 4}, 1.25,{ease: FlxEase.smoothStepOut, startDelay: 0.2});
					FlxTween.tween(tipTextBG,{alpha: 0.5, y: FlxG.height - tipText.height - 10}, 1.25, {ease: FlxEase.smoothStepOut});
				case 1:
					//Top Left
					FlxTween.tween(tipText,{alpha: 1, y: tipText.height + 5}, 1.25, {ease: FlxEase.elasticInOut, startDelay: 0.2});
					FlxTween.tween(tipTextBG,{alpha: 0.5, y: tipText.height + 10}, 1.25, {ease: FlxEase.elasticInOut});
			}
		}
	}
}
