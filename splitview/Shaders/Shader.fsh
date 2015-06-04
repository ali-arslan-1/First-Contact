//
//  Shader.fsh
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

precision mediump float;

varying mediump vec4 vPosition;
varying mediump vec3 vNormal;

uniform sampler2D uSampler;
uniform int       isGrid;

varying mediump vec2 vTexCoord;

uniform vec3 uLightPosition ;
vec3 uLightColor = vec3(1.0, 1.0, 1.0);

mat3 uAmbientMaterial = mat3(
                             4.0, 0.0, 0.0,
                             0.0, 4.0, 0.0,
                             0.0, 0.0, 4.0
                             );

mat3 uSpecularMaterial = mat3(
                              0.15, 0.0, 0.0,
                              0.0, 0.15, 0.0,
                              0.0, 0.0, 0.15
                              );
float uSpecularityExponent = 60.0;


vec3 ambient() {
    
    return uLightColor * vec3(0.05) * uAmbientMaterial;
}

vec3 diffuse() {
    
    lowp vec4 texCol = texture2D(uSampler, vTexCoord);
    
    vec3 pl = normalize(uLightPosition - vec3(vPosition));
    float cosAngle = max(dot(pl, normalize(vNormal)), 0.0);
    
    return vec3((uLightColor * vec3(texCol)) * cosAngle);
}

vec3 specular() {
    
    vec3 bisector = normalize(normalize(-vec3(vPosition)) + normalize((uLightPosition - vec3(vPosition))));
    
    float cosAngle = max(dot(bisector, normalize(vNormal)), 0.0);
    
    return uLightColor * uSpecularMaterial * pow(cosAngle, uSpecularityExponent);
}

void main()
{
    if (isGrid == 1)
        gl_FragData[0] = vec4(0.0, 1.0, 0.0, 1.0);
    else
        gl_FragData[0] = vec4(ambient() + diffuse() + specular(),1.0);;
}
