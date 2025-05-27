#ifdef GL_ES
precision mediump float;
#endif

void main() 
{
    float levels = 10;

    gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    
    float greyscale = max(gl_FragColor.r, max(gl_FragColor.g, gl_FragColor.b));

    float lower     = floor(greyscale * levels) / levels;
    float lowerDiff = abs(greyscale - lower);

    float upper     = ceil(greyscale * levels) / levels;
    float upperDiff = abs(upper - greyscale);

    float level      = lowerDiff <= upperDiff ? lower : upper;
    float adjustment = level / greyscale;

    gl_FragColor.rgb * adjustment;
}