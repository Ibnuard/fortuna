//
// Vertex Shader: Deform Y position to create an arc
//
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_curvature;

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    
    // Calculate arc based on horizontal texture coordinate (0 to 1)
    // sin(x * PI) gives us a curve from 0 up to 1 and back to 0
    float arc = sin(in_TextureCoord.x * 3.14159265);
    
    // Apply the curvature to the Y position
    object_space_pos.y += arc * u_curvature;
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}
