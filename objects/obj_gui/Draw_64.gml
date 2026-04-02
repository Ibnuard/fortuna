// Top Bar
draw_sprite_stretched(spr_gui_top_bar, 0, 0, 0, room_width, 200);

// ─── BOTTOM GUI CONTAINER & BUTTONS ───

// Button Layout Constants
var _main_w = 360;
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
if (draw_gui_button(_left_x, _side_y, _side_w, _side_h, spr_button_red, "Property", c_white, fnt_gui_button_medium)) {
    gui_state = "PROPERTY"; // Trigger slide out
}

// Draw Center Button (Main)
draw_gui_button(_center_x, _main_y, _main_w, _main_h, spr_button_main, "Roll The Dice!", c_white);

// Draw Right Button (Blue)
draw_gui_button(_right_x, _side_y, _side_w, _side_h, spr_button_blue, "Shop", c_white, fnt_gui_button_medium);


// ─── PROPERTY OVERLAY PANEL ───

if (property_y_offset < 790) { // Only draw and calculate if visible
    
    // --- Dynamic Card Logic ---
    var _card_count  = 5; // Placeholder (bisa dinamis sesuai Pawn nanti)
    var _filled_slot = 2; // Placeholder 
    
    // Cards Scaling & Sizing
    var _card_spr = spr_card_placeholder;
    var _card_scale = 0.74; // Shrink to make UI look more breathable
    var _card_w = sprite_get_width(_card_spr) * _card_scale;
    var _card_h = sprite_get_height(_card_spr) * _card_scale;
    var _card_gap = 16;
    
    // Auto-calculate dynamic total width based on the number of cards
    var _total_cards_w = (_card_w * _card_count) + (_card_gap * max(0, _card_count - 1));
    
    // Panel Dimensions
    var _prop_panel_w = _total_cards_w + 100; // 50px padding on left and right
    
    // Add an extra 20px height dedicated specifically for the Text Header
    var _header_space = 20; 
    var _prop_panel_h = _card_h + 170 + _header_space; 
    var _prop_panel_x = room_width / 2 - (_prop_panel_w / 2);
    
    // Submerge the panel so the bottom rounded corners are cut off off-screen
    var _submerged_amt = 50; 
    var _prop_target_y = room_height - _prop_panel_h + _submerged_amt; 
    var _prop_panel_y = _prop_target_y + property_y_offset;
    
    // Draw Panel Base
    draw_sprite_stretched(spr_gui_bottom_container, 0, _prop_panel_x, _prop_panel_y, _prop_panel_w, _prop_panel_h);
    
    // Draw Close Button (Top Right, slightly scaled down proportionally)
    var _close_scale = 0.65;
    var _close_w = sprite_get_width(spr_panel_close) * _close_scale;
    var _close_h = sprite_get_height(spr_panel_close) * _close_scale;
    var _close_x = _prop_panel_x + _prop_panel_w - (_close_w * 0.7);
    var _close_y = _prop_panel_y - (_close_h * 0.3);
    
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _close_hover = point_in_rectangle(_mx, _my, _close_x, _close_y, _close_x + _close_w, _close_y + _close_h);
    
    if (_close_hover) {
        if (mouse_check_button_released(mb_left)) {
            gui_state = "MAIN"; // Return to main UI
        }
    }
    
    // Draw smaller close button (Using offset logic to ensure it doesn't move weirdly if origin differs)
    draw_sprite_ext(spr_panel_close, 0, _close_x, _close_y, _close_scale, _close_scale, 0, c_white, 1);
    
    // ─── Draw Slot Info Text ───
    
    draw_set_font(fnt_main);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _text_x = _prop_panel_x + (_prop_panel_w / 2);
    // Draw it beautifully nestled inside the new flat _header_space we carved out
    var _text_y = _prop_panel_y + 32 + (_header_space / 2); 
    var _text_str = "Properties (" + string(_filled_slot) + "/" + string(_card_count) + ")";
    
    // Simple Shadow
    draw_set_color(c_black); draw_set_alpha(0.3);
    draw_text(_text_x + 2, _text_y + 3, _text_str);
    // Main Text
    draw_set_alpha(1.0); draw_set_color(c_white);
    draw_text(_text_x, _text_y, _text_str);
    
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    
    // ─── Draw Card Placeholders (Origin-Agnostic Centering) ───
    
    var _origin_x = sprite_get_xoffset(_card_spr) * _card_scale;
    var _origin_y = sprite_get_yoffset(_card_spr) * _card_scale;
    
    var _visual_start_x = _prop_panel_x + 50; 
    
    // Exact 50px top padding + the dedicated header space for text
    var _visual_start_y = _prop_panel_y + 50 + _header_space;
    
    var _start_x = _visual_start_x + _origin_x;
    var _card_y = _visual_start_y + _origin_y;
    
    for (var i = 0; i < _card_count; i++) {
        draw_sprite_ext(_card_spr, 0, _start_x + (i * (_card_w + _card_gap)), _card_y, _card_scale, _card_scale, 0, c_white, 1);
    }
}
