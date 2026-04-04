// Draw GUI event — renders the sprite chunk at the particle's GUI-space position
var _alpha = life_timer / life_max;

draw_set_alpha(_alpha);
draw_sprite_part(spr, sub_img, chunk_xx, chunk_yy, chunk_sz, chunk_sz, gui_x, gui_y);
draw_set_alpha(1.0);
