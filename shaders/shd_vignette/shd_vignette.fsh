//
// Balatro-style Vignette Overlay
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution;
    
    // ── Vignette ──
    vec2 vc = uv - 0.5;
    float dist = length(vc * vec2(1.2, 1.0));
    float vignette = smoothstep(0.8, 0.4, dist);
    float vig_factor = mix(0.4, 1.0, vignette);
    
    // Output black with alpha based on factor
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0 - vig_factor);
}
