package;

import flixel.input.gamepad.FlxGamepad;
//import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

class StoryMenuState extends MusicBeatMenu
{
	var scoreText:FlxText;

	static function weekData():Array<Dynamic>
	{
		return 
		[
			['Mic Test'],
			['Tech. Difficulties', 'Awkward Pauses', 'Up and Beyond'],
			['Desperation', 'Disagreement', 'Retaliation'],
			['Kid With a Gun', 'Playing With Fire', 'Variegated Skylines'],
			['Sudden Confrontation', 'Sprouting Irritation', 'Striking Tribulation'],
		];
	}

	/**
	 * 		['Cocoa', 'Eggnog', 'Winter Horrorland'],
			['Senpai', 'Roses', 'Thorns']
	 */

	//Making this static, this was once public static cause i was stupid and didnt know how vars work
	static var curWeek:Int = 0;//Sets your current selected week to the currently unlocked week
	static var curDifficulty:Int = 1;
	public static var weekUnlocked:Array<Bool> = [];

	var weekCharacters:Array<Dynamic> = [
		['', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-christmas', 'bf', 'gf'],
		['senpai', 'bf', 'gf']
	];

	var weekNames:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekNames'));

	var txtWeekTitle:FlxText;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem.StoryMenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var combo:String = '';

	var weekLockedSound:FlxSound;

	function unlockWeeks():Array<Bool>
	{
		var weeks:Array<Bool> = [];
		#if debug
		for(i in 0...weekNames.length)
			weeks.push(true);
		return weeks;
		#end
		
		weeks.push(true);

		for(i in 0...FlxG.save.data.weekUnlocked)
			{
				weeks.push(true);
			}
		return weeks;
	}

	static var firstStart:Bool = true;

	override function create()
	{
		//FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
		confirmSound = new FlxSound();

		weekUnlocked = unlockWeeks();
		if (firstStart)
		{
			curWeek = FlxG.save.data.weekUnlocked;
			firstStart = false;
		}

		//Week-dependent Menu theme and BG colours
		switch (FlxG.save.data.weekUnlocked)
		{
			case 0 | 1:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.65);
				bgColor = 0xFF000000;
				TitleState.weekAdderThingy = "";
			case 2:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0.65);
				bgColor = 0xFF120005;
				TitleState.weekAdderThingy = "-glitchy";
			case 3:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('cityMenu'), 0.65);
				bgColor = 0xFF0b0d1d;
				TitleState.weekAdderThingy = "-city";
			case 4:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('villageMenu'), 0.65);
				bgColor = 0xff00171c;
				TitleState.weekAdderThingy = "-village";
			default:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.65);
				bgColor = 0xFF051c31;
		}

		if (!FreeplayState.freeplayMusicPlaying)
			Conductor.changeBPM(102);

		//Ripped from PlayState 1
		camUI = new FlxCamera();
		camLoad = new FlxCamera();

		camLoad.bgColor.alpha = 0;

		FlxG.cameras.reset(camUI);
		FlxG.cameras.add(camLoad);
		
		FlxCamera.defaultCameras = [camUI];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		/*else if (PlayState.menuAfterVideo)
			// && !PlayState.menuAfterVideo
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}*/

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 00000000", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		scoreText.borderColor = FlxColor.BLACK;
		scoreText.borderSize = 4;
		scoreText.borderStyle = FlxTextBorderStyle.OUTLINE;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("Playtime With Hot Toddies", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.borderColor = FlxColor.BLACK;
		txtWeekTitle.borderSize = 3;
		txtWeekTitle.borderStyle = FlxTextBorderStyle.OUTLINE;
		txtWeekTitle.antialiasing = FlxG.save.data.antialiasing;
		txtWeekTitle.alpha = 0.7;

		/*var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("playtime.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);*/

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var storyMenuColorBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400);
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			storyMenuColorBG.color = 0xFFEB829C
		else
			storyMenuColorBG.color = 0xFF94485B;

		grpWeekText = new FlxTypedGroup<MenuItem.StoryMenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, bgColor);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		for (i in 0...weekData().length)
		{
			var weekThing:MenuItem.StoryMenuItem = new MenuItem.StoryMenuItem(0, storyMenuColorBG.y + storyMenuColorBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = FlxG.save.data.antialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				trace('locking week ' + i);
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = FlxG.save.data.antialiasing;
				grpLocks.add(lock);
			}
		}

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left", 8, false);
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		sprDifficulty.antialiasing = FlxG.save.data.antialiasing;
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 8, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(rightArrow);

		add(storyMenuColorBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, storyMenuColorBG.y + storyMenuColorBG.height + 30, 0, "Tracks", 32);
		//txtTracklist.y -= 50;
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font("playtime.ttf"), 32);
		txtTracklist.borderColor = FlxColor.BLACK;
		txtTracklist.borderSize = 3;
		txtTracklist.borderStyle = FlxTextBorderStyle.OUTLINE;
		txtTracklist.antialiasing = FlxG.save.data.antialiasing;
		txtTracklist.color = 0xff70f5ff;

		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();


		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		super.create();

		setUpTips('StoryMenu');

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			earlyBird = true;
		});

		#if windows
		// Updating Discord Rich Presence
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Perusing the Menus", null, false, 'apppresence-default');
		#end

		weekLockedSound = FlxG.sound.load(Paths.sound('confirmMenuLocked'), 0.5);

		mouseTimer = new FlxTimer().start(0.5, function(swagTimer:FlxTimer)
		{
			mouseActive = true;
		});
	}

	var transitionTimer:FlxTimer;
	var earlyBird:Bool = false;
	var gamepad:FlxGamepad;
	var mouseActive:Bool = false;
	var mouseTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.65 && !FreeplayState.freeplayMusicPlaying)
			FlxG.sound.music.volume = 0.65;

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = FlxMath.lerp(lerpScore, intendedScore, 0.3);

		scoreText.text = "SCORE:" + Math.round(lerpScore) + "   " + combo;
		scoreText.antialiasing = false;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				gamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
						changeWeek(-1);
					else if (gamepad.justPressed.DPAD_DOWN)						
						changeWeek(1);

					if (gamepad.justPressed.DPAD_RIGHT && weekUnlocked[curWeek] && !gamepad.pressed.DPAD_LEFT)
					{
						rightArrow.animation.play('press');
						changeDifficulty(1);
					}
					else if (gamepad.justPressed.DPAD_LEFT && weekUnlocked[curWeek] && !gamepad.pressed.DPAD_RIGHT)
					{
						leftArrow.animation.play('press');
						changeDifficulty(-1);
					}
					else
					{
						rightArrow.animation.play('idle');
						leftArrow.animation.play('idle');
					}
				}
				else if (Main.isFocused)
				{
					if (mouseActive && FlxG.mouse.justMoved && earlyBird)
					{
						for (textSprite in grpWeekText)
						{
							if (FlxG.mouse.overlaps(textSprite) && curWeek != textSprite.ID)
							{
								curWeek = textSprite.ID;
								changeWeek();
								mouseActive = false;
								mouseTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer)
								{
									mouseActive = true;
								});
							}
						}
					}
					else
					{
						if (FlxG.keys.justPressed.UP)
						{
							changeWeek(-1);
							if (mouseTimer.active)
								mouseTimer.cancel();
							mouseActive = false;
							mouseTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								mouseActive = true;
							});
						}
						else if (FlxG.keys.justPressed.DOWN)
						{
							changeWeek(1);
							if (mouseTimer.active)
								mouseTimer.cancel();
							mouseActive = false;
							mouseTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								mouseActive = true;
							});
						}
					}	
					
					if ((controls.RIGHT_P || (FlxG.mouse.overlaps(rightArrow) || FlxG.mouse.overlaps(sprDifficulty)) && FlxG.mouse.justPressed) && weekUnlocked[curWeek])
					{
						changeDifficulty(1);
						FlxG.sound.play(Paths.sound('switchMenu'), 0.3);
					}
					else if ((controls.LEFT_P || FlxG.mouse.overlaps(leftArrow) && !FlxG.mouse.overlaps(sprDifficulty) && FlxG.mouse.justPressed) && weekUnlocked[curWeek])
					{
						changeDifficulty(-1);
						FlxG.sound.play(Paths.sound('switchMenu'), 0.3);
					}
										
					if ((controls.RIGHT || (FlxG.mouse.overlaps(rightArrow) || FlxG.mouse.overlaps(sprDifficulty)) && FlxG.mouse.pressed) && !controls.LEFT)
						rightArrow.animation.play('press');
					else
						rightArrow.animation.play('idle');
						
					if ((controls.LEFT || FlxG.mouse.overlaps(leftArrow) && !FlxG.mouse.overlaps(sprDifficulty) && FlxG.mouse.pressed) && !controls.RIGHT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');
				}
			}

			if (controls.ACCEPT || FlxG.mouse.justPressed && FlxG.mouse.overlaps(grpWeekText.members[curWeek]))
			{
				if (weekUnlocked[curWeek])
					selectWeek();
				else
					weekLockedSound.play(true);
			}
		}

		if ((controls.BACK || FlxG.mouse.justPressedRight) && !selectedWeek)
		{
			if (!movedBack)
			{
				mouseActive = false;
				//Week dependent Cancel Menu Sounds
				switch (FlxG.save.data.weekUnlocked)
				{
					case 2:
						FlxG.sound.play(Paths.sound('cancelMenu'));
					case 3:
						FlxG.sound.play(Paths.sound('cancelMenu'));
					case 6:
						FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
					default:
						if (!FreeplayState.freeplayMusicPlaying)
							FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
						else
							FlxG.sound.play(Paths.sound('cancelMenu'));
				}
				movedBack = true;
				transitionTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					//FlxTransitionableState.defaultTransIn.setStatus(NULL);
					Main.updateTimeStuffs();
					FlxG.switchState(new MainMenuState());
					transitionTimer.destroy();
				});
			}
			else
			{
				transitionTimer.cancel();
				//FlxTransitionableState.defaultTransIn.setStatus(NULL);
				Main.updateTimeStuffs();
				FlxG.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!stopspamming)
		{
			grpWeekText.members[curWeek].startFlashing();
			grpWeekCharacters.members[1].animation.play('bfConfirm');
			stopspamming = true;
			Main.doFocusShit = false;
			FlxG.sound.music.stop();
			confirmSound = FlxG.sound.play(Paths.sound('confirmMenuBlue' + TitleState.weekAdderThingy));
			confirmSound.persist = true;
			confirmSound.autoDestroy = true;
			FlxG.camera.shake(0.01, 1, true, true);

			PlayState.storyPlaylist = weekData()[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			FreeplayState.freeplayMusicPlaying = false;

			PlayState.storyDifficulty = curDifficulty;

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

			var poop:String = Highscore.formatSong(songFormat, curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
			PlayState.storyWeek = curWeek;
			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				transitionOut();
				FlxG.mouse.visible = false;
				LoadingState.target = new PlayState();
				FlxG.switchState(new LoadingState());
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		combo = Highscore.getWeekCombo(curWeek, curDifficulty);
		//trace (combo);
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {type: ONESHOT, ease: FlxEase.circOut});
	}

	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData().length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData().length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		switch (FlxG.save.data.weekUnlocked)
		{
			case 2:
				FlxG.sound.play(Paths.sound('scrollMenu'));
			case 3:
				FlxG.sound.play(Paths.sound('scrollMenu'));
			case 6:
				FlxG.sound.play(Paths.sound('scrollMenu' + curKey));
			default:
				if (!FreeplayState.freeplayMusicPlaying)
					FlxG.sound.play(Paths.sound('scrollMenu' + curKey));
				else
					FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateText();
	}

	function updateText()
	{
		trace (curWeek);
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		txtTracklist.text = "Songs:\n";
		var stringThing:Array<String> = weekData()[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		combo = Highscore.getWeekCombo(curWeek, curDifficulty);
		trace (combo);
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	public static function unlockNextWeek(week:Int):Void
	{
		if(week <= weekData().length - 1 && FlxG.save.data.weekUnlocked == week)
		{
			weekUnlocked.push(true);
			trace('Week ' + week + ' beat (Week ' + (week + 1) + ' unlocked)');
		}

		FlxG.save.data.weekUnlocked = weekUnlocked.length - 1;
		FlxG.save.flush();
	}

	override function beatHit()
	{
		super.beatHit();

		grpWeekCharacters.members[0].bopHead();
		grpWeekCharacters.members[1].bopHead();
		grpWeekCharacters.members[2].bopHead();
	}
}
