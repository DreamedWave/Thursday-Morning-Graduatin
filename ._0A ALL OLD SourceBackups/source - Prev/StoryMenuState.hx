package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	static function weekData():Array<Dynamic>
	{
		return [
			['Mic Test'],
			['Tech. Difficulties', 'Awkward Pauses', 'Up and Beyond'],
			['Desperation', 'Disagreement', 'Retaliation'],
			['Kid With a Gun', 'Playing With Fire', 'Variegated Skylines'],
			['Sudden Confrontation', 'Sprouting Irritation'],
			['Cocoa', 'Eggnog', 'Winter Horrorland'],
			['Senpai', 'Roses', 'Thorns']
		];
	}

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

	//Making this static, this was once public static cause i was stupid and didnt know how vars work
	static var curWeek:Int = 0;

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

	var loadingIcon:FlxSprite;
	var camUI:FlxCamera;
	var camLoad:FlxCamera;

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

	override function create()
	{
		//FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		weekUnlocked = unlockWeeks();

		//Week-dependent Menu theme and BG colours
		switch (FlxG.save.data.weekUnlocked)
		{
			case 1:
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
			default:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.65);
				bgColor = 0xFF051c31;
		}

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

		if (!FreeplayState.freeplayMusicPlaying)
			Conductor.changeBPM(102);

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 00000000", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("Playtime With Hot Toddies", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.antialiasing = true;
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

		trace("Line 70");

		for (i in 0...weekData().length)
		{
			var weekThing:MenuItem.StoryMenuItem = new MenuItem.StoryMenuItem(0, storyMenuColorBG.y + storyMenuColorBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			if(FlxG.save.data.antialiasing)
				{
					weekThing.antialiasing = true;
				}
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
				if(FlxG.save.data.antialiasing)
					{
						lock.antialiasing = true;
					}
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		add(storyMenuColorBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, storyMenuColorBG.y + storyMenuColorBG.height + 30, 0, "Tracks", 32);
		//txtTracklist.y -= 50;
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font("playtime.ttf"), 32);
		txtTracklist.antialiasing = true;
		txtTracklist.color = 0xFF79e5ed;

		//ripped from PlayState 2
		loadingIcon = new FlxSprite().loadGraphic(Paths.image('loadingNextSong'));
		loadingIcon.setGraphicSize(Std.int(loadingIcon.width * 0.5));
		//loadingIcon.screenCenter();
		loadingIcon.x = FlxG.width - loadingIcon.width / 2;
		loadingIcon.y = FlxG.height - loadingIcon.height / 2;
		loadingIcon.scrollFactor.set();
		loadingIcon.updateHitbox();
		if (FlxG.save.data.antialiasing)
			loadingIcon.antialiasing = true;
		loadingIcon.alpha = 0;
		//loadingIcon.screenCenter();
		loadingIcon.cameras = [camLoad];
		add(loadingIcon);
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

		trace("Line 165");

		super.create();

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		weekLockedSound = FlxG.sound.load(Paths.sound('confirmMenuLocked'));
	}

	var transitionTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "SCORE:" + lerpScore + "   " + combo;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
						changeWeek(-1);
					else if (gamepad.justPressed.DPAD_DOWN)						
						changeWeek(1);

					if (gamepad.pressed.DPAD_RIGHT)
						rightArrow.animation.play('press')
					else
						rightArrow.animation.play('idle');
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT && weekUnlocked[curWeek])
						changeDifficulty(1);
					else if (gamepad.justPressed.DPAD_LEFT && weekUnlocked[curWeek])
						changeDifficulty(-1);
				}

				else if (FlxG.keys.justPressed.UP)
				{
					changeWeek(-1);
				}

				else if (FlxG.keys.justPressed.DOWN)
				{
					changeWeek(1);
				}

				if (controls.RIGHT && !controls.LEFT)
					rightArrow.animation.play('press');
				else
					rightArrow.animation.play('idle');
					
				if (controls.LEFT && !controls.RIGHT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');
									
				if (controls.RIGHT_P && leftArrow.animation.name != "press" && weekUnlocked[curWeek])
				{
					changeDifficulty(1);
					FlxG.sound.play(Paths.sound('switchMenu'), 0.3);
				}
				else if (controls.LEFT_P && rightArrow.animation.name != "press" && weekUnlocked[curWeek])
				{
					changeDifficulty(-1);
					FlxG.sound.play(Paths.sound('switchMenu'), 0.3);
				}
			}

			if (controls.ACCEPT)
			{
				if (weekUnlocked[curWeek])
					selectWeek();
				else
					weekLockedSound.play(true);
			}
		}

		if (controls.BACK && !selectedWeek)
		{
			if (!movedBack)
			{
				//Week dependent Cancel Menu Sounds
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
				movedBack = true;
				transitionTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					//FlxTransitionableState.defaultTransIn.setStatus(NULL);
					FlxG.switchState(new MainMenuState());
					transitionTimer.destroy();
				});
			}
			else
			{
				transitionTimer.cancel();
				//FlxTransitionableState.defaultTransIn.setStatus(NULL);
				FlxG.switchState(new MainMenuState());
			}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		if (MainMenuState.curKey > 4 || MainMenuState.curKey < 1)
			MainMenuState.curKey = 1;
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (stopspamming == false)
		{
			grpWeekText.members[curWeek].startFlashing();
			grpWeekCharacters.members[1].animation.play('bfConfirm');
			stopspamming = true;
			new FlxTimer().start(0.04, function(tmr:FlxTimer)
			{
				FlxG.sound.music.stop();
			});
			FlxG.sound.play(Paths.sound('confirmMenuBlue' + TitleState.weekAdderThingy));

			PlayState.storyPlaylist = weekData()[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			FreeplayState.freeplayMusicPlaying = false;

			PlayState.storyDifficulty = curDifficulty;

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

			var poop:String = Highscore.formatSong(songFormat, curDifficulty);
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				FlxTween.tween(loadingIcon, {alpha: 1}, 0.3, {type: ONESHOT, ease: FlxEase.smootherStepIn});
				LoadingState.loadAndSwitchState(new PlayState());
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

	var lerpScore:Int = 0;
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
				FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
			default:
				if (!FreeplayState.freeplayMusicPlaying)
					FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
				else
					FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateText();
	}

	function updateText()
	{
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

		if (FlxG.sound.music.playing && FlxG.save.data.weekUnlocked == 1)
		{
			if (curBeat % 4 == 0)
				MainMenuState.curKey += 1;
		}

		grpWeekCharacters.members[0].bopHead();
		grpWeekCharacters.members[1].bopHead();
		grpWeekCharacters.members[2].bopHead();
	}
}
