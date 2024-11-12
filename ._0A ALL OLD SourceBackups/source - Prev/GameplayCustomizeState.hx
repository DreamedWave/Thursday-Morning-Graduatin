import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
#if windows
import Discord.DiscordClient;
import sys.thread.Thread;
#end

import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.ui.Keyboard;
import flixel.FlxSprite;
import flixel.FlxG;

class GameplayCustomizeState extends MusicBeatState
{
    var background:FlxSprite;
    var curt:FlxSprite;
    var front:FlxSprite;

    var sick:FlxSprite;

    var text:FlxText;
    var blackBorder:FlxSprite;

    var bf:Boyfriend;
    var dad:Character;
    var gf:Character;

    var strumLine:FlxSprite;
    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrums:FlxTypedGroup<FlxSprite>;
    private var camHUD:FlxCamera;
    
    public override function create() 
    {
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay Modules", null);
		#end

		//Conductor.changeBPM(102);
		persistentUpdate = true;

        super.create();

        KadeEngineData.initSave();

        background = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback','shared'));
        curt = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains','shared'));
        front = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront','shared'));

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);

        background.scrollFactor.set(0.9,0.9);
        curt.scrollFactor.set(0.9,0.9);
        front.scrollFactor.set(0.9,0.9);

        add(background);
        add(front);
        add(curt);

		var camFollow = new FlxObject(0, 0, 1, 1);

		dad = new Character(100, 100, 'demon-dad');

        bf = new Boyfriend(770, 450, 'guy-default');

        gf = new Character(250, 240, 'table-default');
		gf.scrollFactor.set(0.95, 0.95);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 400, dad.getGraphicMidpoint().y);

		camFollow.setPosition(camPos.x, camPos.y);

        add(gf);
        add(bf);
        add(dad);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = 0.85;
		FlxG.camera.focusOn(camFollow.getPosition());

		strumLine = new FlxSprite(50, 50).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
        strumLine.alpha = 0;
		
		if (FlxG.save.data.downscroll)
        {
			strumLine.y = FlxG.height - 165;
        }

        sick = new FlxSprite().loadGraphic(Paths.image('rating'));
        sick.scrollFactor.set();
        add(sick);

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

        sick.cameras = [camHUD];
        strumLine.cameras = [camHUD];
        playerStrums.cameras = [camHUD];
        
		generateStaticArrows(0);
		generateStaticArrows(1);

        text = new FlxText(5, 0, FlxG.width - 5, "Click and drag around gameplay elements to customize their positions.\nPress [R] to reset.\nPress [ESCAPE] to save and exit.", 12);
		if (!FlxG.save.data.downscroll)
            text.y = FlxG.height;
        else 
            text.y = -text.height;
        text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        
        blackBorder = new FlxSprite(-30, 0).makeGraphic((Std.int(text.width + 100)),Std.int(text.height * 1.3),FlxColor.BLACK);
		blackBorder.alpha = 0;
        if (!FlxG.save.data.downscroll)
            blackBorder.y = FlxG.height - 40 +  blackBorder.height;
        else
            blackBorder.y = -blackBorder.height;
		add(blackBorder);
		add(text);

        if (!FlxG.save.data.downscroll)
        {
		    FlxTween.tween(text,{y: FlxG.height - (text.height + 10)}, 1.1, {ease: FlxEase.elasticInOut});
		    FlxTween.tween(blackBorder,{y: FlxG.height - (blackBorder.height - 5), alpha: 0.6}, 1, {ease: FlxEase.elasticInOut});
        }
        else
        {
		    FlxTween.tween(text,{y: 5}, 1.1, {ease: FlxEase.elasticInOut});
		    FlxTween.tween(blackBorder,{y: -5, alpha: 0.6}, 1, {ease: FlxEase.elasticInOut});
        }

        sick.x = FlxG.save.data.changedHitX;
        sick.y = FlxG.save.data.changedHitY;

        if(FlxG.save.data.antialiasing)
            sick.antialiasing = true;

        FlxG.mouse.visible = true;

    }

    override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        for (i in playerStrums)
            i.y = strumLine.y;
        for (i in strumLineNotes)
            i.y = strumLine.y;

        if (FlxG.mouse.overlaps(sick) && FlxG.mouse.pressed)
        {
            sick.x = FlxG.mouse.x - sick.width / 2;
            sick.y = FlxG.mouse.y - sick.height;
        }    
        else if (FlxG.mouse.overlaps(sick) && FlxG.mouse.justReleased)
        {
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = true;
        }

        if (FlxG.keys.justPressed.R)
        {
            FlxG.save.data.changedHitX = null;
            FlxG.save.data.changedHitY = null; 
            FlxG.save.data.changedHit = false;
            KadeEngineData.initSave();
            sick.x = FlxG.save.data.changedHitX;
            sick.y = FlxG.save.data.changedHitY;
        }

        if (controls.BACK && FlxG.mouse.visible)
        {
            FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new OptionsMenu());
        }

    }

    override function beatHit() 
    {
        super.beatHit();

        if (curBeat % 2 == 1)
        {
            bf.playAnim('idle', true);
            dad.dance(true);
        }
        gf.dance();
        trace('beat');
    }


    // ripped from play state cuz im lazy
    
	private function generateStaticArrows(player:Int):Void
        {
            for (i in 0...4)
            {
                // FlxG.log.add(i);
                var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y + (!FlxG.save.data.downScroll ? -10 : 10));
                babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
                babyArrow.animation.addByPrefix('green', 'arrowUP');
                babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
                babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
                babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
                babyArrow.antialiasing = true;
                babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
                switch (Math.abs(i))
                {
                    case 0:
                        babyArrow.x += Note.swagWidth * 0;
                        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                        babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                    case 1:
                        babyArrow.x += Note.swagWidth * 1;
                        babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                        babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                    case 2:
                        babyArrow.x += Note.swagWidth * 2;
                        babyArrow.animation.addByPrefix('static', 'arrowUP');
                        babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                    case 3:
                        babyArrow.x += Note.swagWidth * 3;
                        babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                        babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
                }
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();
    
                babyArrow.ID = i;
    
                if (player == 1)
                    playerStrums.add(babyArrow);
    
                babyArrow.animation.play('static');
                if(!FlxG.save.data.optimize)
                    babyArrow.x += 50;
                else
                    babyArrow.x -= 275;
                babyArrow.x += ((FlxG.width / 2) * player);
                babyArrow.alpha = 0.5;
    
                strumLineNotes.add(babyArrow);
            }
        }
}