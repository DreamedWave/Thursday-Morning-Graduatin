package shaders;

import shaders.PosterizeShaderTest;

//This shit is from flixel demos LMAO
class PosterizeEffectTest
{
	/**
	 * The effect's "start-value" on the x/y-axes (the effect is not visible with this value).
	 */
	public static inline var DEFAULT_LEVEL:Float = 2;
	public var levels(default, null):Float = DEFAULT_LEVEL;

	/**
	 * The instance of the actual shader class
	 */
	public var shader(default, null):PosterizeShaderTest;

	public function new():Void
	{
		shader = new PosterizeShaderTest();
		#if (openfl >= "8.0.0")
		shader.data.levels.value = levels;
		#else
		shader.levels = levels;
		#end
	}

	public function setLevels(newLevel:Float = 16):Void
	{
		levels = newLevel;
		#if (openfl >= "8.0.0")
		shader.data.levels.value = levels;
		#else
		shader.levels = levels;
		#end
	}
}
