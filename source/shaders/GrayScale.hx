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

	//by av01d and Volcanoscar
	//https://gist.github.com/Volcanoscar/4a9500d240497d3c0228f663593d167a

	@:glFragmentSource('
		#pragma header

		uniform float u_colorFactor = 0.5;

		void main() 
		{
			vec4 sample = flixel_texture2D(bitmap, openfl_TextureCoordv);
			float grey = 0.21 * sample.r + 0.71 * sample.g + 0.07 * sample.b;
			gl_FragColor = vec4(sample.r * u_colorFactor + grey * (1.0 - u_colorFactor), sample.g * u_colorFactor + grey * (1.0 - u_colorFactor), sample.b * u_colorFactor + grey * (1.0 - u_colorFactor), 1.0);
		}')
	
	public function new()
	{
		super();
	}
}