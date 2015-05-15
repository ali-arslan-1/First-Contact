
//
//  Shader.vsh
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

attribute vec4 position;
attribute vec2 texCoord;
attribute vec3 normal;

varying lowp vec2 vTexCoord;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewInvTransMatrix;

varying vec4 vPosition;
varying vec3 vNormal;


void main()
{
    // pass to fragment shader
    vTexCoord = texCoord;
    
    vPosition = modelViewProjectionMatrix * position;
    vNormal = vec3(modelViewInvTransMatrix * vec4(normal, 0.0));
    
    gl_Position = modelViewProjectionMatrix * position;
}
