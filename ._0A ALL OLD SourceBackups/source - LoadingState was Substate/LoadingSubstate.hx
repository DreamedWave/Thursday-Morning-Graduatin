package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import sys.thread.Thread;
import sys.FileSystem;

using StringTools;

//Original code from Indie Cross, modified by DreamedWave for TMG
class LoadingSubstate extends MusicBeatMenu
{
	public static var target:FlxState;
	public static var stopMusic:Bool = true;
	public static var doScreenshotShit:Bool = false;

	var screen:LoadingScreen = null;
	var inPlayState:Bool = false;

	public function new(instantShow:Bool = false)
	{
		Paths.clearUnusedMemory();

		super();

		switch(Type.getClass(target))
		{
			case PlayState:
				if (Type.getClass(FlxG.state) == PlayState)
				{
					cameras = [PlayState.instance.camEXT];
					inPlayState = true;
				}
				
				var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
				var preloadList:Map<String, String> = new Map<String, String>();
				
				if (!FlxG.save.data.cacheMusic)
				{
					preloadList.set(PlayState.SONG.song, 'inst');
					if (PlayState.SONG.needsVoices)
						preloadList.set(PlayState.SONG.song, 'voices');
					if (PlayState.SONG.needsMiscs)
						preloadList.set(PlayState.SONG.song, 'miscs');
					if (PlayState.SONG.needsAdaptiveMus)
						preloadList.set(PlayState.SONG.song, 'adaptiveMus');
				}

				switch (PlayState.SONG.song)
				{
					case "Mic Test":
						preloadList.set('skipButton', 'image-in-week-library');
					case "Desperation" | "Disagreement" | "Retaliation":
						preloadList.set('glitch_1', 'sound-in-week-library');
						preloadList.set('glitch_2', 'sound-in-week-library');
						if (PlayState.SONG.song == 'Desperation')
							preloadList.set('Table_Crash', 'sound-in-week-library');
						else if (PlayState.SONG.song == 'Retaliation')
							preloadList.set('week2/midcutscene2-MUSIC', 'video-music');
					case "Variegated Skylines":
						for (i in 0...9)
						{
							preloadList.set('theCityPortalOpen/effects/stageParticle_' + i, 'image-in-week-library');
						}
					case "Finale":
						var soundNameArr:Array<String> = ["drums_0", "drums_1", "drums_2", "drums_3", "drums_climax", "taiko_0", "taiko_1", "taiko_2", "taiko_3", 
						"taiko_4", "taiko_5", "choir_0", "choir_1", "hats_0", "hats_1", "woodwinds", "violin", "slayer_0", "slayer_1", "slayer_climax", "retal-hats_0", 
						"retal-hats_1", "bells_0", "bells_1", "pads_0", "pads_1", "pads_climax", "pads_climax_bosslowhp", "elecpiano_climax", "danger-loop", "stab"]; //THANK YOU BSOD#2524 FROM HAXE DISCORD SERVER!!!!
						for (i in soundNameArr) 
							preloadList.set('finaleAdaptiveMus/' + i, 'music');
				}

				//Preloading of stages
				if (!PlayStateChangeables.Optimize)
				{
					var stageCheck:String = 'default';
					if (PlayState.SONG.stage == null || PlayState.SONG.stage == '' || PlayState.SONG.stage == ' ')
					{
						switch (PlayState.storyWeek)
						{
							case 2:
								stageCheck = 'theBorder';
							case 3:
								if (songLowercase == "variegated skylines")
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
				
				var gameplaySFX:Array<String> = ["skipSongIntro", "intro3", "intro2", "intro1", "introGo", "missnote1", "missnote2", "missnote3", "enemyMiss1", "enemyMiss2", "enemyMiss3", "GitarooFail", "GitarooPress", "GitarooHover", "practiceModeFail", "styleOnEm"]; //THANK YOU STILL BSOD#2524 FROM HAXE DISCORD SERVER!!!!
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

				var leCount:Int = 0;
				for (i in 0...10) 
				{
					preloadList.set('num' + leCount, 'image');
					leCount++;
				}
				
				//Not as bulky as before owo
				var preloadList:Map<String, String> = new Map<String, String>();

				definePlayStateShit();

				preloadList.set(PlayState.pauseMusicName, 'music');

				if (PlayState.dadSwaperoo != "" && !FlxG.save.data.cacheImages)
				{
					preloadList.set("characters/" + PlayState.dadSwaperoo, 'image');
					var swaperooIconPath:String = 'icons/' + PlayStateHelpers.getIconID(PlayState.dadSwaperoo);
					preloadList.set(swaperooIconPath, 'image');
				}

				//Le GameOver Music and SFX
				preloadList.set("deathsound" + PlayState.stageSuffix, 'sound');
				preloadList.set("gameOver" + PlayState.stageSuffix, 'music');
				preloadList.set("gameOver" + PlayState.stageSuffix + "_End", 'music');
				preloadList.set('Gameover_0', 'image');
				preloadList.set('Gameover_1', 'image');

				if (FlxG.save.data.notesfx)
				{
					if (FlxG.save.data.botplay)
						PlayState.hitsoundType = "botplay";
					else
						PlayState.hitsoundType = FlxG.save.data.notesfxType;

					if (!FlxG.save.data.botplay)
					{
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
					preloadList.set('Note_botplay', 'sound');

					if (PlayState.SONG.song == "Playing With Fire" || PlayState.SONG.song == "Variegated Skylines")
					{
						preloadList.set('Note_Mine', 'sound');
						preloadList.set('Note_Trigger', 'sound');
						preloadList.set('damageAlert_1', 'sound');
						preloadList.set('damageAlert_2', 'sound');
						preloadList.set('damageAlert_3', 'sound');
						preloadList.set('damageAlert_fail', 'sound');
					}
				}

				screen = new LoadingScreen(instantShow, inPlayState);
				for (key in preloadList)
					screen.toDo++;
				add(screen);

				var pathLibrary:String = "week" + PlayState.storyWeek;
				if (PlayState.storyWeek == 0)
					pathLibrary = "tutorial";

				Thread.create(() ->
				{
					for (key => type in preloadList)
					{
						//trace("Preloading " + key + " (" + type + ")");
						switch(type)
						{
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
							case 'music-in-week-library':
								Paths.music(key, pathLibrary);
							case 'video-music':
								Paths.videoMusic(key);
							case 'inst':
								Paths.inst(key);
							case 'voices':
								Paths.voices(key);
							case 'miscs':
								Paths.miscs(key);
							case 'adaptiveMus':
								Paths.adaptiveMus(key);
						}
						//#if debug
						trace("Preloaded " + key + " (" + type + ")");
						//#end
						screen.done++;
					}
					
					var leTime:Float = 0.25;
					if(inPlayState)
						0.1;
					FlxTween.tween(screen, {alpha: 0}, (leTime), {type: ONESHOT, ease: FlxEase.smoothStepOut, onComplete:
						function (twn:FlxTween)
						{
							stopMusic = true;
							loadAndSwitchState(target, stopMusic, false);
							close();
						}
					});
				});
			
			default:
				loadAndSwitchState(target, true, false);
				close();
		}
	}

	public static function loadAndSwitchState(target:FlxState, stopMusic:Bool = true, defineShitHere:Bool = true)
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Paths.setCurrentLevel("week" + PlayState.storyWeek);
		if (FlxG.save.data.pauseOnUnfocus)
			FlxG.autoPause = true;

		if (defineShitHere)
			definePlayStateShit();

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
					PlayState.pauseMusicName = 'pauseScreen/callous_desperation';
				case 3:
					if (PlayState.SONG.song != 'Variegated Skylines')
						PlayState.pauseMusicName = 'pauseScreen/heated_stalemate';
					else
						PlayState.pauseMusicName = 'pauseScreen/holy_shit_the_stalemate_is_on_fire';
				default:
					PlayState.pauseMusicName = 'pauseScreen/bathroom_break';
			}
		}
		else
			PlayState.pauseMusicName = 'pauseScreen/today_is_a_sunday_pauseMix';

		//dadSwaperoos
		switch (PlayState.SONG.song)
		{
			case "Desperation":
				PlayState.dadSwaperoo = "priest-theborderannoyed";
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