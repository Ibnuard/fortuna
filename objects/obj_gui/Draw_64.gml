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
var _main_y = _mid_y - (_main_h / 2) - 5;
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

// Configure slot rules based on pawn data (dynamically mockup'd here)
var _fate_max = 6;
var _prop_max = 12;
var _fate_filled = 2;
var _prop_filled = 5;

// Cards Scaling & Sizing
var _card_spr = spr_card_placeholder;
var _card_scale = 0.74; // Shrink to make UI look more breathable
var _card_w = sprite_get_width(_card_spr) * _card_scale;
var _card_h = sprite_get_height(_card_spr) * _card_scale;
var _card_gap = 16;

// Logic: Determine grid columns (min 5, max 6 per row)
var _columns = clamp(max(_fate_max, _prop_max), 5, 6);

// Auto-calculate dynamic total width based on the number of columns
var _total_cards_w = (_card_w * _columns) + (_card_gap * max(0, _columns - 1));

// Panel Dimensions
var _prop_panel_w = _total_cards_w + 100; // 50px padding on left and right

// Increased to 70% of room height to comfortably fit slots and give room for submerging
var _prop_panel_h = room_height * 0.7; 
var _prop_panel_x = room_width / 2 - (_prop_panel_w / 2);

// Submerge the panel so the bottom rounded corners are cut off off-screen
var _submerged_amt = 150; // Increased to 120 so the thick rounded corners are fully pushed past the screen edge
var _prop_target_y = room_height - _prop_panel_h + _submerged_amt; 
var _prop_panel_y = _prop_target_y + property_y_offset;

// Render only if the panel is on screen
if (property_y_offset < 790) {
    
    // Draw Panel Base
    draw_sprite_stretched(spr_gui_bottom_container, 0, _prop_panel_x, _prop_panel_y, _prop_panel_w, _prop_panel_h);
    
    // Draw Close Button (Top Right...
    var _close_scale = 0.65;
    var _close_w = sprite_get_width(spr_panel_close) * _close_scale;
    var _close_h = sprite_get_height(spr_panel_close) * _close_scale;
    var _close_x = _prop_panel_x + _prop_panel_w - (_close_w * 0.7);
    var _close_y = _prop_panel_y - (_close_h * 0.3);
    
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _close_hover = point_in_rectangle(_mx, _my, _close_x, _close_y, _close_x + _close_w, _close_y + _close_h);
    var _close_pressed = _close_hover && mouse_check_button(mb_left);
    
    if (_close_hover) {
        // Prevent click bleeding into drag tracking
        if (mouse_check_button_pressed(mb_left)) {
             is_dragging_panel = false;
        }
        if (mouse_check_button_released(mb_left)) {
            gui_state = "MAIN"; // Return to main UI
        }
    }
    
    var _draw_scale = _close_scale;
    var _draw_x = _close_x;
    var _draw_y = _close_y;
    
    // JUICE: Scale down when pressed
    if (_close_pressed) {
        _draw_scale = _close_scale * 0.9;
        var _shrink_w = _close_w - (sprite_get_width(spr_panel_close) * _draw_scale);
        var _shrink_h = _close_h - (sprite_get_height(spr_panel_close) * _draw_scale);
        _draw_x += _shrink_w / 2;
        _draw_y += _shrink_h / 2;
    }
    
    // Draw close button
    draw_sprite_ext(spr_panel_close, 0, _draw_x, _draw_y, _draw_scale, _draw_scale, 0, c_white, 1);
    
    // Glow when hovered
    if (_close_hover && !_close_pressed) {
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(spr_panel_close, 0, _draw_x, _draw_y, _draw_scale, _draw_scale, 0, c_white, 0.25);
        gpu_set_blendmode(bm_normal);
    }
    
    // ─── Scrollable Surface Architecture ───
    
    var _inner_w = _total_cards_w;
    var _inner_h = _prop_panel_h - _submerged_amt - 100; // 50px top buffer + 50px bottom buffer dynamically calculated
    var _inner_x = _prop_panel_x + 50; // Aligned to 50px left padding
    var _inner_y = _prop_panel_y + 50; // Aligned to 50px top padding
    
    // Prevent crashes from negative surface sizes during weird resolution shifts
    if (_inner_w > 0 && _inner_h > 0) {
        
        // Guarantee surface existence and resizing
        if (!surface_exists(surf_panel)) {
            surf_panel = surface_create(_inner_w, _inner_h);
        } else if (surface_get_width(surf_panel) != _inner_w || surface_get_height(surf_panel) != _inner_h) {
            surface_free(surf_panel);
            surf_panel = surface_create(_inner_w, _inner_h);
        }
        
        // Target surface and clean background transparency
        surface_set_target(surf_panel);
        draw_clear_alpha(c_black, 0);
        
        // Y Cursor tracks rendering progression vertically inside the surface
        // Start negative to simulate scrolling down
        var _draw_cursor_y = -panel_scroll_y; 
        
        // Central alignment setting
        draw_set_font(fnt_main);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        var _text_x = _inner_w / 2;
        
        // Pivot normalization for Grid
        var _origin_x = sprite_get_xoffset(_card_spr) * _card_scale;
        var _origin_y = sprite_get_yoffset(_card_spr) * _card_scale;
        
        // --- 1. RENDER FATE CARDS GROUP ---
        _draw_cursor_y += 15; // Padding above header
        
        // Removed unsupported em-dash symbols 
        var _fate_str = "Fate Cards (" + string(_fate_filled) + "/" + string(_fate_max) + ")";
        
        draw_set_color(c_black); draw_set_alpha(0.3); draw_text(_text_x + 2, _draw_cursor_y + 3, _fate_str);
        draw_set_color(c_white); draw_set_alpha(1.0); draw_text(_text_x, _draw_cursor_y, _fate_str);
        
        _draw_cursor_y += 25 + _origin_y; // Plunge to grid alignment level
        
        // Fate Grid
        for (var i = 0; i < _fate_max; i++) {
            var _col = i mod _columns;
            var _row = i div _columns;
            var _cx = (_col * (_card_w + _card_gap)) + _origin_x;
            var _cy = _draw_cursor_y + (_row * (_card_h + _card_gap));
            
            draw_sprite_ext(_card_spr, 0, _cx, _cy, _card_scale, _card_scale, 0, c_white, 1);
        }
        
        var _fate_rows = ceil(_fate_max / _columns);
        _draw_cursor_y += (_fate_rows * (_card_h + _card_gap)) - _origin_y;
        
        // --- 2. RENDER PROPERTIES GROUP ---
        _draw_cursor_y += 20; // Separator space
        
        // Removed unsupported em-dash symbols
        var _prop_str = "Properties (" + string(_prop_filled) + "/" + string(_prop_max) + ")";
        
        draw_set_color(c_black); draw_set_alpha(0.3); draw_text(_text_x + 2, _draw_cursor_y + 3, _prop_str);
        draw_set_color(c_white); draw_set_alpha(1.0); draw_text(_text_x, _draw_cursor_y, _prop_str);
        
        _draw_cursor_y += 25 + _origin_y; // Plunge to grid alignment level
        
        // Properties Grid
        for (var i = 0; i < _prop_max; i++) {
            var _col = i mod _columns;
            var _row = i div _columns;
            var _cx = (_col * (_card_w + _card_gap)) + _origin_x;
            var _cy = _draw_cursor_y + (_row * (_card_h + _card_gap));
            
            draw_sprite_ext(_card_spr, 0, _cx, _cy, _card_scale, _card_scale, 0, c_white, 1);
        }
        
        var _prop_rows = ceil(_prop_max / _columns);
        _draw_cursor_y += (_prop_rows * (_card_h + _card_gap)) - _origin_y;
        _draw_cursor_y += 15; // Tail space so it doesn't clip immediately
        
        // Restore screen rendering
        surface_reset_target();
        
        // Draw the clipped Surface window perfectly within the UI border
        draw_surface(surf_panel, _inner_x, _inner_y);
        
        // Update Scroll bounds using pure accumulated cursor metrics 
        // Real absolute height = Current Cursor Pos + whatever we scrolled (since it was deducted at start)
        var _total_content_height = (_draw_cursor_y + panel_scroll_y); 
        if (_total_content_height > _inner_h) {
            panel_max_scroll = _total_content_height - _inner_h;
        } else {
            panel_max_scroll = 0;
        }
        
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }
}
