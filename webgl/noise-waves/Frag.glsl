precision highp float;

// our uniforms, from javascript
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_sampler;

// our varying, from the vert
varying vec2 v_texcoord;

// 2D Random
float bosRandom(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float bosNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = bosRandom(i);
    float b = bosRandom(i + vec2(1.0, 0.0));
    float c = bosRandom(i + vec2(0.0, 1.0));
    float d = bosRandom(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

//
// Stuff for crumpled paper
// from https://www.shadertoy.com/view/ltsSDf

float hash(float n) {
    n=mod(n,64.0);
    return fract(sin(n)*43758.5453);
}

float noise(vec2 p) {
    return hash(p.x + p.y*57.0);
}

float smoothNoise2(vec2 p) {
    vec2 p0 = floor(p + vec2(0.0, 0.0));
    vec2 p1 = floor(p + vec2(1.0, 0.0));
    vec2 p2 = floor(p + vec2(0.0, 1.0));
    vec2 p3 = floor(p + vec2(1.0, 1.0));
    vec2 pf = fract(p);
    return mix( mix(noise(p0), noise(p1), pf.x), 
               mix(noise(p2), noise(p3), pf.x), pf.y);
}

vec2 cellPoint(vec2 cell) {
    return vec2(noise(cell)+cos(cell.y)*0.3, noise(cell*0.3)+sin(cell.x)*0.3);
}

vec3 voronoi2(vec2 t,float pw) {
    vec2 p = floor(t);
    vec3 nn=vec3(1e10);

    float wsum=0.0;
    vec3 cl=vec3(0.0);
    for(int y = -1; y < 2; y += 1)
        for(int x = -1; x < 2; x += 1)
        {
            vec2 b = vec2(float(x), float(y));
            vec2 q = b + p;
            vec2 q2 = q-floor(q/8.0)*8.0;
            vec2 c = q + cellPoint(q2);
            vec2 r = c - t;
            vec2 r2=r;

            float d = dot(r, r);
            float w=pow(smoothstep(0.0,1.0,1.0-abs(r2.x)),pw)*pow(smoothstep(0.0,1.0,1.0-abs(r2.y)),pw);

            cl+=vec3(0.5+0.5*cos((q2.x+q2.y*119.0)*8.0))*w;
            wsum+=w;

            nn=mix(vec3(q2,d),nn,step(nn.z,d));
        }

    return pow(cl/wsum,vec3(0.5))*2.0;
}

vec3 voronoi(vec2 t) {
    return voronoi2(t*0.25,16.0)*(0.0+1.0*voronoi2(t*0.5+vec2(voronoi2(t*0.25,16.0)),2.0))+voronoi2(t*0.5,4.0)*0.5;
}

void main() {
    vec2 uv = v_texcoord;
    // noise texture
    vec4 noiseTexture = texture2D(u_sampler, v_texcoord + vec2(u_time * 0.1)) * 2.;
    noiseTexture -= 0.5;
    uv += noiseTexture.ba * 0.005;

    vec2 t = uv;
    gl_FragColor.a = 1.0;

    vec2 tt = fract((t + 1.0) * 0.5) * 64.0;

    tt.y += distance(vec2(u_time/10.0), tt);

    float x=voronoi(tt).r;
    float x1=voronoi(tt+vec2(0.01,0.0)).r;
    float x2=voronoi(tt+vec2(0.0,0.01)).r;

    vec3 color = 0.64 * mix(
        vec3(0.1,0.1,0.9) * 0.4,
        vec3(1.05,1.05,1.0),
        0.5 + 0.5 * dot(
            normalize(
                vec3(0.1,1.0,0.5))
            ,normalize(
                vec3((x1 - x)/0.01, (x2-x)/0.01,8.0))
            * 0.5 + vec3(0.5)));
    gl_FragColor.rgb = color;

}
