package shaders;
import flixel.system.FlxAssets.FlxShader;

class TestShader extends FlxShader {
    @:glFragmentSource('#pragma header

    void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        gl_FragColor = vec4(1.0 * color.a, 0.5098 * color.a, 0.6902 * color.a, color.a); //rgba
    }')

    public function new()
    {super();}
}