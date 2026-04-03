//
// CRT Scanlines + Vignette — Balatro-style
// Outputs a multiply factor (white = no change, darker = darken)
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution;
    
    // ── Scanlines ──
    float py = gl_FragCoord.y;
    float scanline = 1.0 - step(0.5, mod(py / 3.0, 1.0)) * 0.15;
    
    // ── Vignette ──
    vec2 vc = uv - 0.5;
    float dist = length(vc * vec2(1.2, 1.0));
    float vignette = smoothstep(0.85, 0.35, dist);
    float vig_factor = mix(0.55, 1.0, vignette);
    
    // Output multiply factor as color
    float factor = scanline * vig_factor;
    gl_FragColor = vec4(factor, factor, factor, 1.0);
}
