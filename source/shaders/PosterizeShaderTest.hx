package shaders;
//This is from openFL8 - I just modified the package for custom sizes

import flixel.system.FlxAssets.FlxShader;

/**
 * A classic mosaic effect, just like in the old days!
 *
 * Usage notes:
 * - The effect will be applied to the whole screen.
 * - Set the x/y-values on the 'uBlocksize' vector to the desired size (setting this to 0 will make the screen go black)
 */
class PosterizeShaderTest extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float levels = 2;

		void main() 
		{
			vec4 guh = flixel_texture2D(bitmap, openfl_TextureCoordv);
			
			float greyscale = max(guh.r, max(guh.g, guh.b));

			float lower     = floor(greyscale * levels) / levels;
			float lowerDiff = abs(greyscale - lower);

			float upper     = ceil(greyscale * levels) / levels;
			float upperDiff = abs(upper - greyscale);

			float level      = lowerDiff <= upperDiff ? lower : upper;
			float adjustment = level / greyscale;

			guh.r * adjustment;
			guh.g * adjustment;
			guh.b * adjustment;

			gl_FragColor = guh;
		}')
	public function new()
	{
		super();
	}
}
