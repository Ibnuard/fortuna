//
// Balatro-style Vignette Overlay
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;

void main()
{
    vec2 uv = gl_FragCoord.xy / u_resolution;
    
    // Vignette
    vec2 vc = uv - 0.5;
    float dist = length(vc * vec2(1.2, 1.0));
    
    // Lebih soft, lebih kecil coverage
    float vignette = smoothstep(1.0, 0.3, dist);
    
    // Tengah = fully transparent, pinggir = max 50% black
    float alpha = (1.0 - vignette) * 0.5;
    
    gl_FragColor = vec4(0.0, 0.0, 0.0, alpha);
}
