precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_sampler;

varying vec2 v_texcoord;

float normalSinTime(float amp, float period) {
    return (sin(u_time/period) * 0.5 + 0.5) * amp;
}

float normalCosTime(float amp, float period) {
    return (cos(u_time/period) * 0.5 + 0.5) * amp;
}

void main() {
    
    vec4 noise = texture2D(u_sampler, v_texcoord + vec2(u_time * 0.1)) * 2.;
    vec4 color = vec4(1.0);
    vec2 uv = v_texcoord;
    
    noise -= 0.5;
    uv += noise.ba * 0.02;
    
    float d = distance(normalSinTime(2., 2.), (uv.x * 0.5 + 0.5) * (uv.y * 0.5 + 0.5) * 10.);
    float spacing = 0.5;
    d = mod(d, spacing) / spacing;
    color.rgb = vec3(d);

    // trying to get some blues
    color.rgb = mix(vec3(0.02, 0.04, 0.4), vec3(0.04, normalCosTime(1.,1.) * 0.24, 0.6), d/15.);
    
    // output to screen
    gl_FragColor = color;
}
