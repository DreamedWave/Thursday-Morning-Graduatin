//IN PAIN - TOO LAZY TO FIX UP PATHS.JSON TO WORK WITH THIS SHIT AUGHHHH
package lore_minigames;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.util.FlxAxes;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.system.FlxSoundGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

//import lore_minigames.Interactibles;
//import lore_minigames.Clatterer;
//import lore_minigames.Collectibles;

class MinigameState extends MusicBeatState
{
	var player:Player;
	var map:FlxOgmo3Loader;

	var walls:FlxTilemap;
	var interactiblesGroup:FlxTypedGroup<Interactibles>;
	var doorsLocationMap:Map<String, Array<Float>> = new Map<String, Array<Float>>(); //Format ([PortalID, PortalDestination], [PortalX, PortalY])
	var clatterGroup:FlxTypedGroup<Clatterer>;
	var collectiblesGroup:FlxTypedGroup<Collectibles>;

	var movedBack:Bool = false;
	public static var shakeCam:Bool = false;

	var clatter:Int = 0; //basically the decked out clank system :))) | set to -2 until we can reliably calc adaptive caps (check out what you did for the enemy dmg in pico week)
	var risk:Int = 0; //basically the decked hazard system :DDD

	var heartBeatLevel:Int = 0;

	var pseudoCamFade:FlxSprite;
	var blackScreen:FlxSprite;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;
	var defaultCamZoom = 6;

	var screen:LoadingScreen = null;

	var preEscMusGroup:FlxSoundGroup;

	public static var weekNum:Int = 0;

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

		camGame.zoom = defaultCamZoom;
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

		interactiblesGroup = new FlxTypedGroup<Interactibles>();
		add(interactiblesGroup);
		
		clatterGroup = new FlxTypedGroup<Clatterer>();
		add(clatterGroup);

		collectiblesGroup = new FlxTypedGroup<Collectibles>();
		add(collectiblesGroup);

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
		//FlxG.sound.music.onComplete = checkAndSwapMusic;
	}

	var inEscSeq:Bool = false;
	var seqCheck:Int = 0;
	
	private function checkAndSwapMusic()
	{
		if (clatter <= 7)
		{
			if (heartBeatLevel < clatter)
			{
				trace('increased heartrate');
				heartBeatLevel = clatter;
				FlxG.sound.music.stop();
				FlxG.sound.playMusic('assets/minigame/music/HeartbeatLoop' + heartBeatLevel + '.ogg', 1, false);
				FlxG.sound.music.looped = true;
				FlxG.sound.music.autoDestroy = false;
				//FlxG.sound.music.onComplete = checkAndSwapMusic;
			}
			else
				trace ('whadagfak ' + clatter);
		}
		else
		{
			switch (seqCheck)
			{
				case 0:
					//Moved to a funct for easy??
					triggerEscapeSeq();
				default:
					trace('yep is workin as intended');
			}
		}
	}

	var totalDone:Int = 0;
	
	private function placeEntities(entity:EntityData, totalItems:Int)
	{
		switch (entity.name)
		{
			case 'player':
				player.setPosition(entity.x, (entity.y - 32) + player.height);
			case 'portal_door':
				//definitely make a class for this
				var door:Interactibles = new Interactibles(entity.x, entity.y, DOOR);
				door.destinationID = entity.values.destinationInt;
				door.specialAnimType = entity.values.specialAnimType;
				door.locationID = entity.values.portal_ID + '_' + entity.values.destinationInt;
				door.isLocked = entity.values.isLocked;
				doorsLocationMap.set(door.locationID, [entity.x, entity.y]);
				interactiblesGroup.add(door);
			case 'interactibles':
				var interactibles:Interactibles = new Interactibles(entity.x, entity.y, OTHER);
				interactibles.spriteID = entity.values.spriteID;
				interactibles.dialogueArray = entity.values.dialogue.split('+');
				interactiblesGroup.add(interactibles);
				trace(interactibles.dialogueArray);
			case 'memory_collectible':
				var secretPickup:Collectibles = new Collectibles(entity.x, entity.y, SECRET);
				collectiblesGroup.add(secretPickup);
			case 'final_collectible':
				var finalPickup:Collectibles = new Collectibles(entity.x, entity.y, FINAL);
				collectiblesGroup.add(finalPickup);
			case 'clatter_producer':
				//definitely make a class for this
				var clatterers:Clatterer = new Clatterer(entity.x, entity.y);
				clatterGroup.add(clatterers);
			case 'enemy':
				//enemyType
		}
		totalDone++;

		if (totalDone < totalItems)
			return;

		//Goes through every item in interactiblesGroup!
		//Set door locations
		interactiblesGroup.forEach(function(bobuxDoors:Interactibles)
		{
			if (bobuxDoors.type == DOOR)
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
				}
			}
		});
	}

	var canDoor:Bool = true; //determines if player can interact with doors

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
		
		if (clatter > 8)
			clatter = 8;

		//Overlaps
		if (FlxG.keys.justPressed.E)
			FlxG.overlap(player, interactiblesGroup, interactFunct);
		if (!player.isSneaking)
			FlxG.overlap(player, clatterGroup, clatterFunct);
		FlxG.overlap(player, collectiblesGroup, pickupFunct);

		if (shakeCam)
		{
			shakeCam = false;
			camShake(true, false, 0.025, 0.2);
		}

		if (seqCheck > 0)
		{
			camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, PlayStateHelpers.calculateLerpTime(elapsed, 3, 0, 1));
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
	//stfu im very prouc of this function it is cool
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

		if (curBeat % 4 == 0)
		{
			trace ('huh???');
			checkAndSwapMusic();
		}

		switch (seqCheck)
		{
			//Normal
			case 0:
				if (!inEscSeq && clatter >= 0)
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
						if(FlxG.random.bool(0.85) && fakeBeat >= beatFlavoured + beatOffset)
						{
							beatFlavoured = fakeBeat;
							beatOffset = FlxG.random.int(0, 16);
							FlxG.sound.play('assets/minigame/music/FlavourSFX' + flavourDeterminator + '.ogg', FlxG.random.float(0.5, 0.8), false, preEscMusGroup);
						}
					}
				}
			
			//Escape seq
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

	function triggerEscapeSeq():Void
	{
		if (!inEscSeq)
		{
			trace('run for your life');
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
					player.isPanicked = true;
					player.defaultMaxVelocityX = 160;
					player.color = 0xFFFF0000;
					FlxG.sound.playMusic('assets/minigame/music/ExitSequenceThemeV1.ogg', 1, false);
					FlxG.sound.music.looped = true;
					FlxG.sound.music.autoDestroy = false;
					//FlxG.sound.music.onComplete = checkAndSwapMusic;
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
		}
	}

	//Interact Functions
	function interactFunct(player:Player, object:Interactibles)
	{
		switch (object.type)
		{
			case DOOR:
				if (canDoor)
				{
					canDoor = false;
					FlxG.sound.play('assets/minigame/sounds/doorSND_Placeholder.ogg', 1);
					new FlxTimer().start(Conductor.stepCrochet / 1000, function(tmr:FlxTimer)
					{
						if (pseudoCamFade.alpha < 1)
							pseudoCamFade.alpha += 0.25;
						else
						{
							player.setPosition(object.destination[0], object.destination[1]);
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
			case OTHER:
				var placeholderTXT:FlxText = new FlxText(0, FlxG.height - 80, FlxG.width - 100, '', 25);
				placeholderTXT.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				placeholderTXT.scrollFactor.set();
				placeholderTXT.screenCenter(X);
				placeholderTXT.borderSize = 1.25;
				placeholderTXT.cameras = [camHUD];
				add(placeholderTXT);

				var placeHolderCount:Int = 0;
				placeholderTXT.text = object.dialogueArray[0];

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					if (placeHolderCount != object.dialogueArray.length)
						placeholderTXT.text = object.dialogueArray[placeHolderCount];
					else
						placeholderTXT.destroy();
					placeHolderCount++;
				}, object.dialogueArray.length + 1);
		}
	}

	function pickupFunct(player:Player, object:Collectibles)
	{
		if (object.isActive)
		{
			object.isActive = false;
			switch (object.type)
			{
				case FINAL:
					object.kill();
					FlxTween.tween(this, {defaultCamZoom: 7}, 0.1, {type: ONESHOT, ease: FlxEase.smoothStepOut,});
					FlxG.sound.play('assets/minigame/sounds/finalPickupSND_Placeholder.ogg', 1);
					FlxG.timeScale = 0.25;
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						defaultCamZoom = 6;
						FlxG.timeScale = 1;
						FlxG.camera.flash(DisclaimerScreen.flashColor, Conductor.crochet * 4 / 1000);
						clatter = 8;
						triggerEscapeSeq();
					});
				case SECRET:
					object.kill();
					FlxG.sound.play('assets/minigame/sounds/doorSND_Placeholder.ogg', 1);
			}
		}
	}

	function clatterFunct(player:Player, clatterer:Clatterer)
	{
		if ((player.velocity.x > 15 || player.velocity.x < -15) && clatterer.canClatter)
		{
			clatterer.canClatter = false;
			clatter += clatterer.clatterAmt;
			clatterer.playerMadeNoise();
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				clatterer.canClatter = true;
				clatterer.alpha = 0.25;
			});
		}
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