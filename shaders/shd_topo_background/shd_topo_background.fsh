//
// Topographic Background Fragment Shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_color_bg;
uniform vec3 u_color_pattern;

// Hash function for noise
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// 2D Perlin Noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

// Fractal Brownian Motion
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    for (int i = 0; i < 5; ++i) {
        v += a * noise(p);
        p = rot * p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    
    // Maintain aspect ratio for noise
    float aspect = u_resolution.x / u_resolution.y;
    vec2 noise_uv = uv * vec2(aspect, 1.0) * 3.0;
    
    // Add movement
    noise_uv += u_time * 0.05;
    
    // Get noise value
    float n = fbm(noise_uv);
    
    // Create contour lines using sine wave
    // Frequency of lines
    float freq = 12.0; 
    float dist = n * freq + u_time * 0.2;
    
    // Anti-aliased line drawing
    float lines = abs(sin(dist * 3.14159));
    float thickness = 0.1;
    float smoothing = 0.1;
    float line_mask = smoothstep(thickness + smoothing, thickness, lines);
    
    // Mix colors
    vec3 final_color = mix(u_color_bg, u_color_pattern, line_mask);
    
    gl_FragColor = vec4(final_color, 1.0);
}
