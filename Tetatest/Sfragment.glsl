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
const mediump vec4 color=vec4(0.,0.,0.,0.0);
// mix(texture2D (s_texture, v_texCoord),color,0.5)

if(abs(etype)<0.01)
{
gl_FragColor =texture2D (s_texture, v_texCoord); // 3 DestinationColor+
}
else
 if(abs(etype-1.0)<0.01)
{
 mediump vec4 tclr=mix(mix(ecolor1,ecolor2,virt_coord.y),mix(ecolor3,ecolor4,virt_coord.y),virt_coord.x);
gl_FragColor =mix(texture2D (s_texture, v_texCoord),tclr,eparams.x); 
 }
  else
 if(abs(etype-2.0)<0.01)
{
lowp float alx=1.0,aly=1.0;
if(virt_coord.x<ecolor1.x)
 {alx=ecolor2.x;}
else
 if (virt_coord.x>ecolor1.y)
{alx=ecolor2.y;}
 else
  {alx=ecolor2.x+(virt_coord.x-ecolor1.x)*eparams.x;}
if(virt_coord.y<ecolor1.z)
{aly=ecolor2.z;}
else
if (virt_coord.y>ecolor1.w)
{aly=ecolor2.w;}
else
{aly=ecolor2.z+(virt_coord.y-ecolor1.z)*eparams.y;}
mediump vec4 tclr=texture2D(s_texture, v_texCoord);
tclr.w=tclr.w*alx*aly;
gl_FragColor=tclr;
}
else

{
gl_FragColor =texture2D (s_texture, v_texCoord);
}

}