//This is NOT from indie cross
package shaders;
import flixel.system.FlxAssets.FlxShader;

class GrayScale extends FlxShader
{
	// fragment shader
	//
	// RGBA color to RGBA greyscale
	//
	// smooth transition based on u_colorFactor: 0.0 = original, 1.0 = greyscale
	//
	// http://www.johndcook.com/blog/2009/08/24/algorithms-convert-color-grayscale/
	// "The luminosity method is a more sophisticated version of the average method.
	// It also averages the values, but it forms a weighted average to account for human perception.
	// We’re more sensitive to green than other colors, so green is weighted most heavily. The formula
	// for luminosity is 0.21 R + 0.72 G + 0.07 B."

	//A modified version by av01d

	@:glFragmentSource('
		#pragma header

		uniform float u_colorFactor = 0.75;

		void main() 
		{
			vec4 sample = flixel_texture2D(bitmap, openfl_TextureCoordv);
			float gray = 0.21 * sample.r + 0.71 * sample.g + 0.07 * sample.b;
			sample.r = sample.r * (1.0 - u_colorFactor) + (gray * u_colorFactor);
			sample.b = sample.b * (1.0 - u_colorFactor) + ((gray * 1.15) * u_colorFactor);
			sample.g = sample.g * (1.0 - u_colorFactor) + ((gray * 1.25) * u_colorFactor);
			sample.rbg = sample.rgb * 0.55;
			
			gl_FragColor = sample;
		}')
	
	public function new()
	{
		super();
	}
}