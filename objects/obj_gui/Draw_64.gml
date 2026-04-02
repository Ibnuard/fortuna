// Top Bar
draw_sprite_stretched(spr_gui_top_bar, 0, 0, 0, room_width, 200);

// ─── BOTTOM GUI CONTAINER & BUTTONS ───

// Button Layout Constants
var _main_w = 240;
var _main_h = 100;

var _side_w = 240; 
var _side_h = 90;

var _gap    = 24; 

// Dinamically Calculate Panel Dimensions (Tight Padding)
var _total_btn_w = (_side_w * 2) + _main_w + (_gap * 2);
var _padding_x = 48; // Space from buttons to panel edge
var _panel_w = _total_btn_w + (_padding_x * 2); 
var _panel_h = 190; // Shrink panel height massively from 300 to 190

// Center the Panel
var _target_y = 890; // Slide it down slightly to compensate for lost height padding
var _panel_draw_y = _target_y + bottom_y_offset;
var _panel_x = room_width / 2 - (_panel_w / 2);

draw_sprite_stretched(spr_gui_bottom_container, 0, _panel_x, _panel_draw_y, _panel_w, _panel_h);

// Vertical Center Alignment (Buttons placed relative to panel center)
var _mid_y = _panel_draw_y + (_panel_h / 2) - 12; // Modifiers to counter heavy shadows
var _main_y = _mid_y - (_main_h / 2);
// Aligning bottoms for a unified 3D perspective base
var _side_y = _main_y + _main_h - _side_h;

// Center Main Button Geometry
var _center_x = room_width / 2 - (_main_w / 2);

// Calculate Left & Right Button X
var _left_x   = _center_x - _gap - _side_w;
var _right_x  = _center_x + _main_w + _gap;

// Draw Left Button (Red)
draw_gui_button(_left_x, _side_y, _side_w, _side_h, spr_button_red, "Property", c_white, fnt_gui_button_medium);

// Draw Center Button (Main)
draw_gui_button(_center_x, _main_y, _main_w, _main_h, spr_button_main, "Roll The Dice!", c_white);

// Draw Right Button (Blue)
draw_gui_button(_right_x, _side_y, _side_w, _side_h, spr_button_blue, "Shop", c_white, fnt_gui_button_medium);
