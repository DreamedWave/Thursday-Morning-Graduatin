package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var sprTrackerWidth:Float = 0;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	private var prevChar:String = '';

	public var isShowingAlive:Bool = true;
	public var curAnimName:String = 'normal_stillFrame';

	public function new(char:String = 'guy-default', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		var iconName:String = PlayStateHelpers.getIconID(char);
		changeIcon(iconName, false);
		scrollFactor.set();
	}

	//does the job done ADGKSDBKSKB
	public function set_sprTracker(tracker:FlxSprite):Void
	{
		sprTracker = tracker;
		sprTrackerWidth = tracker.width;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTrackerWidth + 10, sprTracker.y - 50);
	}

	public function swapOldIcon() 
	{
		isOldIcon = !isOldIcon;
		
		if(isOldIcon) 
			changeIcon('bf-old');
		else 
		{
			trace (prevChar);
			changeIcon(prevChar);
		}
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, swapIcon:Bool = true) 
	{
		if(this.char != char) 
		{
			if (char == '' || char == null)
				return;

			var swapToFrame:Int = 0;
			if (swapIcon)
			{
				if (animation.curAnim.name.endsWith('_normal') || (animation.curAnim.name == this.char && animation.curAnim.curFrame == 0))
					swapToFrame = 0;
				else if (animation.curAnim.name.endsWith('_lowHP') || (animation.curAnim.name == this.char && animation.curAnim.curFrame == 1))
					swapToFrame = 1;
			}

			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) 
				name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) 
				name = 'icons/bf-old'; //Prevents crash from missing icon

			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file's size
			var div:Array<Int> = [0, 0]; //Then determine how many frames are in the file
			div[0] = Math.round(width / 150);
			div[1] = Math.round(height / 150);
			loadGraphic(file, true, Math.floor(width / div[0]), Math.floor(height / div[1])); //Then load it fr
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
			updateHitbox();

			switch (char)
			{
				case 'holy-cross':
					//animation.add(char + '_normal', [0, 0, 0, 0], 12, false, isPlayer);
					//animation.add(char + '_lowHP', [0, 1, 2, 3], 12, false, isPlayer);
					animation.add(char, [0, 0], 0, false, isPlayer);
				default:
					animation.add(char + '_normal', [0, 1, 2, 3], 12, false, isPlayer);
					animation.add(char + '_lowHP', [4, 5, 6, 7], 12, false, isPlayer);
					animation.add(char, [3, 7], 0, false, isPlayer);
			}
			animation.play(char);
			if (swapIcon)
				animation.curAnim.curFrame = swapToFrame;

			if (this.char != 'bf-old' && prevChar != this.char && this.char != null)
				prevChar = this.char;
			this.char = char;

			if(!char.endsWith('-pixel'))
				antialiasing = FlxG.save.data.antialiasing;
		}
	}

	public function playAnimation(animName:String = '', inFreeplay:Bool = false):Void
	{
		if ((!FlxG.save.data.distractions && !animName.endsWith('_stillFrame')) || char == 'holy-cross')
		{
			trace('replaced');
			animName = animName + '_stillFrame';
		}

		if ((inFreeplay || (animation.curAnim.curFrame >= 3 || animation.curAnim.name == char)) && !animName.endsWith('_stillFrame'))
		{
			switch(animName)
			{
				case 'normal':
					isShowingAlive = true;
					animation.play(char + '_normal');
					trace('normie');
				case 'lowHP':
					isShowingAlive = false;
					animation.play(char + '_lowHP');
					trace('ded');
				default:
					trace('animation not specified and/or invalid');
					return;
			}
			curAnimName = animName;
		}
		else if (animName.endsWith('_stillFrame'))
		{
			switch(animName)
			{
				case 'normal_stillFrame':
					isShowingAlive = true;
					animation.play(char);
					animation.curAnim.curFrame = 0;
					trace('normie_still');
				case 'lowHP_stillFrame':
					isShowingAlive = false;
					animation.play(char);
					animation.curAnim.curFrame = 1;
					trace('dead_still');
				default:
					trace('animation not specified and/or invalid');
					return;
			}
			curAnimName = animName;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
