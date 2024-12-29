package;

import flixel.math.FlxRandom;
#if sys
import sys.io.File;
#end
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
//import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
//import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import lime.media.openal.AL;
import lime.app.Application;
import openfl.Lib;
import openfl.ui.Keyboard;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.events.KeyboardEvent;
import shaders.WiggleEffect;
import flixel.util.FlxAxes;

using StringTools;

//Quick and dirty state for me to test shit
class TestState extends MusicBeatState
{
	var tauntRating:FlxText;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camEXT:FlxCamera;
	private var camFollow:FlxObject;

	var stageOverlay:FlxSprite;
	var stageFloor:FlxSprite;
	var stageBG:FlxSprite;

	var defaultCamZoom:Float = 1;

	private var camFollowSpeed:Float = 1; //The higher the number is, the faster the camera moves
	var frameRateCap:Int = 1;

	public static var instance:TestState;

	var funnyAlphabetTesterBold:Alphabet;
	var funnyAlphabetTesterSkinny:Alphabet;
	var blackScreen:FlxSprite;

	var pageNumberLOL:FlxText;

	override public function create():Void
	{
		if (FlxG.save.data.pauseOnUnfocus && !FlxG.autoPause)
			FlxG.autoPause = true;
		if (!FlxG.save.data.pauseOnUnfocus && FlxG.autoPause)
			FlxG.autoPause = false;

		instance = this;
		
		//Bruh this caused me so much stress - my ass thought openal sound integration was fucking up sht but it was just this LMFAO
		//FlxG.game.soundTray.silent = true;

		//Update Saves
		SaveData.initSave();

		if (FlxG.save.data.fpsCap > 290)
		{
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
			FlxG.save.data.fpsCap = 290;
		}

		bgColor = 0xFF000000;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camEXT = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camEXT.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camEXT);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		stageBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('graduation/graduation_back', 'week1'));
		stageBG.antialiasing = FlxG.save.data.antialiasing;
		stageBG.scrollFactor.set(0.5, 0.5);
		stageBG.screenCenter();
		add(stageBG);

		stageFloor = new FlxSprite(-650, 600).loadGraphic(Paths.image('graduation/graduation_front', 'week1'));
		stageFloor.setGraphicSize(Std.int(stageFloor.width * 1.1));
		stageFloor.updateHitbox();
		stageFloor.antialiasing = FlxG.save.data.antialiasing;
		stageBG.screenCenter();
		add(stageFloor);

		stageOverlay = new FlxSprite(-490, -300).loadGraphic(Paths.image('graduation/graduation_overlay', 'week1'));
		stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.9));
		stageOverlay.updateHitbox();
		stageOverlay.antialiasing = FlxG.save.data.antialiasing;
		stageOverlay.screenCenter();
		add(stageOverlay);

		var instructionsLOL:FlxText = new FlxText(0, FlxG.height, FlxG.width - 50);
		instructionsLOL.text = "[[/]] Change Zoom | [1/2] Change FG Parralax | [3/4] Change BG Parralax | [5-8] CamShake\n[ENTER] Switch CamShake Mode | [SPACE] BumpCam | [ESC] Return";
		instructionsLOL.antialiasing = FlxG.save.data.antialiasing;
		instructionsLOL.setFormat(Paths.font("playtime.ttf"), 28, CENTER);
		instructionsLOL.y -= instructionsLOL.height + 10;
		instructionsLOL.screenCenter(X);
		instructionsLOL.color = FlxColor.WHITE;
		instructionsLOL.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
		instructionsLOL.cameras = [camEXT];
		add(instructionsLOL);

		blackScreen = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		blackScreen.alpha = 0.5;
		blackScreen.visible = false;
		blackScreen.cameras = [camEXT];
		add(blackScreen);
		
		tauntRating = new FlxText(0, 0);
		tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite + "\nFrameRateHold(60): " + frameRateCap;
		tauntRating.antialiasing = FlxG.save.data.antialiasing;
		tauntRating.setFormat(Paths.font("playtime.ttf"), 20, LEFT);
		tauntRating.color = FlxColor.YELLOW;
		tauntRating.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
		tauntRating.cameras = [camEXT];
		add(tauntRating);

		pageNumberLOL = new FlxText(0, 0);
		pageNumberLOL.text = "Pg. " + testPage + '\n(Z / X to change)';
		pageNumberLOL.antialiasing = FlxG.save.data.antialiasing;
		pageNumberLOL.setFormat(Paths.font("VCR OSD Mono"), 20, RIGHT);
		//pageNumberLOL.screenCenter();
		pageNumberLOL.color = FlxColor.CYAN;
		pageNumberLOL.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
		pageNumberLOL.x = (FlxG.width - pageNumberLOL.width) - 5;
		pageNumberLOL.cameras = [camEXT];
		add(pageNumberLOL);

		//Cameradata
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		camGame.zoom = defaultCamZoom;
		camGame.focusOn(camFollow.getPosition());
		camGame.follow(camFollow, LOCKON, 1);

		//For CamHUD to fix itself after shake
		//var camHUDFollow:FlxObject = new FlxObject(0, 0, 1, 1);
		//camHUDFollow.screenCenter();
		//camHUD.focusOn(camHUDFollow.getPosition());
		//camHUD.follow(camHUDFollow, LOCKON, 1);

		funnyAlphabetTesterBold = new Alphabet(0, 0, '', true);
		funnyAlphabetTesterBold.screenCenter();
		funnyAlphabetTesterBold.cameras = [camEXT];
		funnyAlphabetTesterBold.visible = false;
		add(funnyAlphabetTesterBold);
		
		funnyAlphabetTesterSkinny = new Alphabet(0, 0, '', false);
		funnyAlphabetTesterSkinny.screenCenter();
		funnyAlphabetTesterSkinny.cameras = [camEXT];
		funnyAlphabetTesterSkinny.visible = false;
		add(funnyAlphabetTesterSkinny);

		super.create();

		//whatthefuck
		var fullFuckingDocument:String = Assets.getText(Paths.txt('data/allTypableCharacters'));
		fuckAssAllTypableCharactersArray = fullFuckingDocument.split(' ');
		trace(fuckAssAllTypableCharactersArray);

		Paths.clearUnusedMemory();
	}

	function styleOnEm(ms:Float, styleToIntimidate:Bool = false):Void
	{
		FlxG.sound.play(Paths.sound("optionsSliderDown"), 1);
		var styleRating:String = Ratings.CalculateRating(ms);
		tauntRating.text = "Taunt Rating: " + FlxMath.roundDecimal(ms,5) + "ms ("+ styleRating + ")\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite  + "\nFrameRateHold(60): " + frameRateCap;
	}

	var loseControl:Bool = false;
	var shitPlaceholder:Bool = false;
	var PLACEHOLDERTESTFILTERBOOLEAN:Bool = false;
	var funnyFilter:FlxSoundFilter;
	var testPage:Int = 0; //a page system lol
	//what the fuck
	var fuckAssAllTypableCharactersArray:Array<String> = [];
	var fuckAssAllTypCharCount:Int = 0;
	var funnyTextLmao:String = '';

	override public function update(elapsed:Float)
	{
		if (Conductor.songPosition < FlxG.sound.music.length)
			Conductor.songPosition += FlxG.elapsed * 1000;

		if (!loseControl)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new MainMenuState());
				//Find a way to remove filters from the sound cuz a crash will def happen if I delete this while it's in use LMAO
				if (PLACEHOLDERTESTFILTERBOOLEAN)
				{
					funnyFilter.destroyWithSound = true;
					funnyFilter.destroy();
				}
			}
			
			//Controls forEach page
			switch(testPage)
			{
				case 0:
					if (FlxG.keys.justPressed.LBRACKET)
					{
						if (!FlxG.keys.pressed.SHIFT)
							defaultCamZoom += 0.1;
						else
							defaultCamZoom += 0.025;
						loseControl = true;
					}
					else if (FlxG.keys.justPressed.RBRACKET)
					{
						if (!FlxG.keys.pressed.SHIFT)
							defaultCamZoom -= 0.1;
						else
							defaultCamZoom -= 0.025;
						loseControl = true;
					}

					if (FlxG.keys.justPressed.COMMA)
					{
						if (frameRateCap > 1)
						{
							frameRateCap--;
							tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite + "\nFrameRateHold(60): " + frameRateCap;
						}
					}
					else if (FlxG.keys.justPressed.PERIOD)
					{
						if (frameRateCap < 10)
						{
							frameRateCap++;
							tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite + "\nFrameRateHold(60): " + frameRateCap;
						}
					}

					if (FlxG.keys.justPressed.R)
					{
						var num:Float = FlxG.random.float(50, 5000);
						//trace('generated truncate float test: ' + num);
						var num1:Float = HelperFunctions.truncateFloat(num, 3);
						tauntRating.text = "origin: " + num;
						tauntRating.text += "\ntrunc: " + num1;
						//num1 = HelperFunctions.truncateFloatUsingTheOtherWay(num, 3);
					}
					
					if (FlxG.keys.justPressed.ONE)
					{
						if (stageFloor.scrollFactor.x > 0.1)
						{
							stageFloor.scrollFactor.x -= 0.1;
							stageFloor.scrollFactor.y -= 0.1;
						}
						if (stageOverlay.scrollFactor.x > 0)
						{
							stageOverlay.scrollFactor.x -= 0.1;
							stageOverlay.scrollFactor.y -= 0.1;
						}
						loseControl = true;
						tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite + "\nFrameRateHold(60): " + frameRateCap;
					}
					else if (FlxG.keys.justPressed.TWO)
					{
						if (stageFloor.scrollFactor.x < 1)
						{
							stageFloor.scrollFactor.x += 0.1;
							stageFloor.scrollFactor.y += 0.1;
						}
						if (stageOverlay.scrollFactor.x < 1)
						{
							stageOverlay.scrollFactor.x += 0.1;
							stageOverlay.scrollFactor.y += 0.1;
						}
						loseControl = true;
						tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite + "\nFrameRateHold(60): " + frameRateCap;
					}

					if (FlxG.keys.justPressed.THREE)
					{
						if (stageBG.scrollFactor.x > 0.1)
						{
							stageBG.scrollFactor.x -= 0.1;
							stageBG.scrollFactor.y -= 0.1;
						}
						loseControl = true;
						tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite + "\nFrameRateHold(60): " + frameRateCap;
					}
					else if (FlxG.keys.justPressed.FOUR)
					{
						if (stageBG.scrollFactor.x < 1)
						{
							stageBG.scrollFactor.x += 0.1;
							stageBG.scrollFactor.y += 0.1;
						}
						loseControl = true;
						tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite + "\nFrameRateHold(60): " + frameRateCap
						;
					}

					if (FlxG.keys.justPressed.FIVE)
					{
						camShake(true, false, 'camGame', 0.1, Conductor.crochet * 2 / 1000);
						loseControl = true;
					}
					else if (FlxG.keys.justPressed.SIX)
					{
						camShake(true, true, 'camGame', 0.1, Conductor.crochet * 2 / 1000);
						loseControl = true;
					}
					else if (FlxG.keys.justPressed.SEVEN)
					{
						camShake(true, false, 'camGame', 0.1, Conductor.crochet * 2 / 1000, X);
						loseControl = true;
					}
					else if (FlxG.keys.justPressed.EIGHT)
					{
						camShake(true, false, 'camGame', 0.1, Conductor.crochet * 2 / 1000, Y);
						loseControl = true;
					}

					if (FlxG.keys.justPressed.SPACE)
					{
						camGame.zoom += 0.2;
					}

					if (FlxG.keys.justPressed.L)
					{
						FlxG.sound.music.volume = 0.15;

						if (!PLACEHOLDERTESTFILTERBOOLEAN)
						{
							PLACEHOLDERTESTFILTERBOOLEAN = true;
							funnyFilter = new FlxSoundFilter();
							funnyFilter.filterType = FlxSoundFilterType.LOWPASS;
							funnyFilter.gainHF = 0.1;
							funnyFilter.destroyWithSound = false;

							var reverb = new FlxSoundReverbEffect();
							reverb.decayTime = 3.5;
							funnyFilter.addEffect(reverb);
						}

						var sound = new FlxFilteredSound();
						sound.loadEmbedded(Paths.sound('boh'));
						FlxG.sound.list.add(sound);
						FlxG.sound.defaultSoundGroup.add(sound);
						sound.volume = 0.5;
						sound.play();
						sound.filter = funnyFilter;
					}

					if (FlxG.keys.justPressed.ENTER)
					{
						camGame.shakeFlashSprite = !camGame.shakeFlashSprite;
						tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite;
						loseControl = true;
					}

					if (FlxG.keys.justPressed.C)
					{
						var bpmMult:Float = Conductor.songPosition * (Conductor.bpm * 0.01);
						var beatOffset = Std.int(bpmMult % 600);
						beatOffset = (beatOffset >= 300) ? beatOffset - 600 : beatOffset;
						styleOnEm(beatOffset, FlxG.keys.justPressed.C);
						loseControl = true;
					}
				case 1:
					//guh primitive text testing
					//this is sooooo bad [UGLY SOBBING]
					if (FlxG.keys.justPressed.ENTER)
					{
						funnyAlphabetTesterBold.set_text(fuckAssAllTypableCharactersArray[fuckAssAllTypCharCount]);
						funnyAlphabetTesterBold.screenCenter();
						loseControl = true;
						FlxG.sound.play(Paths.sound("keybindsCancel"));
						fuckAssAllTypCharCount++;

						if (fuckAssAllTypCharCount >= fuckAssAllTypableCharactersArray.length)
							fuckAssAllTypCharCount = 0;
						trace('isworki? (Bold)');
					}
				case 2:
					if (FlxG.keys.justPressed.ENTER)
					{
						funnyAlphabetTesterSkinny.set_text(fuckAssAllTypableCharactersArray[fuckAssAllTypCharCount]);
						funnyAlphabetTesterSkinny.screenCenter();
						loseControl = true;
						FlxG.sound.play(Paths.sound("keybindsCancel"));
						fuckAssAllTypCharCount++;

						if (fuckAssAllTypCharCount >= fuckAssAllTypableCharactersArray.length)
							fuckAssAllTypCharCount = 0;
						trace('isworki? (Skinny)');
					}
			}
		}

		//fuck
		if (FlxG.keys.justPressed.Z)
			changePage(false);
		else if (FlxG.keys.justPressed.X)
			changePage(true);

		super.update(elapsed);

		if (loseControl)
		{
			new FlxTimer().start(0.05, function(tmr:FlxTimer)
			{
				loseControl = false;
			});
		}

		camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, CoolUtil.boundTo(1 - (elapsed * (5 * (Conductor.bpm * 0.01))), 0, 1));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * (5 * (Conductor.bpm * 0.01))), 0, 1));
	}

	function camShake(force:Bool = true, decay:Bool = false, camToShake:String = 'camGame', intensity:Float = 0.03, duration:Float = 0.25, axis:FlxAxes = XY):Void
	{
		if (decay)
		{
			intensity *= 2;
			duration *= 2;
		}

		switch (camToShake)
		{
			case 'camGame':
				camGame.shake(frameRateCap, intensity, duration, force, decay, axis);
			case 'camHUD':
				camHUD.shake(frameRateCap, intensity, duration, force, decay, axis);
		}
	}

	//guh this is stupd and this state is stupid but we need somethin quick and dirty to test shiz qwith
	function changePage(goingForward:Bool = true)
	{
		var pageLimit:Int = 2; //Justchange this when you add more pages LMFAO
		if (goingForward)
		{
			if (testPage < pageLimit)
				testPage++;
			else
				testPage = 0;
		}
		else
		{
			if (testPage > 0)
				testPage--;
			else
				testPage = pageLimit;
		}

		pageNumberLOL.text = "Pg. " + testPage + '\n(Z / X to change)';

		//per page update
		switch(testPage)
		{
			case 0:
				blackScreen.visible = false;
				funnyAlphabetTesterBold.visible = false;
				funnyAlphabetTesterSkinny.visible = false;
				tauntRating.text = "Taunt Rating: 0.00 ms (No Rating)\nBGSC: " + stageBG.scrollFactor.x + ", " + stageBG.scrollFactor.y + "\nFGSC: " + stageFloor.scrollFactor.x + ", " + stageFloor.scrollFactor.y + "\nShake FlashSprite: " + camGame.shakeFlashSprite + "\nFrameRateHold(60): " + frameRateCap;
			case 1:
				blackScreen.visible = true;
				funnyAlphabetTesterSkinny.visible = false;
				funnyAlphabetTesterBold.visible = true;
				tauntRating.text = "Alphabet Testing Mode!\nText: Bold\nPress [ENTER] to Test!"; //i ngl forgor what to put here
			case 2:
				blackScreen.visible = true;
				funnyAlphabetTesterBold.visible = false;
				funnyAlphabetTesterSkinny.visible = true;
				tauntRating.text = "Alphabet Testing Mode!\nText: Regular\nPress [ENTER] to Test!";
		}
	}
}