// Top Bar
draw_sprite_stretched(spr_gui_top_bar, 0, 0, 0, room_width, 200);

// Bottom Three Button Container
var _target_y = 825;
draw_sprite_stretched(spr_gui_bottom_container, 0, room_width / 2 - 540, _target_y + bottom_y_offset, 1080, 300);

// Button Layout Constants
// Keep main button at standard comfortable size
var _main_w = 320;
var _main_h = 120;

// Make side buttons only slightly smaller than the main button
var _side_w = 300; 
var _side_h = 110;

var _gap    = 24; // Give balanced breathing room

// Vertical Center Alignment
var _mid_y = _target_y + bottom_y_offset + 120;
var _main_y = _mid_y - (_main_h / 2);
// Aligning bottoms for a unified 3D perspective base
var _side_y = _main_y + _main_h - _side_h;

// Center Main Button Geometry
var _center_x = room_width / 2 - (_main_w / 2);

// Calculate Left & Right Button X
var _left_x   = _center_x - _gap - _side_w;
var _right_x  = _center_x + _main_w + _gap;

// Draw Left Button (Red)
draw_gui_button(_left_x, _side_y, _side_w, _side_h, spr_button_red, "Property", #3E2500, fnt_gui_button_medium);

// Draw Center Button (Main)
draw_gui_button(_center_x, _main_y, _main_w, _main_h, spr_button_main, "Roll", #3E2500);

// Draw Right Button (Blue)
draw_gui_button(_right_x, _side_y, _side_w, _side_h, spr_button_blue, "Shop", #3E2500, fnt_gui_button_medium);
