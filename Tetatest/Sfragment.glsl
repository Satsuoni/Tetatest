//varying lowp vec4 DestinationColor; // 1
varying mediump vec2 v_texCoord; 
uniform sampler2D s_texture; 
void main(void) { // 2
gl_FragColor = texture2D (s_texture, v_texCoord); // 3 DestinationColor+
}