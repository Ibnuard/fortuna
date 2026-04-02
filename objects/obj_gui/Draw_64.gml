// Top Bar
draw_sprite_stretched(spr_gui_top_bar, 0, 0, 0, room_width, 200);

// Bottom Three Button Container
var _target_y = 825;
draw_sprite_stretched(spr_gui_bottom_container, 0, room_width / 2 - 540, _target_y + bottom_y_offset, 1080, 300);

// Main Button (320x120)
var _btn_w = 320;
var _btn_h = 120;
var _btn_x = room_width / 2 - (_btn_w / 2);
// Adjusted from 150 to 115 since the bottom part of the container is likely off-screen
var _btn_y = _target_y + bottom_y_offset + 120 - (_btn_h / 2);

draw_gui_button(_btn_x, _btn_y, _btn_w, _btn_h, spr_button_main, "Roll");
