precision mediump float;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform float time;
varying lowp vec2 vTexCoord;


void main()
{
    float sourceAlpha = texture2D(texture1, vTexCoord).a;
    
    if(sourceAlpha<0.99){
        float scale = clamp( sin(abs(time*time)), 0.33, 1.0 );
        gl_FragColor = (texture2D(texture1, vTexCoord) * 2.0 * scale) + (texture2D(texture2, vTexCoord) );
    }
    else{
        gl_FragColor = texture2D(texture2,vTexCoord);
    }

    /*float Depth = texture2D(texture1, vTexCoord).x;
    Depth = 1.0 - (1.0 - Depth) * 25.0;
    gl_FragColor = vec4(Depth);
    */
}