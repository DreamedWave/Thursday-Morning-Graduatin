//IN PAIN - TOO LAZY TO FIX UP PATHS.JSON TO WORK WITH THIS SHIT AUGHHHH
package lore_minigames;

import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.util.FlxAxes;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.system.FlxSoundGroup;

import lore_minigames.DoorPortal;

class MinigameState extends MusicBeatState
{
	var player:Player;
	var map:FlxOgmo3Loader;

	var walls:FlxTilemap;
	var doorsGroup:FlxTypedGroup<DoorPortal>;
	var doorsLocationMap:Map<String, Array<Float>> = new Map<String, Array<Float>>(); //Format ([PortalID, PortalDestination], [PortalX, PortalY])
	var clatterGroup:FlxTypedGroup<FlxSprite>;

	var movedBack:Bool = false;
	public static var shakeCam:Bool = false;

	var clatter:Int = 0; //basically the decked out clank system :)))
	var risk:Int = 0; //basically the decked hazard system :DDD

	var heartBeatLevel:Int = 0;

	var pseudoCamFade:FlxSprite;
	var blackScreen:FlxSprite;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var screen:LoadingScreen = null;

	var preEscMusGroup:FlxSoundGroup;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		Conductor.changeBPM(115);

		preEscMusGroup = new FlxSoundGroup(1);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		transIn.camera = camHUD;
		transOut.camera = camHUD;

		camGame.zoom = 6;
		//trace('mmm');
		map = new FlxOgmo3Loader('assets/minigame/rooms/minigame.ogmo', 'assets/minigame/rooms/room_0.json');
		//trace("buh");
		walls = map.loadTilemap("assets/minigame/images/tilemap.png", "tiles");
		//trace("bruh");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, NONE);
		walls.setTileProperties(3, ANY);
		walls.setTileProperties(4, ANY);
		walls.setTileProperties(5, ANY);
		walls.setTileProperties(6, ANY);
		walls.setTileProperties(7, ANY);
		walls.setTileProperties(8, NONE);
		walls.setTileProperties(9, NONE);
		//trace("???");
		add(walls);

		doorsGroup = new FlxTypedGroup<DoorPortal>();
		add(doorsGroup);
		
		clatterGroup = new FlxTypedGroup<FlxSprite>();
		add(clatterGroup);

		player = new Player();
		map.loadEntities(placeEntities, "entities");

		add(player);

		//trace("finally");
		FlxG.camera.follow(player, LOCKON, 1);

		pseudoCamFade = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF000000);
		pseudoCamFade.scrollFactor.set();
		pseudoCamFade.alpha = 0;
		pseudoCamFade.cameras = [camHUD];
		add(pseudoCamFade);
		
		blackScreen = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF000000);
		blackScreen.scrollFactor.set();
		blackScreen.alpha = 0;
		blackScreen.cameras = [camGame];
		blackScreen.blend = MULTIPLY;
		add(blackScreen);

		var minigameSFX:Array<String> = ["walk0", "walk1", "walk2", "walk3", "walk4", "walk5", "jump0", "jump1", "jump2", "jump3", "jump4", "jump5"]; //, "land0", "land1", "land2", "land3", "land4", "land5", "landHard0", "landHard1", "landHard2", "landHard3", "landHard4", "landHard5"];
		for (i in minigameSFX)
		{
			FlxG.sound.load('assets/minigame/sounds/' + i + '.ogg');
		}
		
		super.create();

		heartBeatLevel = 0;
		FlxG.sound.playMusic('assets/minigame/music/HeartbeatLoop' + heartBeatLevel + '.ogg', 1, false);
		FlxG.sound.music.looped = true;
		FlxG.sound.music.autoDestroy = false;
		FlxG.sound.music.onComplete = checkAndSwapMusic;
	}

	var inEscSeq:Bool = false;
	var seqCheck:Int = 0;
	
	private function checkAndSwapMusic()
	{
		if (clatter <= 6)
		{
			if (heartBeatLevel < clatter)
			{
				heartBeatLevel = clatter;
				FlxG.sound.playMusic('assets/minigame/music/HeartbeatLoop' + heartBeatLevel + '.ogg', 1, false);
				FlxG.sound.music.looped = true;
				FlxG.sound.music.autoDestroy = false;
				FlxG.sound.music.onComplete = checkAndSwapMusic;
			}
		}
		else
		{
			switch (seqCheck)
			{
				case 0:
					inEscSeq = true;
					FlxG.sound.music.looped = false;
					FlxG.sound.music.stop();
					FlxG.sound.play('assets/minigame/music/YoureFucked.ogg', 1, false);
					fakeBeat = 0;
					Conductor.songPosition = 0;
					beatFlavoured = 0;

					//Bro there's like 3 tweens in this-
					FlxTween.tween(camGame, {angle: -1.5, zoom: 6.25}, Conductor.crochet * 16 / 1000, 
					{	
						type: ONESHOT, 
						ease: FlxEase.smoothStepOut,
						onComplete: function(twn:FlxTween)
						{
							camGame.zoom += 0.45;
							blackScreen.alpha = 0;
							seqCheck++;
							FlxG.sound.playMusic('assets/minigame/music/ExitSequenceThemeV1.ogg', 1, false);
							FlxG.sound.music.looped = true;
							FlxG.sound.music.autoDestroy = false;
							FlxG.sound.music.onComplete = checkAndSwapMusic;
						}
					});
					FlxTween.tween(preEscMusGroup, {volume: 0}, Conductor.crochet * 8 / 1000, 
					{	
						type: ONESHOT, 
						ease: FlxEase.smoothStepOut,
						onComplete: function(twn:FlxTween)
						{
							preEscMusGroup.stop();
						}
					});
					FlxTween.tween(blackScreen, {alpha: 0.45}, Conductor.crochet * 10 / 1000, {type: ONESHOT, ease: FlxEase.smoothStepOut, startDelay: Conductor.crochet * 6 / 1000});

				default:
					trace('yep is workin as intended');
			}
		}
	}

	var totalDone:Int = 0;
	
	private function placeEntities(entity:EntityData, totalItems:Int)
	{
		if (entity.name == "player")
			player.setPosition(entity.x, (entity.y - 32) + player.height);
		else if (entity.name == "portal_door")
		{
			//definitely make a class for this
			var door:DoorPortal = new DoorPortal();
			door.setPosition(entity.x, entity.y);
			door.destinationID = entity.values.destinationInt;
			door.emitParticles = entity.values.emitParticles;
			door.locationID = entity.values.portal_ID + '_' + entity.values.destinationInt;
			doorsLocationMap.set(door.locationID, [entity.x, entity.y]);
			doorsGroup.add(door);
		}
		else if (entity.name == "clatter_producer")
		{
			//definitely make a class for this
			var clatterers:FlxSprite = new FlxSprite();
			clatterers.makeGraphic(32, 32, 0xFF640000);
			clatterers.setPosition(entity.x, entity.y);
			clatterers.alpha = 0.15;
			clatterGroup.add(clatterers);
			//clatterProducer.type = entity.type;
		}
		totalDone++;

		if (totalDone < totalItems)
			return;

		//Goes through every item in doorsGroup!
		doorsGroup.forEach(function(bobuxDoors:DoorPortal)
		{
			//get Location ID and split
			var split:Array<String> = bobuxDoors.locationID.split('_');
			//THEN invert the shit
			var loadID:String = '';
			if (Std.parseInt(split[1]) == 0)
				loadID = split[0] + '_1';
			else if (Std.parseInt(split[1]) == 1)
				loadID = split[0] + '_0';

			//Then retrieve the coords to place the player in!
			var locationArray:Array<Float> = doorsLocationMap.get(loadID);
			switch (Std.parseInt(split[1]))
			{
				case 0 | 1:
					bobuxDoors.destination[0] = Std.int(locationArray[0]);
					bobuxDoors.destination[1] = Std.int(locationArray[1]);
					trace ('set door ' + bobuxDoors.locationID + "'s tp coords to [" + locationArray[0] + ', ' + locationArray[1] + '].');
				default:
					//do nada for now >:))
			}
		});
	}

	var canDoor:Bool = true; //determines if player can interact withd doors
	var canClatter:Bool = true;

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music.playing)
			Conductor.songPosition += FlxG.elapsed * 1000;

		super.update(elapsed);

		if (controls.BACK && !movedBack)
		{
			//Week dependent Cancel Menu Sounds
			switch (FlxG.save.data.weekUnlocked)
			{
				case 2:
					FlxG.sound.play(Paths.sound('cancelMenu'));
				case 3:
					FlxG.sound.play(Paths.sound('cancelMenu'));
				case 6:
					FlxG.sound.play(Paths.sound('cancelMenu'));
				default:
					if (!FreeplayState.freeplayMusicPlaying)
						FlxG.sound.play(Paths.sound('cancelMenu'));
					else
						FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			movedBack = true;
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
		}
		
		if (FlxG.keys.justPressed.R)
		{
			isResetting = true;
			FlxG.resetState();
		}

		FlxG.collide(player, walls);
		
		if (clatter > 7)
			clatter = 7;

		if (FlxG.keys.justPressed.E && canDoor)
		{
			doorsGroup.forEach(function(bobuxDoor:DoorPortal)
			{
				if (player.overlaps(bobuxDoor))
				{
					canDoor = false;
					FlxG.sound.play('assets/minigame/sounds/doorSND_Placeholder.ogg', 1);
					new FlxTimer().start(Conductor.stepCrochet / 1000, function(tmr:FlxTimer)
					{
						if (pseudoCamFade.alpha < 1)
							pseudoCamFade.alpha += 0.25;
						else
						{
							player.setPosition(bobuxDoor.destination[0], bobuxDoor.destination[1]);
							new FlxTimer().start(Conductor.stepCrochet / 2 / 1000, function(tmr:FlxTimer)
							{
								if (pseudoCamFade.alpha > 0)
									pseudoCamFade.alpha -= 0.25;
								else
									canDoor = true;
							}, 5);
						}
					}, 5);
				}
			});
		}

		if (canClatter)
		{
			clatterGroup.forEach(function(clutterer:FlxSprite)
			{
				if (player.overlaps(clutterer))
				{
					canClatter = false;
					clatter++;
					FlxG.sound.play('assets/minigame/sounds/clatterSND_Placeholder.ogg', 1);
					new FlxTimer().start(5, function(tmr:FlxTimer)
					{
						canClatter = true;
					});
				}
			});
		}

		if (shakeCam)
		{
			shakeCam = false;
			camShake(true, false, 0.025, 0.2);
		}

		if (seqCheck > 0)
		{
			camGame.zoom = FlxMath.lerp(6, camGame.zoom, PlayStateHelpers.calculateLerpTime(elapsed, 3, 0, 1));
			blackScreen.alpha = FlxMath.lerp(0.25, blackScreen.alpha, PlayStateHelpers.calculateLerpTime(elapsed, 1, 0, 1));
		}
	}

	var droneDeterminator:Int = 1;
	var uniformDeterminator:Int = 1;
	var additionsDeterminator:Int = 1;
	var flavourDeterminator:Int = 0;
	var fakeBeat:Int = 0;

	var beatOffset:Int = 0;
	var beatFlavoured:Int = 0;
	
	//Ripped from playstate???\
	//stfu im very prouc of this function it is cook
	//chuu~
	function camShake(force:Bool = true, decay:Bool = false, intensity:Float = 0.03, duration:Float = 0.25, axis:FlxAxes = XY):Void
	{
		if (decay)
		{
			intensity *= 2;
			duration *= 2;
		}

		camGame.shake(intensity, duration, force, decay, axis);
	}

    override function beatHit()
	{
		super.beatHit();

		switch (seqCheck)
		{
			case 0:
				if (!inEscSeq)
				{
					if (fakeBeat % 32 == 0)
					{
						//Randomise Tracks
						switch (clatter)
						{
							case 0:
								droneDeterminator = 1;
								additionsDeterminator = 1;
								uniformDeterminator = 0;
							case 1 | 2:
								uniformDeterminator = 1;
								if (FlxG.random.bool(50))
									droneDeterminator = FlxG.random.int(1, 2);
				
								if (FlxG.random.bool(50))
									additionsDeterminator = FlxG.random.int(1, 2);
							case 3:
								uniformDeterminator = 1;
								if (FlxG.random.bool(80))
									droneDeterminator = FlxG.random.int(1, 2);
								
								if (FlxG.random.bool(80))
									additionsDeterminator = FlxG.random.int(1, 2);
							case 4:
								uniformDeterminator = 2;
								droneDeterminator = FlxG.random.int(1, 2);
								additionsDeterminator = FlxG.random.int(1, 2);
							default:
								uniformDeterminator = 2;
								droneDeterminator = 2;
								additionsDeterminator = 2;
						}

						FlxG.sound.play('assets/minigame/music/PadsDrone' + droneDeterminator + '.ogg', 1, false, preEscMusGroup);
						if (uniformDeterminator > 0)
							FlxG.sound.play('assets/minigame/music/BackingPads' + uniformDeterminator + '.ogg', 0.75, false, preEscMusGroup);
						FlxG.sound.play('assets/minigame/music/Additions' + additionsDeterminator + '.ogg', 1, false, preEscMusGroup);
					}

					switch (clatter)
					{
						case 0:
							flavourDeterminator = 0;
						case 1 | 2 | 3:
							if (FlxG.random.bool(50))
								flavourDeterminator = FlxG.random.int(1, 2);
			
							if (FlxG.random.bool(50))
								flavourDeterminator = FlxG.random.int(1, 2);
						default:
							flavourDeterminator = FlxG.random.int(1, 4);
					}

					if (flavourDeterminator > 0)
					{
						if(FlxG.random.bool(0.85) && curBeat >= beatFlavoured + beatOffset)
						{
							beatFlavoured = curBeat;
							beatOffset = FlxG.random.int(0, 16);
							FlxG.sound.play('assets/minigame/music/FlavourSFX' + flavourDeterminator + '.ogg', FlxG.random.float(0.5, 0.8), false);
						}
					}
				}
			
			case 1:
				camShake(false, false, 0.01, Conductor.crochet / 1000 - 0.01);
				if (curBeat % 4 == 0)
				{
					camGame.zoom += 0.25;
					blackScreen.alpha = 0;
				}

				if (FlxG.random.bool(45) && curBeat % 32 == 0)
				{
					flavourDeterminator = FlxG.random.int(1, 4);
					FlxG.sound.play('assets/minigame/music/FlavourSFXSuspense' + flavourDeterminator + '.ogg', FlxG.random.float(0.8, 1), false);

					//Have a chance to have layered additions
					if (FlxG.random.bool(30))
					{
						flavourDeterminator = FlxG.random.int(1, 4);
						FlxG.sound.play('assets/minigame/music/FlavourSFX' + flavourDeterminator + '.ogg', FlxG.random.float(0.9, 1), false);
					}
				}
		}

		fakeBeat++;
	}

	var isResetting:Bool = false;
	override function destroy()
	{
		FlxG.sound.music.stop();
		if (!isResetting)
		{
			transIn.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
			transOut.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
		}
	}
}