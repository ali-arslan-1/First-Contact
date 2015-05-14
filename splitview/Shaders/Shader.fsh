//
//  Shader.fsh
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

uniform sampler2D uSampler;
uniform int       isGrid;

varying lowp vec2 vTexCoord;

void main()
{
    lowp vec4 texCol = texture2D(uSampler, vTexCoord);
    
    if (isGrid == 1)
        gl_FragData[0] = vec4(0.0, 1.0, 0.0, 1.0);
    else
        gl_FragData[0] = vec4(texCol.rgba);
}
