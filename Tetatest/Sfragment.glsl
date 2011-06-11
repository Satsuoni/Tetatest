//varying lowp vec4 DestinationColor; // 1
varying mediump vec2 v_texCoord; 
uniform sampler2D s_texture; 
void main(void) { // 2
//const mediump vec4 color=vec4(1.,0.,0.,1.0);
// mix(texture2D (s_texture, v_texCoord),color,0.5)
gl_FragColor =texture2D (s_texture, v_texCoord); // 3 DestinationColor+
}