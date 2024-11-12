package;

import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
#if windows
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	public static var skippedSong:Bool = false;
	public static var randomMusicTime:Bool = false;

	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Skip Song', 'Toggle Practice Mode', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	//var oldPauseVolume:Float = 0;
	var perSongOffset:FlxText;
	var blackBorder:FlxSprite;
	
	var offsetChanged:Bool = false;

	//Declared Here for changeable purposus
	var practiceModeText:FlxText;

	public function new(x:Float, y:Float)
	{
		super();

		/*if (PlayState.instance.useVideo)
		{
			menuItems.remove("Resume");
			if (GlobalVideo.get().playing)
				GlobalVideo.get().pause();
		}*/

		if (FlxG.save.data.weekUnlocked < PlayState.storyWeek + 1 || PlayState.SONG.song.toLowerCase() == "mic test")
		{
			menuItems.remove("Skip Song");
		}
		if (PlayStateChangeables.botPlay || PlayState.SONG.song.toLowerCase() == "mic test")
		{
			menuItems.remove("Toggle Practice Mode");
		}

		switch (PlayState.storyWeek)
		{
			case 2:
				pauseMusic = new FlxSound().loadEmbedded(Paths.music('pauseScreen/callous_desperation'), true, true);
			case 3:
				pauseMusic = new FlxSound().loadEmbedded(Paths.music('pauseScreen/heated_stalemate'), true, true);
			default:
				pauseMusic = new FlxSound().loadEmbedded(Paths.music('pauseScreen/bathroom_break'), true, true);
		}
		pauseMusic.volume = 0;
		
		if(randomMusicTime)
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		else
			pauseMusic.play(false);

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "");
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("playtime.ttf"), 32);
		levelInfo.updateHitbox();
		levelInfo.alpha = 0;
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "");
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font("playtime.ttf"), 32);
		levelDifficulty.updateHitbox();
		levelDifficulty.alpha = 0;
		add(levelDifficulty);

		var failCount:FlxText = new FlxText(20, 15 + 64, 0, "");
		failCount.text += "Fail Count: " + PlayState.deaths;
		failCount.scrollFactor.set();
		failCount.setFormat(Paths.font("playtime.ttf"), 32);
		failCount.updateHitbox();
		failCount.alpha = 0;
		add(failCount);

		practiceModeText = new FlxText(20, 15 + 96, 0, "");
		practiceModeText.text = "Practice Mode: " + (!PlayState.cannotDie? "Off" : "On");
		practiceModeText.scrollFactor.set();
		practiceModeText.setFormat(Paths.font("playtime.ttf"), 32, RIGHT);
		practiceModeText.updateHitbox();
		practiceModeText.alpha = 0;
		add(practiceModeText);

		var runValidityText:FlxText = new FlxText(20, 15 + 128, 0, "");
		runValidityText.text = "Is A Valid Run: " + (!PlayState.toggledPracticeMode ? "Yes" : "No");
		runValidityText.scrollFactor.set();
		runValidityText.setFormat(Paths.font("playtime.ttf"), 32);
		runValidityText.updateHitbox();
		runValidityText.alpha = 0;
		add(runValidityText);

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		failCount.x = FlxG.width - (failCount.width + 20);
		practiceModeText.x = FlxG.width - (practiceModeText.width + 20);
		runValidityText.x = FlxG.width - (runValidityText.width + 20);

		FlxTween.tween(bg, {alpha: 0.75}, 0.75, {ease: FlxEase.quadInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(failCount, {alpha: 1, y: failCount.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceModeText, {alpha: 1, y: practiceModeText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(runValidityText, {alpha: 1, y: runValidityText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.1});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		#if cpp
		perSongOffset = new FlxText(5, FlxG.height, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds song-dependent milisecond offset.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height).makeGraphic((Std.int(FlxG.width + 100)),Std.int(perSongOffset.height * 2),FlxColor.BLACK);
		blackBorder.alpha = 0.6;

		add(blackBorder);
		add(perSongOffset);

		FlxTween.tween(perSongOffset, {y: FlxG.height - 21}, 0.9, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 20}, 0.8, {ease: FlxEase.elasticInOut});
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.8)
			pauseMusic.volume += 0.008 * elapsed;

		/*if (!FlxG.sound.muted || FlxG.sound.volume > 0)
			oldPauseVolume = pauseMusic.volume;

		if (FlxG.sound.muted || FlxG.sound.volume <= 0)
			pauseMusic.volume = 0;
		else if (pauseMusic.volume < oldPauseVolume)
			pauseMusic.volume = oldPauseVolume;*/

		super.update(elapsed);

		/*if (PlayState.instance.useVideo)
			menuItems.remove('Resume');*/

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upPcontroller:Bool = false;
		var downPcontroller:Bool = false;
		var leftPcontroller:Bool = false;
		var rightPcontroller:Bool = false;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upPcontroller = gamepad.justPressed.DPAD_UP;
			downPcontroller = gamepad.justPressed.DPAD_DOWN;
			leftPcontroller = gamepad.justPressed.DPAD_LEFT;
			rightPcontroller = gamepad.justPressed.DPAD_RIGHT;
		}

		// pre lowercasing the song name (update)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'philly-nice': songLowercase = 'philly';
		}
		var songPath = 'assets/data/' + songLowercase + '/';

		#if sys
		if (PlayState.isSM && !PlayState.isStoryMode)
			songPath = PlayState.pathToSm;
		#end

		if (controls.UP_P || upPcontroller)
		{
			changeSelection(-1);
   
		}
		else if (controls.DOWN_P || downPcontroller)
		{
			changeSelection(1);
		}
		
		
		#if cpp
			else if (controls.LEFT_P || leftPcontroller)
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset -= 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';

				// Prevent loop from happening every single time the offset changes
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = ['Restart Song', 'Toggle Practice Mode', 'Exit to menu'];

					for (i in 0...menuItems.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						grpMenuShit.add(songText);
					}

					changeSelection();

					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
					offsetChanged = true;
				}
			} 
			else if (controls.RIGHT_P || rightPcontroller)
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset += 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = ['Restart Song', 'Toggle Practice Mode', 'Exit to menu'];

					for (i in 0...menuItems.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						grpMenuShit.add(songText);
					}

					changeSelection();

					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
					offsetChanged = true;
				}
			}
		#end
		

		if (controls.ACCEPT)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					randomMusicTime = true;
					close();
				case "Restart Song":
					randomMusicTime = true;
					PlayState.hasReset = true;
					PlayState.startTime = 0;
					/*if (PlayState.instance.useVideo)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}*/
					//Testing if this doesn't increase RAM
					PlayState.instance.clear();
					FlxG.resetState();
					FlxTransitionableState.skipNextTransOut = true;
				case "Skip Song":
					randomMusicTime = true;
					if (PlayState.isStoryMode && !PlayState.cantSkipSong)
					{
						PlayState.startTime = 0;
						/*if (PlayState.instance.useVideo)
						{
							GlobalVideo.get().stop();
							PlayState.instance.remove(PlayState.instance.videoSprite);
							PlayState.instance.removedVideo = true;
						}*/
						FlxTransitionableState.skipNextTransOut = true;
						skippedSong = true;
						trace("Skipped song");
						close();
						FlxG.sound.music.volume = 0;
						FlxG.sound.music.pause();
					}
					else if (PlayState.isStoryMode && PlayState.cantSkipSong)
					{
						FlxG.sound.play(Paths.sound('pauseMenuCant'), 0.4);
						trace("No song to skip to");
						skippedSong = false;
					}
					else
					{
						FlxG.sound.play(Paths.sound('pauseMenuCant'), 0.5);
						trace("Can't skip song in Freeplay Mode");
						skippedSong = false;
					}
				case "Toggle Practice Mode":
					PlayState.cannotDie = !PlayState.cannotDie;
					if (!PlayState.cannotDie)
					{FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						practiceModeText.text = "Practice Mode: Off";
						PlayState.safeVignette.visible = false;
					}
					else
					{
						FlxG.sound.play(Paths.soundRandom('scrollMenu', 1, 4), 0.4);
						practiceModeText.text = "Practice Mode: On";
						PlayState.safeVignette.visible = true;
					}
					FlxTween.tween(practiceModeText, {x: FlxG.width - (practiceModeText.width + 20)}, 0.1, {ease: FlxEase.quartInOut});
				case "Exit to menu":
					randomMusicTime = false;
					PlayState.deaths = 0;
					PlayState.hasReset = false;
					PlayState.startTime = 0;

					PlayState.cannotDie = false;
					PlayState.toggledPracticeMode = false;

					if (PlayState.playedCutscene)
						PlayState.playedCutscene = false;
					
					/*if (PlayState.instance.useVideo)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}*/
					#if windows
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

					//FlxTransitionableState.skipNextTransOut = true;

					if (PlayState.isStoryMode)
					{
						FlxTransitionableState.skipNextTransIn = true;
						FlxG.switchState(new StoryMenuState());
					}
					else
						FlxG.switchState(new FreeplayState());
			}
		}

		/*if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}*/
	}

	override function destroy()
	{
		FlxG.sound.play(Paths.sound('returnMenu'));
		if (PlayState.cannotDie)
			PlayState.toggledPracticeMode = true;
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.45;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
