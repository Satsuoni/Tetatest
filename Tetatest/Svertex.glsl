attribute vec4 Position; // 1
attribute vec2 TexPos;
attribute vec2 VirtPos;
attribute vec4 ef_color1;
attribute vec4 ef_color2;
attribute vec4 ef_color3;
attribute vec4 ef_color4;
attribute vec2 ef_params;
attribute float effect_type;

varying vec2 v_texCoord; 
varying vec2 virt_coord;
varying float etype;
varying vec4 ecolor1;
varying vec4 ecolor2;
varying vec4 ecolor3;
varying vec4 ecolor4;
varying vec2 eparams;
uniform mat4 Projection;
uniform mat4 Modelview;

void main(void) { // 4
//DestinationColor = SourceColor; // 5
gl_Position = Projection * Modelview * Position;
v_texCoord = TexPos;
virt_coord = VirtPos;
etype=effect_type;
ecolor1=ef_color1;
ecolor2=ef_color2;
ecolor3=ef_color3;
ecolor4=ef_color4;
eparams=ef_params;
}