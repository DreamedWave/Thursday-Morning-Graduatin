package;
import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if sys
import smTools.SMFile;
import sys.FileSystem;
import sys.io.File;
#end
import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	public static var curSelected:Int = 0;
	public static var lastSelected:Int = -1;
	public static var curDifficulty:Int = 1;
	public static var freeplayMusicPlaying:Bool = false;
	public static var freeplayCurColour:Int = 0;//0 for blue, 1 for orange
	public static var freeplayPrevColour:Int = -1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	//var previewtext:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';
	var movedBack:Bool = false;
	var stopInputs:Bool = false;

	var loadingIcon:FlxSprite;
	var camUI:FlxCamera;
	var camLoad:FlxCamera;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	public static var songData:Map<String,Array<SwagSong>> = [];

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>)
	{
		try 
		{
			array.push(Song.loadFromJson(Highscore.formatSong(format, diff), name));
		}
		catch(ex)
		{
			// do nada
		}
	}
	override function create()
	{
		if (FreeplaySelectionState.isOrange) 
		{
			var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplayOrangeSonglist'));
			freeplayCurColour = 1;

			if (freeplayPrevColour < 0)
				freeplayPrevColour = freeplayCurColour;
			//var diffList = "";
	
			songData = [];
			songs = [];
	
			for (i in 0...initSonglist.length)
			{
				var data:Array<String> = initSonglist[i].split(':');
				var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);
				songs.push(meta);
				var format = StringTools.replace(meta.songName, " ", "-");
	
				var diffs = [];
				FreeplayState.loadDiff(0,format,meta.songName,diffs);
				FreeplayState.loadDiff(1,format,meta.songName,diffs);
				FreeplayState.loadDiff(2,format,meta.songName,diffs);
				FreeplayState.songData.set(meta.songName,diffs);
				trace('loaded diffs for ' + meta.songName);
				//FlxG.sound.load(Paths.inst(meta.songName));
			}
		}
		else
		{
			var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));
			freeplayCurColour = 0;

			if (freeplayPrevColour < 0)
				freeplayPrevColour = freeplayCurColour;
			//var diffList = "";
	
			songData = [];
			songs = [];

			var songListLength:Int = 0;
	
			for (i in 0...initSonglist.length)
			{
				var data:Array<String> = initSonglist[i].split(':');
				var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);
				songs.push(meta);

				if (songs[i].week <= FlxG.save.data.weekUnlocked)
				{
					var format = StringTools.replace(meta.songName, " ", "-");
					var diffs = [];

					FreeplayState.loadDiff(0,format,meta.songName,diffs);
					FreeplayState.loadDiff(1,format,meta.songName,diffs);
					FreeplayState.loadDiff(2,format,meta.songName,diffs);
					FreeplayState.songData.set(meta.songName,diffs);
					trace('loaded diffs for ' + meta.songName + ' - ' + songs[i].week);
					//FlxG.sound.load(Paths.inst(meta.songName));
					songListLength += 1;
				}
				//else
				//{
					//songListLength -= 1;
					//trace("ignored diffs for " + meta.songName + ' - ' + songs[i].week);
				//}
				//trace("InitSongsLength = " + songs.length);
			}
			//trace("songListLength is = " + songListLength);
			songs.resize(songListLength);
			trace("IMPORTANT NOTE: Make sure that the week numbers in 'freePlaySongList.txt' are in ASCENDING ORDER or else it **will** cause a crash. Thank you for listening to my TED Talk. \n (Example: [Song week 0, Song week 1, etc])");
			//trace("Ok, NOW SongsLength is = " + songs.length);
		}

		//trace("\n" + diffList);

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		var isDebug:Bool = false;
		freeplayMusicPlaying = true;
		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		//Ripped from PlayState 1
		camUI = new FlxCamera();
		camLoad = new FlxCamera();

		camLoad.bgColor.alpha = 0;

		FlxG.cameras.reset(camUI);
		FlxG.cameras.add(camLoad);
		
		FlxCamera.defaultCameras = [camUI];

		var bg:FlxSprite;

		if (FreeplaySelectionState.isOrange) 
			bg = new FlxSprite().loadGraphic(Paths.image('menuBGOrange'));
		else 
			bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		if(FlxG.save.data.antialiasing)
			bg.antialiasing = true;
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			bg.alpha = 1
		else
			bg.alpha = 0.65;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			//if (songs[i].week <= FlxG.save.data.weekUnlocked)
			//{
				//trace("Adding SongText = " + songs[i].songName);

				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpSongs.add(songText);

				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				icon.sprTracker = songText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);

				// songText.x += 40;
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				// songText.screenCenter(X);
			//}
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("playtime.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35 + 10), 105, 0xFF000000);
		scoreBG.alpha = 0.5;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		//previewtext = new FlxText(scoreText.x, scoreText.y + 94, 0, "" + (KeyBinds.gamepad ? "X" : "SPACE") + " to preview", 24);
		//previewtext.font = scoreText.font;
		//add(previewtext);

		comboText = new FlxText(diffText.x + 130, diffText.y, 0, "", 24);
		comboText.font = diffText.font;

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
		add(comboText);
		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['demon-dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var transitionTimer:FlxTimer;
	var gamepad:FlxGamepad;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST: " + lerpScore;
		comboText.text = combo + '\n';

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		if (!stopInputs)
		{
			gamepad = FlxG.gamepads.lastActive;
			var upP = FlxG.keys.justPressed.UP;
			var downP = FlxG.keys.justPressed.DOWN;
			//var accepted = FlxG.keys.justPressed.ENTER;
			if (gamepad != null)
			{

				if (gamepad.justPressed.DPAD_UP)
				{
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					changeSelection(1);
				}
				if (gamepad.justPressed.DPAD_LEFT)
				{
					changeDiff(-1);
				}
				if (gamepad.justPressed.DPAD_RIGHT)
				{
					changeDiff(1);
				}

				//if (gamepad.justPressed.X && !openedPreview)
					//openSubState(new DiffOverview());
			}

			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}

			//if (FlxG.keys.justPressed.SPACE && !openedPreview)
				//openSubState(new DiffOverview());

			if (FlxG.keys.justPressed.LEFT)
			{
				changeDiff(-1);
				FlxG.sound.play(Paths.sound('switchMenu'), 0.1);
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				changeDiff(1);
				FlxG.sound.play(Paths.sound('switchMenu'), 0.1);
			}
			
			if (controls.BACK)
			{
				if (!movedBack)
				{
					movedBack = true;
					freeplayPrevColour = freeplayCurColour;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					if (!FlxG.keys.pressed.SHIFT)
					{
						freeplayMusicPlaying = false;
						Conductor.changeBPM(102);
						FlxG.sound.music.stop();
					}
					transitionTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						transitionTimer.destroy();
						//FlxTransitionableState.defaultTransIn.setStatus(NULL);
						if (FlxG.save.data.weekUnlocked >= 6)
							FlxG.switchState(new FreeplaySelectionState());
						else
							FlxG.switchState(new MainMenuState());
					});
				}
				else
				{
					transitionTimer.cancel();
					//FlxTransitionableState.defaultTransIn.setStatus(NULL);
					if (FlxG.save.data.weekUnlocked >= 6)
						FlxG.switchState(new FreeplaySelectionState());
					else
						FlxG.switchState(new MainMenuState());
				}
			}

			if (controls.ACCEPT && !movedBack)
			{
				stopInputs = true;
				// adjusting the song name to be compatible
				var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
				var hmm;
				try
				{
					hmm = songData.get(songs[curSelected].songName)[curDifficulty];
					if (hmm == null)
						return;
				}
				catch(ex)
				{
					return;
				}


				PlayState.SONG = hmm;
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				//trace('CUR WEEK' + PlayState.storyWeek);

				FlxG.sound.music.stop();
				if (FreeplaySelectionState.isOrange)
					FlxG.sound.play(Paths.sound('confirmMenuOrange' + TitleState.weekAdderThingy));
				else
					FlxG.sound.play(Paths.sound('confirmMenuBlue' + TitleState.weekAdderThingy));

				for (item in grpSongs.members)
				{
					if (item.targetY == 0)
					{
						if (FlxG.save.data.flashing)
						{
							FlxFlicker.flicker(iconArray[curSelected], 1.5, 0.06, true, false);
							FlxFlicker.flicker(item, 1.5, 0.06, true, false, function(flick:FlxFlicker)
							{
								FlxTween.tween(loadingIcon, {alpha: 1}, 0.3, {type: ONESHOT, ease: FlxEase.smootherStepIn});
								LoadingState.loadAndSwitchState(new PlayState());
							});
						}
						else
						{
							new FlxTimer().start(1.5, function(tmr:FlxTimer)
							{
								FlxTween.tween(loadingIcon, {alpha: 1}, 0.3, {type: ONESHOT, ease: FlxEase.smootherStepIn});
								LoadingState.loadAndSwitchState(new PlayState());
							});
						}
					}
				}
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;


		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.soundRandom('scrollMenu', 1, 3), 0.4);


		if (freeplayCurColour == freeplayPrevColour)
		{
			lastSelected = curSelected;
			curSelected += change;
		}
		else
		{
			lastSelected = 0;
			curSelected = 0;
		}
	
		if (curSelected < 0)
			curSelected = songs.length - 1;
		else if (curSelected >= songs.length)
			curSelected = 0;

		trace("CurSelected = " + curSelected + " || Songs Length = " + songs.length);

		// selector.y = (70 * curSelected) + 30;
		
		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
		
		#if PRELOAD_ALL
		if (!freeplayMusicPlaying || (curSelected != lastSelected || freeplayCurColour != freeplayPrevColour) || !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		FlxG.sound.music.looped = true;

		var hmm;
			try
			{
				hmm = songData.get(songs[curSelected].songName)[curDifficulty];
				if (hmm != null)
					Conductor.changeBPM(hmm.bpm);
			}
			catch(ex)
			{}

		if (openedPreview)
		{
			closeSubState();
			openSubState(new DiffOverview());
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.3;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.3;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
