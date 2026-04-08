/// @description Initialize Topo Shader
elapsed_time = 0;

// Uniform handles
u_resolution    = shader_get_uniform(shd_topo_background, "u_resolution");
u_time          = shader_get_uniform(shd_topo_background, "u_time");
u_color_bg      = shader_get_uniform(shd_topo_background, "u_color_bg");
u_color_pattern = shader_get_uniform(shd_topo_background, "u_color_pattern");

// Colors (Normalized RGB)
// #2D7B45 (45, 123, 69)
color_bg_r = 45 / 255;
color_bg_g = 123 / 255;
color_bg_b = 69 / 255;

// #2C6027 (44, 96, 39)
color_pattern_r = 44 / 255;
color_pattern_g = 96 / 255;
color_pattern_b = 39 / 255;

depth = 16000;
