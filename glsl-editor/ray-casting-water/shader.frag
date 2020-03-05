#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

const int steps = 128;
const float sphereRadius = 0.2;
const float tinyDist = 0.001;
const float maxDist = 2.0;

// http://www.iquilezles.org/www/articles/palettes/palettes.htm
// As t runs from 0 to 1 (our normalized palette index or domain), 
//the cosine oscilates c times with a phase of d. 
//The result is scaled and biased by a and b to meet the desired constrast and brightness.
vec3 cosPalette( float t, vec3 a, vec3 b, vec3 c, vec3 d ){
    return a + b*cos( 6.28318*(c*t+d) );
}

// Smooth minimum function
float smin(float a, float b, float k) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

// Maximum/minumum elements of a vector
float vmax(vec2 v) {
	return max(v.x, v.y);
}

float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}

float vmax(vec4 v) {
	return max(max(v.x, v.y), max(v.z, v.w));
}

float fSphere(vec3 pos, float rad) {
	return length(pos) - rad;
}

float fSurface(vec3 pos) {
    float reversed = abs(min(0.0, pos.y));
    return step(0.0, pos.y);
}

// Plane with normal n (n is normalized) at some distance from the origin
float fPlane(vec3 pos, vec3 n, float distanceFromOrigin) {
	return dot(pos, n) + distanceFromOrigin;
}

// A box
float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

float scene(vec3 pos) {
    // The first sphere, stays in the center
    float s = fBox(pos, vec3(0.1));
    // The second sphere, moves around
    vec3 rotatingSphere = pos;
    rotatingSphere.x += sin(u_time);
    rotatingSphere.y += sin(u_time)/2.;
    rotatingSphere.z += sin(u_time)/2.0;
    float s2 = fBox(rotatingSphere, vec3(0.1));
    float surface = fSurface(pos);
    return smin(s, s2, 1.4);
    // return smin(s, plane, 1.4);
}

vec4 trace(vec3 camOrigin, vec3 dir) {
    vec3 ray = camOrigin;
    float totalDist = 0.0;
    float dist;
    for (int i = 0; i < steps; i++) {
        dist = scene(ray);
        if (dist < tinyDist) {
            float c = totalDist/maxDist;
            //return vec4(c, c, c, 1.0);
            return vec4(cosPalette(c,
                                    vec3(0.5),
                                    vec3(0.5),
                                    vec3(2.0, 1.0, 0.0),
                                    vec3(0.50, 0.20, 0.25)), 1.0);
        }
        totalDist += dist;
        ray += dist * dir;
    }
    return vec4(cosPalette(0.25,
                                vec3(0.5),
                                vec3(0.5),
                                vec3(1.0),
                                vec3(0.30, 0.20, 0.20)), 1.0);
}

void main(){
    vec2 uv = gl_FragCoord.xy/u_resolution.xy;

    // center our screen so (0,0) is middle
    uv = (uv * 2.0) - vec2(1.);

    // define some variables like our camera,
    // ray origin, and direction
    vec3 camOrigin = vec3(0.0,0.0,-1.0);
    vec3 rayOrigin = vec3(uv + camOrigin.xy, camOrigin.z + 1.0);
    vec3 dir = normalize(rayOrigin - camOrigin);

    // call the trace function
    vec4 color = trace(camOrigin, dir);

    gl_FragColor = color;
}