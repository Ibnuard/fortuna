//
// Topographic Background Fragment Shader with occasional Dollar Signs
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_color_bg;
uniform vec3 u_color_pattern;

// Hash functions for noise and randomness
float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453123) * 2.0 - 1.0;
}

// 2D Perlin Noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

// Fractal Brownian Motion
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    for (int i = 0; i < 5; ++i) {
        v += a * noise(p);
        p = rot * p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// Procedural Stylized Dollar Sign ($)
float drawDollar(vec2 p) {
    p *= 2.5; // Scale up local space
    
    // Vertical strike-through line
    float line = smoothstep(0.06, 0.04, abs(p.x)) * smoothstep(0.45, 0.4, abs(p.y));
    
    // S-shape (simplified as 3 horizontal bars and 2 vertical segments)
    float s = 0.0;
    // Top bar
    s += smoothstep(0.06, 0.04, abs(p.y - 0.3)) * smoothstep(0.2, 0.15, abs(p.x - 0.05));
    // Mid bar
    s += smoothstep(0.06, 0.04, abs(p.y)) * smoothstep(0.2, 0.15, abs(p.x));
    // Bot bar
    s += smoothstep(0.06, 0.04, abs(p.y + 0.3)) * smoothstep(0.2, 0.15, abs(p.x + 0.05));
    // Vertical left top
    s += smoothstep(0.06, 0.04, abs(p.x + 0.15)) * smoothstep(0.15, 0.1, abs(p.y - 0.15));
    // Vertical right bot
    s += smoothstep(0.06, 0.04, abs(p.x - 0.15)) * smoothstep(0.15, 0.1, abs(p.y + 0.15));
    
    return clamp(s + line, 0.0, 1.0);
}

// 2D Rotation Helper
mat2 rotate2d(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float aspect = u_resolution.x / u_resolution.y;
    vec2 noise_uv = uv * vec2(aspect, 1.0);
    
    // --- TOPOGRAPHIC PATTERN ---
    float n = fbm(noise_uv * 3.0 + u_time * 0.05);
    float freq = 12.0; 
    float dist = n * freq + u_time * 0.2;
    float lines = abs(sin(dist * 3.14159));
    float line_mask = smoothstep(0.2, 0.1, lines);
    
    // --- DOLLAR SIGN PATTERN ---
    // Add base movement offset matching the noise
    vec2 moving_uv = noise_uv + u_time * 0.05; 
    vec2 grid_uv = moving_uv * 8.0; // Balanced grid
    vec2 ipos = floor(grid_uv);
    vec2 fpos = fract(grid_uv) - 0.5;
    
    // Random seed per cell
    float cell_rand = rand(ipos);
    float wobble_speed = 0.5 + cell_rand * 1.5;
    
    // 1. Irregular Floating (Position Wobble)
    // We add a unique sin/cos offset based on time and cell rand
    fpos.x += sin(u_time * wobble_speed + cell_rand * 10.0) * 0.15;
    fpos.y += cos(u_time * (wobble_speed * 0.7) + cell_rand * 5.0) * 0.15;
    
    // 2. Rotation (Wobble Angle)
    // Rotate fpos before drawing
    float angle = sin(u_time * wobble_speed * 1.2 + cell_rand * 10.0) * 0.6; // ~34 degrees max tilt
    fpos = rotate2d(angle) * fpos;
    
    // Appearance timing
    float spawn_timer = fract(u_time * 0.2 + cell_rand * 10.0);
    float visibility = smoothstep(0.0, 0.1, spawn_timer) * smoothstep(1.0, 0.9, spawn_timer);
    
    float dollar_mask = 0.0;
    // Balanced threshold: middle ground quantity
    if (cell_rand > 0.88) {
        dollar_mask = drawDollar(fpos) * visibility;
    }
    
    // --- FINAL BLENDING ---
    vec3 base_color = u_color_bg;
    
    // Mix topo pattern
    vec3 final_color = mix(base_color, u_color_pattern, line_mask);
    
    // Mix floating dollar signs (matching pattern color)
    vec3 dollar_color = u_color_pattern;
    final_color = mix(final_color, dollar_color, dollar_mask);
    
    gl_FragColor = vec4(final_color, 1.0);
}
