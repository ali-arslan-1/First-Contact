
attribute vec4 position;

uniform mat4 lightModelViewProjectionMatrix;


void main()
{
    gl_Position = lightModelViewProjectionMatrix * position;
}
