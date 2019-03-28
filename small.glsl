precision mediump float;
uniform float iTime,iAspect;
varying lowp vec4 fragCoord;
uniform vec2 iResolution;
uniform vec4 iMouse;

void main() {
  //get coords and direction
  vec2 uv=gl_FragCoord.xy/iResolution.xy-.5;
  uv.y*=iAspect;
  vec3 dir=vec3(uv,1.);
  float time=iTime;

  //mouse rotation
  float a1=.5+iMouse.x/iResolution.x*2.;
  float a2=.8+iMouse.y/iResolution.y*2.;
  mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
  mat2 rot2=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
  dir.xz*=rot1;
  dir.xy*=rot2;
  vec3 from=vec3(1.,.5,0.5);
  from+=vec3(time*2.,time,-2.);
  from.xz*=rot1;
  from.xy*=rot2;
  
  //volumetric rendering
  float s=0.1,fade=1.;
  vec3 v=vec3(0.);

  // for (int r=0; r<volsteps; r++) {
  // #define volsteps 20
  for (int r=0; r<20; r++) {
    vec3 p=from+s*dir*.5;
    p = abs(vec3(1.)-mod(p,vec3(2.))); // tiling fold
    float pa,a=pa=0.;
    // for (int i=0; i<iterations; i++) { 
    // #define iterations 17
    for (int r=0; r<20; r++) { 
      p=abs(p)/dot(p,p)-0.53; // the magic formula #define formuparam 0.53
      a+=abs(length(p)-pa); // absolute sum of average change
      pa=length(p);
    }
    // #define darkmatter 0.300
    float dm=max(0.,.3-a*a*.001); //dark matter
    
    if (r>6) fade*=1.-dm; // dark matter, don't render near
    //v+=vec3(dm,dm*.5,0.);
    v+=fade;
    a*=a*a; // add contrast
    // v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade;
    // #define brightness 0.0015

    v+=vec3(s,s*s,s*s*s*s)*a*.0015*fade; // coloring based on distance
    fade*=.73; // distance fading #define distfading 0.730
    s+=0.1; // #define stepsize 0.1
  }
  // #define saturation 0.850
  v=mix(vec3(length(v)),v,.85); //color adjust
  gl_FragColor = vec4(v*.01,1.); 
}