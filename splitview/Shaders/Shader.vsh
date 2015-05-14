//
//  Shader.vsh
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

attribute vec4 position;
attribute vec2 texCoord;

varying lowp vec2 vTexCoord;

uniform mat4 modelViewProjectionMatrix;

void main()
{
    // pass to fragment shader
    vTexCoord = texCoord;
    
    gl_Position = modelViewProjectionMatrix * position;
}
