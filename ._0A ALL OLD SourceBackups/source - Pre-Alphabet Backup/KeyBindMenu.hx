package;

/// Code created by Rozebud for FPS Plus (thanks rozebud)
// modified by KadeDev for use in Kade Engine/Tricky
// modified by DreamedWave for Thursday Morning Graduatin'

import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;
import flixel.group.FlxSpriteGroup;


using StringTools;

class KeyBindMenu extends FlxSubState
{

    var keyTextDisplay:FlxText;
    var keyWarning:FlxText;
    var warningTween:FlxTween;
    var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    var defaultKeys:Array<String> = ["A", "S", "W", "D", "R"];
    var defaultGpKeys:Array<String> = ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT"];
    var curSelected:Int = 0;

    var keys:Array<String> = [FlxG.save.data.leftBind,
                              FlxG.save.data.downBind,
                              FlxG.save.data.upBind,
                              FlxG.save.data.rightBind];
    var gpKeys:Array<String> = [FlxG.save.data.gpleftBind,
                              FlxG.save.data.gpdownBind,
                              FlxG.save.data.gpupBind,
                              FlxG.save.data.gprightBind];
    var tempKey:String = "";
    var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"];

    var blackBox:FlxSprite;
    var infoText:FlxText;

    var arrowGroup:FlxSpriteGroup;
    var allTweensGroup:Array<FlxTween> =[];
    var wipTxt:FlxText;
    var keyTextTween:FlxTween;
    var yikers1:FlxTween;
    var yikers2:FlxTween;
    var tweenie:FlxTween;

    var state:String = "select";

	override function create()
	{	

        for (i in 0...keys.length)
        {
            var k = keys[i];
            if (k == null)
                keys[i] = defaultKeys[i];
        }

        for (i in 0...gpKeys.length)
        {
            var k = gpKeys[i];
            if (k == null)
                gpKeys[i] = defaultGpKeys[i];
        }
	
		//FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);

		persistentUpdate = true;

        keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set();
		keyTextDisplay.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, FlxTextAlign.JUSTIFY, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;
        keyTextDisplay.updateHitbox();
        keyTextDisplay.screenCenter();
        keyTextDisplay.x += 350;
        keyTextDisplay.y -= 20;
        keyTextDisplay.alpha = 0;

        
        blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        blackBox.alpha = 0;

        infoText = new FlxText(-10, 580, FlxG.width, 'Current Mode: ${KeyBinds.gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n${KeyBinds.gamepad ? 'R. Trigger' : 'ESC'} to save, ${KeyBinds.gamepad ? 'L. Trigger' : 'BKSP'} to leave without saving, \n${KeyBinds.gamepad ? 'START' : 'ENTER'} to change selected keybind${KeyBinds.gamepad ? '.' : ',\nUP/DOWN to change selection.'}', 72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
        infoText.alpha = 0;
        infoText.screenCenter(X);

        add(blackBox);
        add(infoText);
        add(keyTextDisplay);

        wipTxt = new FlxText(0, 0, 720, 'WIP MENU - Feedback is appreciated!!!', 15);
		wipTxt.setFormat("VCR OSD Mono", 15, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(wipTxt);

        //Sorry i wrote these while theres shit happening in my house so the var names are my reactions to the events that transpired LMAO
        keyTextTween = FlxTween.tween(keyTextDisplay, {alpha: 1}, 0.75, {ease: FlxEase.expoOut, onComplete: 
            function(fuckywucky:FlxTween)
            {
                keyTextTween = null;
            }
        });
       yikers1 = FlxTween.tween(infoText, {alpha: 1}, 0.8, {ease: FlxEase.expoOut, onComplete: 
            function(fuckywucky2:FlxTween)
            {
                yikers1 = null;
            }
        });
        allTweensGroup.push(yikers1);
       yikers2 = FlxTween.tween(blackBox, {alpha: 0.8}, 0.75, {ease: FlxEase.expoOut, onComplete: 
            function(fuckywucky3:FlxTween)
            {
                yikers2 = null;
            }
        });
        allTweensGroup.push(yikers2);

        arrowGroup = new FlxSpriteGroup();
		add(arrowGroup);

        for (i in 0...4)
        {
            // FlxG.log.add(i);
            var babyArrow:FlxSprite = new FlxSprite(50, 100 + (!FlxG.save.data.downScroll ? -10 : 10));
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
                    babyArrow.animation.addByPrefix('select', 'purple alone');
                case 1:
                    babyArrow.x += Note.swagWidth * 1;
                    babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                    babyArrow.animation.addByPrefix('select', 'blue alone');
                case 2:
                    babyArrow.x += Note.swagWidth * 2;
                    babyArrow.animation.addByPrefix('static', 'arrowUP');
                    babyArrow.animation.addByPrefix('select', 'green alone');
                case 3:
                    babyArrow.x += Note.swagWidth * 3;
                    babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                    babyArrow.animation.addByPrefix('select', 'red alone');
            }
            babyArrow.updateHitbox();
            babyArrow.scrollFactor.set();

            babyArrow.ID = i;

            var targetAlpha:Float = 0.5;
            if (i != curSelected)
                babyArrow.animation.play('static');
            else
            {
                babyArrow.animation.play('select');
                targetAlpha = 1;
            }
            babyArrow.x -= 275;
            babyArrow.x += ((FlxG.width / 2) * 1);
            babyArrow.alpha = 0;

            arrowGroup.add(babyArrow);
            tweenie = FlxTween.tween(babyArrow, {y: babyArrow.y + (10), alpha: targetAlpha}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.circOut, startDelay: (0.2 * i),
                onComplete: function(skibidi:FlxTween)
                {
                    tweenie = null;
                }
            });
            allTweensGroup.push(tweenie);
        }

        OptionsMenu.instance.acceptInput = false;

        textUpdate();

		super.create();
	}

    var frames = 0;

	override function update(elapsed:Float)
	{
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

        if (frames <= 10)
            frames++;

        infoText.text = 'Current Mode: ${KeyBinds.gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n${KeyBinds.gamepad ? 'R. Trigger' : 'ESC'} to save, ${KeyBinds.gamepad ? 'L. Trigger' : 'BKSP'} to leave without saving, \n${KeyBinds.gamepad ? 'START' : 'ENTR'} to change selected keybind${KeyBinds.gamepad ? '.' : ',\nUP/DOWN to change selection.'}\n${lastKey != "" ? lastKey + " is blacklisted!" : ""}';

        switch(state)
        {
            case "select":
                if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeItem(-1);
                }

                if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.RIGHT)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeItem(1);
                }

                if (FlxG.keys.justPressed.TAB)
                {
                    KeyBinds.gamepad = !KeyBinds.gamepad;
                    textUpdate();
                }

                if (FlxG.keys.justPressed.ENTER)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu1'));
                    state = "input";
                }
                else if(FlxG.keys.justPressed.ESCAPE){
                    quit();
                }
                else if (FlxG.keys.justPressed.BACKSPACE)
                {
                    reset();
                }
                if (gamepad != null) // GP Logic
                {
                    if (gamepad.justPressed.DPAD_UP)
                    {
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeItem(-1);
                        textUpdate();
                    }
                    if (gamepad.justPressed.DPAD_DOWN)
                    {
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeItem(1);
                        textUpdate();
                    }

                    if (gamepad.justPressed.START && frames > 10)
                    {
                        FlxG.sound.play(Paths.sound('scrollMenu1'));
                        state = "input";
                    }
                    else if(gamepad.justPressed.LEFT_TRIGGER){
                        quit();
                    }
                    else if (gamepad.justPressed.RIGHT_TRIGGER){
                        reset();
                    }
                }

            case "input":
                tempKey = keys[curSelected];
                keys[curSelected] = "?";
                if (KeyBinds.gamepad)
                    gpKeys[curSelected] = "?";
                textUpdate();
                state = "waiting";

            case "waiting":
                if (gamepad != null && KeyBinds.gamepad) // GP Logic
                {
                    if(FlxG.keys.justPressed.ESCAPE){ // just in case you get stuck
                        gpKeys[curSelected] = tempKey;
                        state = "select";
                        FlxG.sound.play(Paths.sound('cancelMenu'));
                    }

                    if (gamepad.justPressed.START)
                    {
                        addKeyGamepad(defaultKeys[curSelected]);
                        save();
                        state = "select";
                    }

                    if (gamepad.justPressed.ANY)
                    {
                        trace(gamepad.firstJustPressedID());
                        addKeyGamepad(gamepad.firstJustPressedID());
                        save();
                        state = "select";
                        textUpdate();
                    }

                }
                else
                {
                    if(FlxG.keys.justPressed.ESCAPE){
                        keys[curSelected] = tempKey;
                        state = "select";
                        FlxG.sound.play(Paths.sound('cancelMenu'));
                    }
                    else if(FlxG.keys.justPressed.ENTER){
                        addKey(defaultKeys[curSelected]);
                        save();
                        state = "select";
                    }
                    else if(FlxG.keys.justPressed.ANY){
                        addKey(FlxG.keys.getIsDown()[0].ID.toString());
                        save();
                        state = "select";
                    }
                }


            case "exiting":

            default:
                state = "select";

        }

        if(FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
		
	}

    function textUpdate(){

        keyTextDisplay.text = "\n\n";

        if (KeyBinds.gamepad)
        {
            for(i in 0...4){

                var textStart = (i == curSelected) ? "> " : "  ";
                trace(gpKeys[i]);
                keyTextDisplay.text += textStart + keyText[i] + ": " + gpKeys[i] + "\n";
                
            }
        }
        else
        {
            for(i in 0...4){

                var textStart = (i == curSelected) ? "> " : "  ";
                keyTextDisplay.text += textStart + keyText[i] + ": " + ((keys[i] != keyText[i]) ? (keys[i] + " / ") : "" ) + keyText[i] + " ARROW\n";

            }
        }

        keyTextDisplay.updateHitbox();
        keyTextDisplay.screenCenter();
        keyTextDisplay.x += 350;
        keyTextDisplay.y -= 20;
    }

    function save(){

        FlxG.save.data.upBind = keys[2];
        FlxG.save.data.downBind = keys[1];
        FlxG.save.data.leftBind = keys[0];
        FlxG.save.data.rightBind = keys[3];
        
        FlxG.save.data.gpupBind = gpKeys[2];
        FlxG.save.data.gpdownBind = gpKeys[1];
        FlxG.save.data.gpleftBind = gpKeys[0];
        FlxG.save.data.gprightBind = gpKeys[3];

        FlxG.save.flush();

        PlayerSettings.player1.controls.loadKeyBinds();

    }

    function reset()
    {
        FlxG.sound.play(Paths.sound('returnMenu'));
        for(i in 0...5)
        {
            keys[i] = defaultKeys[i];
        }
        if (keyTextTween != null)
            keyTextTween.cancel();
        keyTextTween = FlxTween.color(keyTextDisplay, Conductor.crochet * 2 / 1000, FlxColor.RED, FlxColor.WHITE, {type: ONESHOT, ease: FlxEase.smootherStepOut,
        onComplete:
            function(twn:FlxTween)
            {
                keyTextTween = null;
            }
        });
    }

    function quit()
    {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        state = "exiting";
        remove(wipTxt);

        save();

        OptionsMenu.instance.acceptInput = true;

        if (keyTextTween != null)
            keyTextTween.cancel();
        for (i in allTweensGroup)
        {
            if (i != null)
                i.cancel();
        }

        FlxTween.tween(arrowGroup, {alpha: 0}, 0.75, {ease: FlxEase.expoOut});
        FlxTween.tween(keyTextDisplay, {alpha: 0}, 0.75, {ease: FlxEase.expoOut});
        FlxTween.tween(blackBox, {alpha: 0}, 0.8, {ease: FlxEase.expoOut, onComplete: function(flx:FlxTween){close();}});
        FlxTween.tween(infoText, {alpha: 0}, 0.75, {ease: FlxEase.expoOut});
    }


    function addKeyGamepad(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = ["START"];

        for(x in 0...gpKeys.length)
            {
                var oK = gpKeys[x];
                if(oK == r)
                    gpKeys[x] = null;
                if (notAllowed.contains(oK))
                {
                    gpKeys[x] = null;
                    lastKey = r;
                    return;
                }
            }

        if(shouldReturn){
            gpKeys[curSelected] = r;
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        else{
            gpKeys[curSelected] = tempKey;
            lastKey = r;
        }

	}

    public var lastKey:String = "";

	function addKey(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = [];

        for(x in blacklist){notAllowed.push(x);}

        trace(notAllowed);

        for(x in 0...keys.length)
            {
                var oK = keys[x];
                if(oK == r)
                    keys[x] = null;
                if (notAllowed.contains(oK))
                {
                    keys[x] = null;
                    lastKey = oK;
                    return;
                }
            }

        if (r.contains("NUMPAD"))
        {
            keys[curSelected] = null;
            lastKey = r;
            return;
        }

        lastKey = "";

        if(shouldReturn){
            keys[curSelected] = r;
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        else{
            keys[curSelected] = tempKey;
            lastKey = r;
        }

	}

    function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;
                
        if (curSelected > 3)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 3;

        for (i in arrowGroup)
        {
            if (curSelected == i.ID)
            {
                i.alpha = 1;
                i.animation.play('select');
            }
            else
            {
                i.alpha = 0.5;
                i.animation.play('static');
            }
        }
    }
}
