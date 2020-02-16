precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D u_sampler;

varying vec2 v_texcoord;

float grid_size = 100.0;

void main() {
    
    vec4 noise = texture2D(u_sampler, v_texcoord.xy + vec2(u_time * 0.1));
    vec4 color = vec4(1.0);
    vec2 uv = gl_FragCoord.xy;
    
    //noise -= 0.5;
    uv.xy += noise.rg * 20.0;

    vec2 f = fract(uv.xy / vec2(grid_size, grid_size));
    
    float d = distance(vec2(0.), f);
    float spacing = 0.08;
    d = mod(d, spacing) / spacing;
    d = step(0.2, d);
    color.rgb = vec3(d);
    
    // normal black and white
    // gl_FragColor = color;

    // wave colors
    gl_FragColor = mix(vec4(1., 1., 1., 1.), vec4(0.05, 0.3, 0.8, 1.), color.r);
}
