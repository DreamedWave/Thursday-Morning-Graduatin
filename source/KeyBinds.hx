//import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{
    public static var gamepad:Bool = false;

    public static function resetBinds():Void{

        FlxG.save.data.leftBind = "D";
        FlxG.save.data.downBind = "F";
        FlxG.save.data.upBind = "J";
        FlxG.save.data.rightBind = "K";
        FlxG.save.data.killBind = "R";
        FlxG.save.data.styleBind = "SHIFT";
        FlxG.save.data.gpupBind = "DPAD_UP";
        FlxG.save.data.gpdownBind = "DPAD_DOWN";
        FlxG.save.data.gpleftBind = "DPAD_LEFT";
        FlxG.save.data.gprightBind = "DPAD_RIGHT";
        PlayerSettings.player1.controls.loadKeyBinds();
        keyCheck();
	}

    public static function keyCheck():Void
    {
        if(FlxG.save.data.upBind == null || StringTools.contains(FlxG.save.data.upBind,"NUMPAD"))
            FlxG.save.data.upBind = "W";
        if(FlxG.save.data.downBind == null || StringTools.contains(FlxG.save.data.downBind,"NUMPAD"))
            FlxG.save.data.downBind = "S";
        if(FlxG.save.data.leftBind == null || StringTools.contains(FlxG.save.data.leftBind,"NUMPAD"))
            FlxG.save.data.leftBind = "A";
        if(FlxG.save.data.rightBind == null || StringTools.contains(FlxG.save.data.rightBind,"NUMPAD"))
            FlxG.save.data.rightBind = "D";
        
        if(FlxG.save.data.gpupBind == null)
            FlxG.save.data.gpupBind = "DPAD_UP";
        if(FlxG.save.data.gpdownBind == null)
            FlxG.save.data.gpdownBind = "DPAD_DOWN";
        if(FlxG.save.data.gpleftBind == null)
            FlxG.save.data.gpleftBind = "DPAD_LEFT";
        if(FlxG.save.data.gprightBind == null)
            FlxG.save.data.gprightBind = "DPAD_RIGHT";

    	if(FlxG.save.data.killBind == null)
            FlxG.save.data.killBind = "R";
        if(FlxG.save.data.styleBind == null)
            FlxG.save.data.styleBind = "SHIFT";
        
        //trace('StyleBind = ' + FlxG.save.data.styleBind);
        //trace('${FlxG.save.data.leftBind}-${FlxG.save.data.downBind}-${FlxG.save.data.upBind}-${FlxG.save.data.rightBind}');
    }
}
