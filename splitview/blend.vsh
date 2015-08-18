attribute vec4 position;
attribute vec2 texCoord;

varying lowp vec2 vTexCoord;


void main()
{
    vTexCoord = texCoord;
    gl_Position = position;
}
