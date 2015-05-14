//
//  post.fsh
//
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//
precision mediump float;
uniform sampler2D uSamplerL;
uniform sampler2D uSamplerR;

varying lowp vec2 vTexCoord;

void main()
{
    lowp vec4 texCol;
    float x = vTexCoord.x;
    float y = vTexCoord.y;
    
    if (vTexCoord.x < 0.5)
    {
        float u = x * 2.0;
        float v = y;
        texCol = texture2D(uSamplerL, vec2(u, v));
    }
    else if (vTexCoord.x > 0.5)
    {
        float u = (x - 0.5) * 2.0;
        float v = y;
        texCol = texture2D(uSamplerR, vec2(u, v));
    }
    gl_FragColor = vec4(texCol.rgba);
}
