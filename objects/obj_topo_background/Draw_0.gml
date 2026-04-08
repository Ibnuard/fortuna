/// @description Draw Topo Shader Background

elapsed_time += 0.01;

if (shader_is_compiled(shd_topo_background)) {
    shader_set(shd_topo_background);
    
    // We use window/view dimensions for the resolution uniform to ensure UVs are correct
    shader_set_uniform_f(u_resolution, room_width, room_height);
    shader_set_uniform_f(u_time, elapsed_time);
    shader_set_uniform_f(u_color_bg, color_bg_r, color_bg_g, color_bg_b);
    shader_set_uniform_f(u_color_pattern, color_pattern_r, color_pattern_g, color_pattern_b);
    
    // Draw a rectangle covering the entire room area
    draw_rectangle_color(0, 0, room_width, room_height, c_white, c_white, c_white, c_white, false);
    
    shader_reset();
} else {
    draw_clear(make_color_rgb(45, 123, 69));
}
