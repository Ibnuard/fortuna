//
// CRT Scanlines + Vignette — Balatro-style Overlay
// Outputs BLACK with varying alpha to darken the screen
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;
uniform float u_vignette_mix; // 0.0 = none, 1.0 = full
uniform float u_scanline_mix; // 0.0 = none, 1.0 = full

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution;
    
    // ── Scanlines (ADJUSTED: Wider spacing 5.0, Lighter opacity 0.2) ──
    float py = gl_FragCoord.y;
    // Using a softer sine-based scanline for a less "harsh" look
    float scan_wave = (sin(py * 1.5) + 1.0) * 0.5; // Oscillates between 0 and 1
    float scanline = 1.0 - (scan_wave * 0.2);     // 20% max darkening
    
    // ── Vignette ──
    vec2 vc = uv - 0.5;
    float dist = length(vc * vec2(1.2, 1.0));
    float vignette = smoothstep(0.8, 0.4, dist);
    float vig_factor = mix(0.4, 1.0, vignette);
    
    // Apply mixing uniforms
    float v = mix(1.0, vig_factor, u_vignette_mix);
    float s = mix(1.0, scanline, u_scanline_mix);
    
    // The total "darkening" factor
    float factor = v * s;
    
    // Output black with alpha based on factor
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0 - factor);
}
