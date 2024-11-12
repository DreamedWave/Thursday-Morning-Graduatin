package;

import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;
#if windows
import discord_rpc.DiscordRpc;
#end
import flixel.addons.transition.FlxTransitionableState;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	public static var discordClientStarted:Bool = true;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Inputs and Accessibility", [
			new DFJKOption(controls),
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
			new Judgement("Customize your Hit Timings. (LEFT or RIGHT)"),
			new PauseOnLostFocus("Pause the game when it loses focus."),
			new ResetButtonOption("Toggle pressing R to gameover."),
		]),
	
		new OptionCategory("Notes and Ratings", [
			new AccuracyDOption("Change how accuracy is calculated. (Simple = Normal, Complex = Milisecond Based)"),
			new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
			new SongPositionOption("Show the song's current progress as a scrolling bar."),
			new DownscrollOption("Toggle making the notes scroll down rather than up."),
			new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
			new CpuStrums("Toggle whether the enemy's notes light up like the player's when they sing.")
		]),

		new OptionCategory("Graphics and Video", [
			new NoteSplashingEffectsOption("Toggle the effects when you hit a 'SICK!!' or 'Shit' note."),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamZoomOption("Toggle the camera zoom in-game if it is too distracting."),
			new CustomizeGameplay("Drag and drop the rating popup to your prefered positions!"),
			new VideoCutscenes("Enable or disable all video cutscenes.")//,
			//Add videosubtitle option
		]),

		new OptionCategory("Sounds and Music", [
			new NoteHitSFXOption("Toggle sounds everytime you hit a note."),
			new HitSFXTypeOption("Change how you want your note hit sounds to sound like."),
			new HitSFXVolOption("Change the volume of note hit sounds. (Default = 45, Shift for fast)"),
			//Add NoteHitSFXTypeOption (to allow the player to choose how the note hit sound should sound like)
			//Add MissSFXVolOption, MusVolOption, and VocVolOption.
			new MissSoundsOption("Toggle miss sounds playing when you miss a note."),
			new FullscreenOption("Toggle whether the game plays in fullscreen. May cause issues..?"),
		]),

		new OptionCategory("Performance and Data", [
			new MusicPreloading("Loads all MUSIC on startup. Lessens in-game load times but increases RAM usage."),
			new GraphicPreloading("Loads all IMAGES on startup. Lessens in-game load times but increases RAM usage."),
			new AntialiasingOption("Smoothens image edges to make them look better at the cost of a little performance."),
			new Optimization("Simplified gameplay with only arrows and a background like a usual rhythm game."),
			new FPSOption("Toggle the FPS Counter."),
			#if desktop
			new FPSCapOption("Change your FPS Cap.")
			#end
		]),

		new OptionCategory("Saves and Information", [
			#if desktop
			new ShowPresenceOption("(NEEDS RESTART) Show Discord presence data in your status"),
			new ReplayOption("View saved song replays."),
			#end
			new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
			new LockWeeksOption("Reset your story mode progress. This is irreversible!"),
			new ResetSettings("Reset ALL your settings. This is irreversible!")
		]),
		
		new OptionCategory("Miscellaneous", [
			new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
			new WatermarkOption("Enable or disable all watermarks from the engine."),
			new ScoreScreen("Show the score screen after the end of a song."),
			new AccuracyOption("Shows your current Accuracy on the info bar."),
			new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
			new ShowInput("Display every single input on the score screen."),
			new BotPlay("Plays the song's chart automatically for you.")
		])
		
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;

	var movedBack:Bool = false;

	override function create()
	{
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFF5799cf;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		if(FlxG.save.data.antialiasing)
			{
				menuBG.antialiasing = true;
			}
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, "Offset (In miliseconds - Left, Right, Shift to slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)),Std.int(versionShit.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18}, 1 ,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18}, 1 , {ease: FlxEase.elasticInOut});

		changeSelection();

		super.create();
	}

	var isCat:Bool = false;
	
	var transitionTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if windows
		if (!FlxG.save.data.showPresence && discordClientStarted)
		{
			DiscordRpc.shutdown();
			discordClientStarted = false;
		}
		#end

		if (acceptInput)
		{
			if (controls.BACK && !movedBack)
			{
				if (!isCat && DisclaimerScreen.wentOptions)
				{
					movedBack = true;
					DisclaimerScreen.wentOptions = false;
					FlxG.switchState(new TitleState());
				}
				else if (!isCat && !DisclaimerScreen.wentOptions)
				{
					movedBack = true;
					switch (FlxG.save.data.weekUnlocked)
					{
						case 2:
							FlxG.sound.play(Paths.sound('cancelMenu'));
						case 3:
							FlxG.sound.play(Paths.sound('cancelMenu'));
						case 6:
							FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
						default:
							if (!FreeplayState.freeplayMusicPlaying)
								FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
							else
								FlxG.sound.play(Paths.sound('cancelMenu'));
					}
					transitionTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						transitionTimer.destroy();
						//FlxTransitionableState.defaultTransIn.setStatus(NULL);
						FlxG.switchState(new MainMenuState());
					});
				}
				else
				{
					isCat = false;
					grpControls.clear();
					for (i in 0...options.length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
				
					curSelected = 0;
				
					changeSelection(curSelected);
				}
			}
			else if (controls.BACK && movedBack && !isCat && !DisclaimerScreen.wentOptions)
			{
				transitionTimer.cancel();
				FlxG.switchState(new MainMenuState());
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			}
			
			if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN)
				changeSelection(1);
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
						{
							if (FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;
					
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
				else
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;
				
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
		

			if (controls.RESET)
					FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
						trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
				
				changeSelection();
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end
		
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.5;
			//item.x - 30;
			//item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				//item.x + 30;
				//trace("item witdh = " + item.width);
				//item.setGraphicSize(Std.int(item.width * 1));
			}
		}

		/*for (i in 0...grpControls.members.length)
		{
			grpControls.members[i].x = grpControls.members[i].x;
		}*/
	}
}
