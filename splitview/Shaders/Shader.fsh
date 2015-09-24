//
//  Shader.fsh
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

precision mediump float;

varying mediump vec4 vPosition;
varying mediump vec4 lightSpacePos;

varying mediump vec3 vNormal;

uniform sampler2D uSampler;
uniform sampler2D shadowMap;
uniform int       isGrid;

varying mediump vec2 vTexCoord;

uniform vec3 PodRoom_01 ;
vec3 uLightColor = vec3(1.0, 1.0, 1.2);

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
    
    
    
    vec3 pl = normalize(PodRoom_01 - vec3(vPosition));
    float cosAngle = max(dot(pl, normalize(vNormal)), 0.0);
    
    return vec3((uLightColor * vec3(texCol)) * cosAngle);
}

vec3 specular() {
    
    vec3 bisector = normalize(normalize(-vec3(vPosition)) + normalize((PodRoom_01 - vec3(vPosition))));
    
    float cosAngle = max(dot(bisector, normalize(vNormal)), 0.0);
    
    return uLightColor * uSpecularMaterial * pow(cosAngle, uSpecularityExponent);
}

float CalcShadowFactor(vec4 LightSpacePos)
{
    vec3 ProjCoords = LightSpacePos.xyz / LightSpacePos.w;
    vec2 UVCoords;
    UVCoords.x = 0.5 * ProjCoords.x + 0.5;
    UVCoords.y = 0.5 * ProjCoords.y + 0.5;
    float z = 0.5 * ProjCoords.z + 0.5;
    float Depth = texture2D(shadowMap, UVCoords).x;
    if(z < 0.0 || z >1.0)
        return 1.0;
    else if(Depth < (z - 0.01))
        return 0.5;
    else
        return 1.0;
}

void main()
{
    lowp vec4 texCol = texture2D(uSampler, vTexCoord);
    
    if (isGrid == 1)
        gl_FragData[0] = vec4(0.0, 1.0, 0.0, 1.0);
    else if(texCol.a < 0.99){
        

        gl_FragData[0] = texCol;
        
    }
    else{
        
        float shadowFactor = CalcShadowFactor(lightSpacePos);
        gl_FragData[0] = vec4(ambient() + (shadowFactor * diffuse()) + (shadowFactor * specular()),1.0);
        
        //if(shadowFactor<0.5){
          //  gl_FragData[0] = vec4(1,0,0,0);
        //}
        
        //gl_FragData[0].a = 0.0;
    }
}
