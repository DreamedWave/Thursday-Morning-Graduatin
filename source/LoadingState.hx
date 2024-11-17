package;

//import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import sys.thread.Thread;
import sys.FileSystem;

using StringTools;

//Original code from Indie Cross, modified by DreamedWave for TMG
class LoadingState extends MusicBeatMenu
{
	public static var target:FlxState;
	public static var stopMusic:Bool = true;
	public static var doScreenshotShit:Bool = false;

	var screen:LoadingScreen = null;
	var inPlayState:Bool = false;
	var instantShow:Bool = false;

	var skipIn:Bool = true;

	public function new(instantShow:Bool = false)
	{
		skipIn = FlxTransitionableState.skipNextTransOut;

		super();

		this.instantShow = instantShow;
		FlxTransitionableState.skipNextTransIn = true;
	}

	override function create()
	{	
		super.create();

		//Dumping of unused cache
		Paths.clearUnusedMemory();

		FlxTransitionableState.skipNextTransIn = skipIn;
		FlxTransitionableState.skipNextTransOut = true;

		if (Type.getClass(FlxG.state) == PlayState)
			inPlayState = true;

		switch(Type.getClass(target))
		{
			case PlayState:
				var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
				definePlayStateShit();
				var preloadList:Map<String, String> = new Map<String, String>();
				
				//if (!FlxG.save.data.cacheMusic)
				//{
				preloadList.set(PlayState.SONG.song, 'inst');
				if (PlayState.SONG.needsVoices)
					preloadList.set(PlayState.SONG.song, 'voices');
				if (PlayState.SONG.needsMiscs)
					preloadList.set(PlayState.SONG.song, 'miscs');
				if (PlayState.SONG.needsAdaptiveMus)
					preloadList.set(PlayState.SONG.song, 'adaptiveMus');
				//}

				switch (songLowercase)
				{
					case "mic-test":
						preloadList.set('skipButton', 'image-in-week-library');
					case "desperation" | "disagreement" | "retaliation":
						preloadList.set('glitch_1', 'sound-in-week-library');
						preloadList.set('glitch_2', 'sound-in-week-library');
						if (songLowercase == 'desperation')
							preloadList.set('Table_Crash', 'sound-in-week-library');
						else if (songLowercase == 'retaliation')
							preloadList.set('week2/midcutscene2-MUSIC', 'video-music');
					case "variegated-skylines":
						for (i in 0...9)
						{
							preloadList.set('theCityPortalOpen/effects/stageParticle_' + i, 'image-in-week-library');
						}
					case "finale":
						var soundNameArr:Array<String> = ["drums_0", "drums_1", "drums_2", "drums_3", "drums_climax", "taiko_0", "taiko_1", "taiko_2", "taiko_3", 
						"taiko_4", "taiko_5", "choir_0", "choir_1", "hats_0", "hats_1", "woodwinds", "violin", "slayer_0", "slayer_1", "slayer_climax", "retal-hats_0", 
						"retal-hats_1", "bells_0", "bells_1", "pads_0", "pads_1", "pads_climax", "pads_climax_bosslowhp", "elecpiano_climax", "danger-loop", "stab"]; //THANK YOU BSOD#2524 FROM HAXE DISCORD SERVER!!!!
						for (i in soundNameArr) 
							preloadList.set('finaleAdaptiveMus/' + i, 'music-in-week-library');
				}

				//Preloading of stages
				if (!FlxG.save.data.optimize)
				{
					var stageCheck:String = 'default';
					if (PlayState.SONG.stage == null || PlayState.SONG.stage == '' || PlayState.SONG.stage == ' ')
					{
						switch (PlayState.storyWeek)
						{
							case 2:
								stageCheck = 'theBorder';
							case 3:
								if (songLowercase == "variegated-skylines")
									stageCheck = 'theCityPortal';
								else
									stageCheck = 'theCity';
							case 4:
								stageCheck = 'theHouse';
							default:
								stageCheck = 'default';
						}
					}
					else
						stageCheck = PlayState.SONG.stage;

					//Stages
					switch (stageCheck)
					{
						case 'theBorder':
							preloadList.set('theborder_bg', 'image-in-week-library');
							preloadList.set('theborder_floor', 'image-in-week-library');
							if (songLowercase == 'retaliation')
								preloadList.set('theborder_people', 'image-in-week-library');
							preloadList.set('vignette_black', 'image-in-week-library');

						case 'theCity':
							preloadList.set('theCity/sky', 'image-in-week-library');
							preloadList.set('theCity/city', 'image-in-week-library');
							for (i in 0...5)
								preloadList.set('theCity/win' + i, 'image-in-week-library');
							preloadList.set('theCity/behindStreet', 'image-in-week-library');
							preloadList.set('theCity/street', 'image-in-week-library');
							preloadList.set('theCity/vignette', 'image-in-week-library');

						case 'theCityPortal':
							preloadList.set('theCityPortalOpen/sky_variegated', 'image-in-week-library');
							preloadList.set('theCityPortalOpen/city_portal', 'image-in-week-library');
							preloadList.set('theCityPortalOpen/behindStreet_Portal', 'image-in-week-library');
							preloadList.set('theCityPortalOpen/street_portal', 'image-in-week-library');
							preloadList.set('theCity/vignette', 'image-in-week-library');

						case 'theHouse':
							preloadList.set('house/HouseBG', 'image-in-week-library');
							preloadList.set('house/ParralaxObjects1', 'image-in-week-library');
							preloadList.set('house/ParralaxFloor', 'image-in-week-library');
							preloadList.set('house/ParralaxObjects2Shadow', 'image-in-week-library');
							preloadList.set('house/ParralaxObjects2', 'image-in-week-library');
							preloadList.set('house/BlendLight_Window1', 'image-in-week-library');
							preloadList.set('house/BlendLight_Window2', 'image-in-week-library');
							
						default:
							preloadList.set('graduation/graduation_back', 'image-in-week-library');
							preloadList.set('graduation/graduation_front', 'image-in-week-library');
							preloadList.set('graduation/graduation_overlay', 'image-in-week-library');
					}

				}

				//Vibdeo preloadfing???
				if (PlayState.isStoryMode)
				{
					for (i in PlayState.videoPathArray)
						preloadList.set(i, 'video');
				}
				
				var gameplaySFX:Array<String> = ["skipSongIntro", "intro3", "intro2", "intro1", "introGo", "missnote1", "missnote2", "missnote3", "enemyMiss1", "enemyMiss2", "enemyMiss3", "GitarooFail", "GitarooPress", "GitarooHover", "deathsound-practice", "styleOnEm", "pauseMenu", "comboBreak1", "comboBreak2", "comboBreak3", "comboBreakBig1", "comboBreakBig2", "comboBreakBig3"]; //THANK YOU STILL BSOD#2524 FROM HAXE DISCORD SERVER!!!!
				for (i in gameplaySFX) 
					preloadList.set(i, 'sound');

				var imagesToCache:Array<String> = [];
				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images")))
				{
					if (i.endsWith(".png") && i != "lol.png" && i != "screencapTierImage.png" && i != "zzzzzzzz.png")
					{
						i = StringTools.replace(i, ".png", "");
						imagesToCache.push(i);
					}
				}

				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/countdown")))
				{
					if (i.endsWith(".png"))
					{
						i = 'countdown/' + StringTools.replace(i, ".png", "");
						imagesToCache.push(i);
					}
				}
				for (i in imagesToCache) 
					preloadList.set(i, 'image');

				for (i in 0...10) 
				{
					preloadList.set('num' + i, 'image');
				}

				preloadList.set(PlayState.pauseMusicName, 'music');

				if (PlayState.dadSwaperoo != "")// && !FlxG.save.data.cacheImages)
				{
					trace('preloaded Dad Swaperoo!!!');
					preloadList.set("characters/" + PlayState.dadSwaperoo, 'image');
					var swaperooIconPath:String = 'icons/' + HealthIcon.getIconID(PlayState.dadSwaperoo);
					preloadList.set(swaperooIconPath, 'image');
				}

				//Le GameOver Music and SFX
				preloadList.set("deathsound" + PlayState.stageSuffix, 'sound');
				preloadList.set("lose_screen/gameOver" + PlayState.stageSuffix, 'music');
				//guh sticks and ducktape!
				for (i in PlayState.gameOversWithIntros)
					if (PlayState.stageSuffix == i)
						preloadList.set("lose_screen/gameOver" + PlayState.stageSuffix + "_Intro", 'music');
				preloadList.set("lose_screen/gameOver" + PlayState.stageSuffix + "_End", 'music');
				preloadList.set('Gameover_0', 'image');
				preloadList.set('Gameover_1', 'image');

				if (FlxG.save.data.notesfx)
				{
					if (FlxG.save.data.botplay)
					{
						PlayState.hitsoundType = "botplay";
						preloadList.set('Note_botplay', 'sound');
					}
					else
					{
						PlayState.hitsoundType = FlxG.save.data.notesfxType;

						var soundsToPreload:Array<String> = [];
						switch (PlayState.hitsoundType)
						{
							case "chill":
								soundsToPreload = ["Note_chill_Sick", "Note_chill_Good", "Note_chill_Bad", "Note_chill_Crap", "Note_chill_Sustain"];
							case "osu":
								soundsToPreload = ["Note_osu_Sick", "Note_osu_Good", "Note_osu_Bad", "Note_osu_Crap", "Note_osu_Sustain"];
							case "bubble":
								soundsToPreload = ["Note_bubble_Sick", "Note_bubble_Good", "Note_bubble_Bad", "Note_bubble_Crap", "Note_bubble_Sustain"];
							case "custom":
								soundsToPreload = ["Note_custom_Sick", "Note_custom_Good", "Note_custom_Bad", "Note_custom_Crap", "Note_custom_Sustain"];
							default:
								soundsToPreload = ["Note_default_Sick", "Note_default_Good", "Note_default_Bad", "Note_default_Crap", "Note_default_Sustain"];
						}
						
						for (i in soundsToPreload)
							preloadList.set(i, 'sound');
					}
				}

				if (PlayState.SONG.song == "Playing With Fire" || PlayState.SONG.song == "Variegated Skylines")
				{
					preloadList.set('Note_Mine', 'sound');
					preloadList.set('Note_Trigger', 'sound');
					preloadList.set('damageAlert_1', 'sound');
					preloadList.set('damageAlert_2', 'sound');
					preloadList.set('damageAlert_3', 'sound');
					preloadList.set('damageAlert_fail', 'sound');
				}

				if (FlxG.save.data.scoreScreen)
					preloadList.set('ResultsScreenAppear', 'sound');
				
				screen = new LoadingScreen(instantShow, inPlayState);
				add(screen);

				for (key in preloadList)
					screen.toDo++;

				var pathLibrary:String = "week" + PlayState.storyWeek;
				if (PlayState.storyWeek == 0)
					pathLibrary = "tutorial";

				Thread.create(() ->
				{
					for (key => type in preloadList)
					{
						trace("Preloading " + key + " (" + type + ")");
						switch(type)
						{
							case 'video':
								trace('starting vid cache');
								var video = new VideoHandler();
								var vidSprite = new FlxSprite(0, 0);
								video.finishCallback = null;
								video.playMP4(Paths.video(key), false, vidSprite, false, false, false);
								video.kill();
								trace('finished vid cache');
							case 'image':
								Paths.image(key, 'shared');
							case 'image-in-week-library':
								Paths.image(key, pathLibrary);
							case 'sound':
								Paths.sound(key, 'shared');
							case 'sound-in-week-library':
								Paths.sound(key, pathLibrary);
							case 'music':
								Paths.music(key, 'shared');
								trace('WOAGH! PATH.MUSIC!');
							case 'music-in-week-library':
								Paths.music(key, pathLibrary);
							case 'video-music':
								Paths.videoMusic(key);
							case 'inst':
								Paths.inst(key);
								trace('!!!! CaCHED INST ' + key);
							case 'voices':
								Paths.voices(key);
								trace('!!!! CaCHED VOICES ' + key);
							case 'miscs':
								Paths.miscs(key);
								trace('!!!! CaCHED MISCS ' + key);
							case 'adaptiveMus':
								Paths.adaptiveMus(key);
						}
						//#if debug
						trace("Preloaded " + key + " (" + type + ")");
						//#end
						screen.done++;
					}
					
					screen.fadeOutShits();
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						stopMusic = true;
						loadAndSwitchState(target, stopMusic, false);
					});
				});
			
			//IN PAIN - TOO LAZY TO FIX UP PATHS.JSON TO WORK WITH THIS SHIT AUGHHHH
			case lore_minigames.MinigameState:	
				screen = new LoadingScreen(instantShow, inPlayState);
				add(screen);

				for (i in sys.FileSystem.readDirectory('assets/minigame/music'))
					screen.toDo++;

				for (i in sys.FileSystem.readDirectory('assets/minigame/music/map_1'))
					screen.toDo++;

				for (i in sys.FileSystem.readDirectory('assets/minigame/sounds'))
					screen.toDo++;

				Thread.create(() ->
				{
					for (i in sys.FileSystem.readDirectory('assets/minigame/music'))
					{
						trace(i);
						if (i.endsWith(".ogg"))
						{
							i = 'assets/minigame/music/' + i;
							FlxG.sound.load(i);
							screen.done++;
						}
					}

					for (i in sys.FileSystem.readDirectory('assets/minigame/music/map_1'))
					{
						trace(i);
						if (i.endsWith(".ogg"))
						{
							i = 'assets/minigame/music/map_1/' + i;
							FlxG.sound.load(i);
							screen.done++;
						}
					}

					for (i in sys.FileSystem.readDirectory('assets/minigame/sounds'))
					{
						trace(i);
						if (i.endsWith(".ogg"))
						{
							i = 'assets/minigame/music/sounds' + i;
							FlxG.sound.load(i);
							screen.done++;
						}
					}

					screen.fadeOutShits();
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						stopMusic = true;
						loadAndSwitchState(target, stopMusic, false);
					});
				});

			default:
				loadAndSwitchState(target, true, false);
		}
	}

	public static function loadAndSwitchState(target:FlxState, stopMusic:Bool = true, defineShitHere:Bool = true)
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Paths.setCurrentLevel("week" + PlayState.storyWeek);

		if (defineShitHere)
			definePlayStateShit();

		trace('uutopoz: ' + FlxG.autoPause);

		FlxG.switchState(target);
	}

	public static function definePlayStateShit():Void
	{
		//for PauseMusic
		if(!Main.todayIsSunday)
		{
			switch (PlayState.storyWeek)
			{
				case 2:
					PlayState.pauseMusicName = 'pause_screen/callous_desperation';
				case 3:
					if (PlayState.SONG.song != 'Variegated Skylines')
						PlayState.pauseMusicName = 'pause_screen/heated_stalemate';
					else
						PlayState.pauseMusicName = 'pause_screen/holy_shit_the_stalemate_is_on_fire';
				default:
					PlayState.pauseMusicName = 'pause_screen/bathroom_break';
			}
		}
		else
			PlayState.pauseMusicName = 'pause_screen/today_is_a_sunday_pauseMix';

		//dadSwaperoos and videoPathArrays
		switch (PlayState.SONG.song)
		{
			case "Tech. Difficulties":
				PlayState.videoPathArray = ['week1/startcutscene'];
			case "Up and Beyond":
				PlayState.videoPathArray = ['week1/endcutscene'];
			case "Desperation":
				PlayState.videoPathArray = ['week2/startcutscene'];
				PlayState.dadSwaperoo = "priest-theborderannoyed";
			case "Disagreement":
				PlayState.videoPathArray = ['week2/midcutscene1'];
			case "Retaliation":
				PlayState.videoPathArray = ['week2/midcutscene2', 'week2/endcutscene'];
		}

		//for Gameover StageSuffix. Moved here to allow pre-caching of the sounds.
		//Could maybe be used for somethin else
		switch (PlayState.SONG.player1)
		{
			case 'selfsert-default':
				PlayState.stageSuffix = '-selfsert';
			default:
				switch (PlayState.SONG.song)
				{
					case "Mic Test":
						PlayState.stageSuffix = '-tutorial';
					case "Sudden Confrontation" | "Sprouting Irritation" | "Striking Tribulation":
						PlayState.stageSuffix = '-pissed';
					default:
						PlayState.stageSuffix = '';
				}
		}
	}
}