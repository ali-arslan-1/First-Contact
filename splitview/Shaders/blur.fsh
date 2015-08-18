
precision mediump float;
uniform sampler2D	tex0;
uniform mediump vec2		sample_offset;
uniform float		attenuation;
varying lowp vec2 vTexCoord;

void main()
{
    lowp vec4 texCol = texture2D(tex0, vTexCoord);
    
    if (texCol.a < 0.99) {
     
    
        lowp vec3 sum = vec3( 0.0, 0.0, 0.0 );
        sum += texture2D( tex0, vTexCoord.st + -10.0 * sample_offset ).rgb * 0.009167927656011385;
        sum += texture2D( tex0, vTexCoord.st +  -9.0 * sample_offset ).rgb * 0.014053461291849008;
        sum += texture2D( tex0, vTexCoord.st +  -8.0 * sample_offset ).rgb * 0.020595286319257878;
        sum += texture2D( tex0, vTexCoord.st +  -7.0 * sample_offset ).rgb * 0.028855245532226279;
        sum += texture2D( tex0, vTexCoord.st +  -6.0 * sample_offset ).rgb * 0.038650411513543079;
        sum += texture2D( tex0, vTexCoord.st +  -5.0 * sample_offset ).rgb * 0.049494378859311142;
        sum += texture2D( tex0, vTexCoord.st +  -4.0 * sample_offset ).rgb * 0.060594058578763078;
        sum += texture2D( tex0, vTexCoord.st +  -3.0 * sample_offset ).rgb * 0.070921288047096992;
        sum += texture2D( tex0, vTexCoord.st +  -2.0 * sample_offset ).rgb * 0.079358891804948081;
        sum += texture2D( tex0, vTexCoord.st +  -1.0 * sample_offset ).rgb * 0.084895951965930902;
        sum += texture2D( tex0, vTexCoord.st +   0.0 * sample_offset ).rgb * 0.086826196862124602;
        sum += texture2D( tex0, vTexCoord.st +  +1.0 * sample_offset ).rgb * 0.084895951965930902;
        sum += texture2D( tex0, vTexCoord.st +  +2.0 * sample_offset ).rgb * 0.079358891804948081;
        sum += texture2D( tex0, vTexCoord.st +  +3.0 * sample_offset ).rgb * 0.070921288047096992;
        sum += texture2D( tex0, vTexCoord.st +  +4.0 * sample_offset ).rgb * 0.060594058578763078;
        sum += texture2D( tex0, vTexCoord.st +  +5.0 * sample_offset ).rgb * 0.049494378859311142;
        sum += texture2D( tex0, vTexCoord.st +  +6.0 * sample_offset ).rgb * 0.038650411513543079;
        sum += texture2D( tex0, vTexCoord.st +  +7.0 * sample_offset ).rgb * 0.028855245532226279;
        sum += texture2D( tex0, vTexCoord.st +  +8.0 * sample_offset ).rgb * 0.020595286319257878;
        sum += texture2D( tex0, vTexCoord.st +  +9.0 * sample_offset ).rgb * 0.014053461291849008;
        sum += texture2D( tex0, vTexCoord.st + +10.0 * sample_offset ).rgb * 0.009167927656011385;
        

        gl_FragColor.rgb = attenuation * sum;  
        gl_FragColor.a = texCol.a;
        
    }else{
        
        gl_FragColor =  texture2D(tex0, vTexCoord);
        gl_FragColor.a = texCol.a;
    }
}