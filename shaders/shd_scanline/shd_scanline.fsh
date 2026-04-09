//
// CRT Scanlines Overlay
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;

void main()
{
    float py = gl_FragCoord.y;
    // Using a softer sine-based scanline for a less "harsh" look
    float scan_wave = (sin(py * 0.8) + 1.0) * 0.5; // Oscillates between 0 and 1
    float scanline = 1.0 - (scan_wave * 0.07);     // 12% max darkening
    
    // Output black with alpha based on factor
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0 - scanline);
}
