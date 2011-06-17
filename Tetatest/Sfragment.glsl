//varying lowp vec4 DestinationColor; // 1

varying mediump vec2 v_texCoord; 
varying mediump vec2 virt_coord;
varying mediump float etype;
varying mediump vec4 ecolor1;
varying mediump vec4 ecolor2;
varying mediump vec4 ecolor3;
varying mediump vec4 ecolor4;
varying mediump vec2 eparams;
uniform sampler2D s_texture; 
void main(void) { // 2
const mediump vec4 color=vec4(0.,0.,0.,1.0);
// mix(texture2D (s_texture, v_texCoord),color,0.5)
if(etype==0.0)
{
gl_FragColor =texture2D (s_texture, v_texCoord); // 3 DestinationColor+
}
else
 if(etype==1.0)
{
 mediump vec4 tclr=mix(mix(ecolor1,ecolor2,virt_coord.y),mix(ecolor3,ecolor4,virt_coord.y),virt_coord.x);
gl_FragColor =mix(texture2D (s_texture, v_texCoord),tclr,eparams.x); 
 }
  else
{
gl_FragColor =texture2D (s_texture, v_texCoord);
}

}