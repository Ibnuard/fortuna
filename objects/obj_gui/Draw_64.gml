// ─── BALATRO-STYLE CURVED TOP BAR ───
// We render the 9-slice sprite flat to a surface first, 
// then warp the surface pixels via vertex geometry for a CRT cembung effect!

var _topbar_h = 180;

if (!surface_exists(surf_topbar)) {
    surf_topbar = surface_create(room_width, _topbar_h);
}

// 1. Draw 9-slice perfectly flat internally
surface_set_target(surf_topbar);
draw_clear_alpha(c_black, 0);
// Kembalikan Y ke 0 agar teksturnya penuh dan tidak ada garis transparan bocor di atas
draw_sprite_stretched(spr_gui_top_bar, 0, 0, 5, room_width, _topbar_h); 

// --- TOP BAR HUD MODULES ---
var _pad_x = 40; 
var _center_y = _topbar_h / 2; // Mathematical center (90px)
var _visual_mid_y = _center_y - 3; // Visual "Face" Center (87px) to align with 9-slice area

draw_set_font(fnt_main); // Setup font dynamically for measuring layout

// --- IMPROVEMENT: Resized Top Bar Button ---
var _map_btn_w = 190; 
var _map_btn_h = 64;  

// Smaller Utility Buttons for Map/Stat
var _sm_btn_w = 110;
var _sm_btn_h = 56;
var _inner_gap = 12;

// Calculate Label Constraints
var _label_str = "Target";
draw_set_font(fnt_gui_button_medium); // Make TARGET bigger
var _label_x = _pad_x + _map_btn_w + 30; // 30px gap after Map Info Button
var _label_w = string_width(_label_str);

// Calculate Number String Constraints
var _str_cur = "$0";
var _str_tgt = " / $0";

if (instance_exists(obj_controller)) {
    _str_cur = obj_controller.format_money(obj_controller.player_cash);
    _str_tgt = " / " + obj_controller.format_money(obj_controller.map_target);
} else {
    // Fallback for visual testing
    _str_cur = "$5.000";
    _str_tgt = " / $15.000";
}

draw_set_font(fnt_gui_button_medium); // BOTH are now the same size as requested
var _cur_w = string_width(_str_cur);
var _tgt_w_text = string_width(_str_tgt);

var _total_num_w = _cur_w + _tgt_w_text;
// Shift numbers to the left to make room for buttons on the right
var _num_x_start = room_width - _pad_x - (_sm_btn_w * 2) - (_inner_gap * 2) - _total_num_w - 20; 

// --- DRAW TARGET BAR (Stretched dynamically between labels) ---
var _tgt_x = _label_x + _label_w + 20; // Start after TARGET label
var _tgt_w = (_num_x_start - 20) - _tgt_x; // Stop right before the Number String
var _tgt_h = _map_btn_h; // 50px
var _tgt_y = _center_y - (_tgt_h / 2); // Physical alignment (starts at 65px)

// Draw "TARGET" Label
draw_set_font(fnt_gui_button_medium); // BESAR
draw_set_halign(fa_left); draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(40, 40, 40)); // Dark shadow 
draw_text(_label_x + 3, _visual_mid_y + 4, _label_str); // Harmonized shadow offset (+4)
draw_set_color(c_white); 
draw_text(_label_x, _visual_mid_y, _label_str);

// Teal Progress Fill
var _fill_pct = 0.41; // Mockup target percentage
// Precision adjustment: Fill must stay inside the 12px top and 18px bottom borders of the 9-slice
var _inner_y1 = _tgt_y + 12; // Start after top border
var _inner_y2 = _tgt_y + _tgt_h - 18; // End before 18px bottom border shadow
var _fill_pad = 4;
var _fill_w = (_tgt_w - 24) * _fill_pct; // Adjusted width padding based on 12px left/right borders

draw_set_color(make_color_rgb(6, 214, 160)); // Teal #06d6a0
draw_rectangle(_tgt_x + 12, _inner_y1 + _fill_pad, _tgt_x + 12 + _fill_w, _inner_y2 - _fill_pad, false);
draw_set_color(c_white);

// Outline Sprite (Stretched 9-slice target bar)
draw_sprite_stretched(spr_target_bar, 0, _tgt_x, _tgt_y, _tgt_w, _tgt_h);

// Draw Numbers String outside the Bar
draw_set_halign(fa_left); draw_set_valign(fa_middle);

// 1. Current (Gold)
draw_set_font(fnt_gui_button_medium); 
draw_set_color(c_black); draw_set_alpha(0.3);
draw_text(_num_x_start + 3, _visual_mid_y + 4, _str_cur); 
draw_set_alpha(1.0);
draw_set_color(make_color_rgb(248, 194, 58)); // Gold
draw_text(_num_x_start, _visual_mid_y, _str_cur);

// 2. Limit/Target (Matched Font Size & White)
draw_set_font(fnt_gui_button_medium); // MATCHED current font
var _tgt_num_x = _num_x_start + _cur_w;
draw_set_color(c_black); draw_set_alpha(0.3);
draw_text(_tgt_num_x + 3, _visual_mid_y + 4, _str_tgt); 
draw_set_alpha(1.0);
draw_set_color(c_white);
draw_text(_tgt_num_x, _visual_mid_y, _str_tgt);

draw_set_halign(fa_left); draw_set_valign(fa_top);

draw_set_halign(fa_left); draw_set_valign(fa_top);

surface_reset_target();

// 2. Map surface to a curved mesh
var _tex = surface_get_texture(surf_topbar);
draw_primitive_begin_texture(pr_trianglestrip, _tex);

var _segments = 24; // 24 slices is very smooth
// Dikurangi setengahnya agar jauh lebih halus (subtle), gaya Balatro itu tipis!
var _curve_intensity = -5; // Minus means it curves/bulges UPWARDS in the center 

for (var i = 0; i <= _segments; i++) {
    var _ratio = i / _segments;
    var _x = _ratio * room_width;
    
    // Sine arc: 0 at edges, 1 at center
    var _arc = sin(_ratio * pi);
    var _y_offset = _arc * _curve_intensity; 
    
    draw_vertex_texture(_x, top_y_offset + 0 + _y_offset, _ratio, 0); // Top Edge
    draw_vertex_texture(_x, top_y_offset + _topbar_h + _y_offset, _ratio, 1); // Bottom Edge
}
draw_primitive_end();

// (Top Bar Buttons logic moved to the bottom of script)


// ─── BOTTOM GUI CONTAINER & BUTTONS ───

// Button Layout Constants
var _main_w = 320; 
var _main_h = 90;
var _side_w = 240; 
var _side_h = 90;
var _gap    = 24; 

// Dinamically Calculate Panel Dimensions
var _total_btn_w = (_side_w * 2) + _main_w + (_gap * 2);
var _padding_x = 48;
var _panel_w = _total_btn_w + (_padding_x * 2); 
var _panel_h = 240; // Taller panel for better spacing

// Center the Panel (submerged deeper to hide rounded corners)
var _target_y = 855; 
var _panel_draw_y = _target_y + bottom_y_offset;
var _panel_x = room_width / 2 - (_panel_w / 2);

draw_sprite_stretched(spr_gui_bottom_container, 0, _panel_x, _panel_draw_y, _panel_w, _panel_h);

// ─── TURN BADGE (Staggered) ───
var _turn_str = "Turn 1 / 20";
if (instance_exists(obj_controller)) {
    _turn_str = "Turn " + string(obj_controller.current_turn) + " / " + string(obj_controller.map_max_turns);
}
var _badge_angle = 0;
var _badge_w = 200;
var _badge_h = 80;
var _badge_x = room_width / 2;
var _badge_y = _panel_draw_y - 2 + stagger_turn_badge;

// Draw spr_container (Origin set to 100, 50 in sprite editor)
draw_set_alpha(1.0);
draw_sprite_ext(spr_container, 0, _badge_x, _badge_y + 10, _badge_w/200, _badge_h/100, _badge_angle, c_white, 1);

// Text inside badge
draw_set_font(fnt_main);
draw_set_halign(fa_center); draw_set_valign(fa_middle);
draw_set_color(c_black); draw_set_alpha(0.3);
draw_text_transformed(_badge_x + 2, _badge_y + 12, _turn_str, 1.6, 1.6, _badge_angle);
draw_set_color(c_white); draw_set_alpha(1.0);
draw_text_transformed(_badge_x, _badge_y + 8, _turn_str, 1.6, 1.6, _badge_angle);
draw_set_halign(fa_left); draw_set_valign(fa_top);

// (Bottom Panel Buttons logic moved to the bottom of script)




// (Property Overlay logic moved to the bottom of script)


// ─── CRT SCANLINE + VIGNETTE OVERLAY (Shader-based, Balatro-style) ───
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

if (shader_is_compiled(shd_game_fx)) {
    gpu_set_blendmode(bm_normal); 
    shader_set(shd_game_fx);
    var _u_res = shader_get_uniform(shd_game_fx, "u_resolution");
    var _u_vig = shader_get_uniform(shd_game_fx, "u_vignette_mix");
    var _u_scn = shader_get_uniform(shd_game_fx, "u_scanline_mix");
    
    shader_set_uniform_f(_u_res, _gui_w, _gui_h);
    shader_set_uniform_f(_u_vig, 1.0); // Apply Vignette
    shader_set_uniform_f(_u_scn, 0.0); // No Scanlines yet
    
    draw_rectangle_color(0, 0, _gui_w, _gui_h, c_black, c_black, c_black, c_black, false);
    shader_reset();
}

// ─── INTERACTIVE BUTTONS (Drawn after shader to stay bright, but before Property Panel to be dimmable) ───

// 1. Top Bar Buttons
var _map_btn_x = _pad_x; 
var _map_btn_y = top_y_offset + (_topbar_h / 2) - (_map_btn_h / 2) + stagger_option;
draw_gui_button(_map_btn_x, _map_btn_y, _map_btn_w, _map_btn_h, spr_button_main, "Option", c_white, fnt_main, can_interact_gui);

var _stat_btn_x = room_width - _pad_x - _sm_btn_w;
var _map_top_x  = _stat_btn_x - _inner_gap - _sm_btn_w;
var _top_btn_y  = top_y_offset + (_topbar_h / 2) - (_sm_btn_h / 2) + stagger_map_stat;

if (draw_gui_button(_map_top_x, _top_btn_y, _sm_btn_w, _sm_btn_h, spr_button_emerald, "Map", c_white, fnt_main, can_interact_gui)) {
    // Open Map logic
}
if (draw_gui_button(_stat_btn_x, _top_btn_y, _sm_btn_w, _sm_btn_h, spr_button_purple, "Stats", c_white, fnt_main, can_interact_gui)) {
    stats_popup_open = true;
}

// 2. Bottom Panel Buttons
var _mid_y = _panel_draw_y + (_panel_h / 2) - 10; 
var _main_y = _mid_y - (_main_h / 2);
var _center_x = room_width / 2 - (_main_w / 2);
var _left_x   = _center_x - _gap - _side_w;
var _right_x  = _center_x + _main_w + _gap;

if (gui_state == "MOVING") {
    // --- MOVEMENT PROGRESS BOX ---
    var _box_w = 400;
    var _box_h = 100;
    var _box_x = room_width / 2 - (_box_w / 2);
    var _box_y = _mid_y - (_box_h / 2);
    
    draw_sprite_stretched(spr_dice_container, 0, _box_x, _box_y, _box_w, _box_h);
    
    if (instance_exists(obj_board)) {
        draw_set_font(fnt_gui_button_large);
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        var _step_str = "Remaining: " + string(obj_board.steps_remaining);
        
        // Shadow
        draw_set_color(c_black); draw_set_alpha(0.4);
        draw_text(_box_x + _box_w/2 + 4, _box_y + _box_h/2 - 6 + 5, _step_str); 
        // Main
        draw_set_color(c_white); draw_set_alpha(1.0);
        draw_text(_box_x + _box_w/2, _box_y + _box_h/2 - 6, _step_str);
    }
} else {
    if (draw_gui_button(_left_x, _main_y + stagger_btn_left, _side_w, _side_h, spr_button_red, "Inventory", c_white, fnt_gui_button_medium, can_interact_gui)) {
        gui_state = "PROPERTY";
    }

    var _roll_y = _main_y + stagger_btn_center;
    if (draw_gui_button(_center_x, _roll_y, _main_w, _main_h, spr_button_main, "", c_white, fnt_gui_button_medium, can_interact_gui)) {
        if (gui_state == "MAIN") {
            gui_state = "DICE";
            dice_phase = "ENTERING";
            dice_timer = 0;
            dice_pop_y = 1000;    
            dice_can_exit = false;
            randomize();          
        }
    }

    // Waving Text for Roll Button
    var _wave_str = "Roll The Dice!";
    var _wave_len = string_length(_wave_str);
    draw_set_font(fnt_gui_button_medium);
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _roll_hover = can_interact_gui && point_in_rectangle(_mx, _my, _center_x, _roll_y, _center_x + _main_w, _roll_y + _main_h);
    var _roll_press = can_interact_gui && _roll_hover && mouse_check_button(mb_left);
    var _juice_y = 0;
    if (_roll_hover && !_roll_press) _juice_y = -6;
    if (_roll_press) _juice_y = 2;
    var _total_w = string_width(_wave_str);
    var _start_x = _center_x + (_main_w / 2) - (_total_w / 2);
    var _face_h = _main_h - 16 + ((_roll_press) ? -2 : 0); 
    var _base_y = _roll_y + _juice_y + (_face_h / 2);

    var _cx = _start_x;
    for (var i = 0; i < _wave_len; i++) {
        var _ch = string_char_at(_wave_str, i + 1);
        var _ch_w = string_width(_ch);
        var _wave_y = sin((current_time / 1000 * 4.0) + (i * 0.4)) * 3.0;
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_color(c_black); draw_set_alpha(0.3);
        draw_text(_cx + 3, _base_y + _wave_y + 4, _ch);
        draw_set_color(c_white); draw_set_alpha(1.0);
        draw_text(_cx, _base_y + _wave_y, _ch);
        _cx += _ch_w;
    }
    draw_set_halign(fa_left); draw_set_valign(fa_top);

    draw_gui_button(_right_x, _main_y + stagger_btn_right, _side_w, _side_h, spr_button_blue, "Shop", c_white, fnt_gui_button_medium, can_interact_gui);
}



// ─── PROPERTY OVERLAY PANEL (Drawn LAST so it can dim everything else) ───

// Configure slot rules based on pawn data 
var _fate_max = 6;
var _prop_max = 12;
var _fate_filled = 2;
var _prop_filled = 5;

// Cards Scaling & Sizing
var _card_spr = spr_card_placeholder;
var _card_scale = 0.74; 
var _card_w = sprite_get_width(_card_spr) * _card_scale;
var _card_h = sprite_get_height(_card_spr) * _card_scale;
var _card_gap = 16;
var _columns = clamp(max(_fate_max, _prop_max), 5, 6);
var _total_cards_w = (_card_w * _columns) + (_card_gap * max(0, _columns - 1));

// Panel Dimensions
var _prop_panel_w = _total_cards_w + 100; 
var _prop_panel_h = room_height * 0.7; 
var _prop_panel_x = room_width / 2 - (_prop_panel_w / 2);
var _submerged_amt = 150; 
var _prop_target_y = room_height - _prop_panel_h + _submerged_amt; 
var _prop_panel_y = _prop_target_y + property_y_offset;

// Render only if the panel is on screen
if (property_y_offset < 790) {
    // --- JUICY OVERLAY BACKGROUND ---
    // This now covers the interactive buttons as well
    var _overlay_alpha = lerp(0.4, 0, clamp(property_y_offset / 800, 0, 1));
    draw_set_color(c_black);
    draw_set_alpha(_overlay_alpha);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_color(c_white);
    draw_set_alpha(1.0);
    
    // Draw Panel Base
    draw_sprite_stretched(spr_gui_bottom_container, 0, _prop_panel_x, _prop_panel_y, _prop_panel_w, _prop_panel_h);
    
    // Draw Close Button (Top Right)
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
        if (mouse_check_button_pressed(mb_left)) is_dragging_panel = false;
        if (mouse_check_button_released(mb_left)) gui_state = "MAIN";
    }
    
    var _draw_scale = _close_scale;
    var _draw_x = _close_x;
    var _draw_y = _close_y;
    if (_close_pressed) {
        _draw_scale = _close_scale * 0.9;
        var _shrink_w = _close_w - (sprite_get_width(spr_panel_close) * _draw_scale);
        var _shrink_h = _close_h - (sprite_get_height(spr_panel_close) * _draw_scale);
        _draw_x += _shrink_w / 2;
        _draw_y += _shrink_h / 2;
    }
    
    draw_sprite_ext(spr_panel_close, 0, _draw_x, _draw_y, _draw_scale, _draw_scale, 0, c_white, 1);
    if (_close_hover && !_close_pressed) {
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(spr_panel_close, 0, _draw_x, _draw_y, _draw_scale, _draw_scale, 0, c_white, 0.25);
        gpu_set_blendmode(bm_normal);
    }
    
    // ─── Scrollable Surface Architecture ───
    var _inner_w = _total_cards_w;
    var _inner_h = _prop_panel_h - _submerged_amt - 100; 
    var _inner_x = _prop_panel_x + 50; 
    var _inner_y = _prop_panel_y + 50; 
    
    if (_inner_w > 0 && _inner_h > 0) {
        if (!surface_exists(surf_panel)) {
            surf_panel = surface_create(_inner_w, _inner_h);
        } else if (surface_get_width(surf_panel) != _inner_w || surface_get_height(surf_panel) != _inner_h) {
            surface_free(surf_panel);
            surf_panel = surface_create(_inner_w, _inner_h);
        }
        
        surface_set_target(surf_panel);
        draw_clear_alpha(c_black, 0);
        
        var _draw_cursor_y = -panel_scroll_y; 
        draw_set_font(fnt_main);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        var _text_x = _inner_w / 2;
        var _origin_x = sprite_get_xoffset(_card_spr) * _card_scale;
        var _origin_y = sprite_get_yoffset(_card_spr) * _card_scale;
        
        _draw_cursor_y += 15; 
        var _fate_str = "Fate Cards (" + string(_fate_filled) + "/" + string(_fate_max) + ")";
        draw_set_color(c_black); draw_set_alpha(0.3); draw_text(_text_x + 2, _draw_cursor_y + 3, _fate_str);
        draw_set_color(c_white); draw_set_alpha(1.0); draw_text(_text_x, _draw_cursor_y, _fate_str);
        _draw_cursor_y += 25 + _origin_y; 
        
        for (var i = 0; i < _fate_max; i++) {
            var _col = i mod _columns;
            var _row = i div _columns;
            var _cx = (_col * (_card_w + _card_gap)) + _origin_x;
            var _cy = _draw_cursor_y + (_row * (_card_h + _card_gap));
            draw_sprite_ext(_card_spr, 0, _cx, _cy, _card_scale, _card_scale, 0, c_white, 1);
        }
        
        var _fate_rows = ceil(_fate_max / _columns);
        _draw_cursor_y += (_fate_rows * (_card_h + _card_gap)) - _origin_y;
        
        _draw_cursor_y += 20; 
        var _prop_str = "Properties (" + string(_prop_filled) + "/" + string(_prop_max) + ")";
        draw_set_color(c_black); draw_set_alpha(0.3); draw_text(_text_x + 2, _draw_cursor_y + 3, _prop_str);
        draw_set_color(c_white); draw_set_alpha(1.0); draw_text(_text_x, _draw_cursor_y, _prop_str);
        _draw_cursor_y += 25 + _origin_y; 
        
        for (var i = 0; i < _prop_max; i++) {
            var _col = i mod _columns;
            var _row = i div _columns;
            var _cx = (_col * (_card_w + _card_gap)) + _origin_x;
            var _cy = _draw_cursor_y + (_row * (_card_h + _card_gap));
            draw_sprite_ext(_card_spr, 0, _cx, _cy, _card_scale, _card_scale, 0, c_white, 1);
        }
        
        var _prop_rows = ceil(_prop_max / _columns);
        _draw_cursor_y += (_prop_rows * (_card_h + _card_gap)) - _origin_y;
        _draw_cursor_y += 15; 
        
        surface_reset_target();
        draw_surface(surf_panel, _inner_x, _inner_y);
        
        var _total_content_height = (_draw_cursor_y + panel_scroll_y); 
        if (_total_content_height > _inner_h) {
            panel_max_scroll = _total_content_height - _inner_h;
        } else {
            panel_max_scroll = 0;
        }
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }
}

// ─── DICE ROLL POPUP RENDERING ───
// Skip this block once the confirm animation takes over (confirm_phase handles drawing)
if ((gui_state == "DICE" || dice_pop_y < 990) && confirm_phase == 0) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    // 1. Dark Overlay (Fades in with the popup position)
    var _dice_overlay_alpha = lerp(0, 0.4, clamp(1.0 - (dice_pop_y / 1000), 0, 1));
    draw_set_color(c_black);
    draw_set_alpha(_dice_overlay_alpha);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1.0);
    
    // 2. Calculating Dynamic Dimensions
    var _dice_scale = 0.55; // Slightly smaller to look even sharper
    var _margin = 40; // More breathing room
    var _gap = 30; // More space between dice

    
    var _dw = sprite_get_width(spr_dice) * _dice_scale;
    var _dh = sprite_get_height(spr_dice) * _dice_scale;
    
    // Height expands dynamically based on dice_panel_h_extra
    var _total_w = (3 * _dw) + (2 * _gap) + (2 * _margin);
    var _total_h = _dh + (2 * _margin) + dice_panel_h_extra; 
    
    // 3. Popup Centering
    var _popup_x = (_gui_w / 2) - (_total_w / 2);
    var _popup_y = (_gui_h / 2) - (_total_h / 2) + dice_pop_y;
    
    // Draw Dynamic Container (9-slice handling)
    draw_sprite_stretched(spr_dice_container, 0, _popup_x, _popup_y, _total_w, _total_h);
    
    // 4. Dice Rendering (Corrected for Top-Left Origin)
    var _is_rolling = (dice_phase == "ROLLING");
    var _shake_mag = _is_rolling ? 6 : 0;
    var _dice_y_slot = _popup_y + _margin;
    var _sel_count = dice_selected[0] + dice_selected[1] + dice_selected[2];
    
    for (var i = 0; i < 3; i++) {
        var _dice_x_slot = _popup_x + _margin + (i * (_dw + _gap));
        
        // Use animated Y offset (lift)
        var _dx = _dice_x_slot;
        var _dy = _dice_y_slot + dice_select_y[i];
        
        // Apply Shake Jitter (only during ROLLING)
        if (_shake_mag > 0) {
            _dx += random_range(-_shake_mag, _shake_mag);
            _dy += random_range(-_shake_mag, _shake_mag);
        }
        
        // --- SELECTION OUTLINE (Behind the die) ---
        if (dice_selected[i] && dice_phase == "FINISHED") {
            var _out = 4; // Outline thickness
            gpu_set_fog(true, c_gold, 0, 0); // Force pure gold color
            draw_sprite_ext(spr_dice, dice_values[i], _dx - _out, _dy, _dice_scale, _dice_scale, 0, c_white, 1);
            draw_sprite_ext(spr_dice, dice_values[i], _dx + _out, _dy, _dice_scale, _dice_scale, 0, c_white, 1);
            draw_sprite_ext(spr_dice, dice_values[i], _dx, _dy - _out, _dice_scale, _dice_scale, 0, c_white, 1);
            draw_sprite_ext(spr_dice, dice_values[i], _dx, _dy + _out, _dice_scale, _dice_scale, 0, c_white, 1);
            draw_sprite_ext(spr_dice, dice_values[i], _dx - _out, _dy - _out, _dice_scale, _dice_scale, 0, c_white, 1);
            draw_sprite_ext(spr_dice, dice_values[i], _dx + _out, _dy - _out, _dice_scale, _dice_scale, 0, c_white, 1);
            draw_sprite_ext(spr_dice, dice_values[i], _dx - _out, _dy + _out, _dice_scale, _dice_scale, 0, c_white, 1);
            draw_sprite_ext(spr_dice, dice_values[i], _dx + _out, _dy + _out, _dice_scale, _dice_scale, 0, c_white, 1);
            gpu_set_fog(false, c_white, 0, 0); // Turn off fog
        }

        // --- DRAW DIE FACE ---
        var _die_alpha = 1.0;
        if (dice_phase == "FINISHED" && _sel_count == 2 && !dice_selected[i]) {
            _die_alpha = 0.7; // Dim the unselected die to focus on the selections
        }
        draw_sprite_ext(spr_dice, dice_values[i], _dx, _dy, _dice_scale, _dice_scale, 0, c_white, _die_alpha);
        
        // --- NUMERIC INDICATOR (Above Die) ---
        if (dice_phase == "FINISHED" && dice_selected[i]) {
            draw_set_font(fnt_gui_button_large); // Use larger font for visibility
            draw_set_halign(fa_center);
            
            var _num_x = _dx + (_dw / 2);
            var _num_y = _dy - 70; // Push even higher to be strictly above the die
            var _num_str = string(dice_values[i] + 1);
            
            // 1. Drop shadow (Background drop)
            draw_set_color(c_black); draw_set_alpha(0.5);
            draw_text(_num_x + 5, _num_y + 6, _num_str);
            draw_set_alpha(1.0);
            
            // 2. Thick Black Outline
            draw_set_color(c_black);
            draw_text(_num_x - 3, _num_y, _num_str);
            draw_text(_num_x + 3, _num_y, _num_str);
            draw_text(_num_x, _num_y - 3, _num_str);
            draw_text(_num_x, _num_y + 3, _num_str);
            draw_text(_num_x - 3, _num_y - 3, _num_str);
            draw_text(_num_x + 3, _num_y - 3, _num_str);
            draw_text(_num_x - 3, _num_y + 3, _num_str);
            draw_text(_num_x + 3, _num_y + 3, _num_str);
            
            // 3. Main Gold Text (Foreground)
            draw_set_color(c_gold);
            draw_text(_num_x, _num_y, _num_str);
        }
        
        // --- INTERACTION (Clicking the Die) ---
        if (dice_phase == "FINISHED") {
            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);
            if (point_in_rectangle(_mx, _my, _dx, _dy, _dx + _dw, _dy + _dh)) {
                if (mouse_check_button_pressed(mb_left)) {
                    if (dice_selected[i]) {
                        dice_selected[i] = false;
                    } else if (_sel_count < 2) {
                        dice_selected[i] = true;
                    }
                }
            }
        }
    }
    
    // 5. Instructional Text & Confirm Button (only when roll is done)
    if (dice_phase == "FINISHED") {
        var _sel_count = dice_selected[0] + dice_selected[1] + dice_selected[2];
        
        draw_set_font(fnt_main);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        if (_sel_count < 2) {
            draw_set_font(fnt_gui_button_medium); // Slightly larger font
            var _osc_alpha = abs(sin(current_time/300));
            var _inst_x = _gui_w / 2;
            var _inst_y = _popup_y + _total_h + 25; // Adjusted Y for larger font
            
            // 1. Drop Shadow
            draw_set_color(c_black);
            draw_set_alpha(_osc_alpha * 0.7);
            draw_text(_inst_x + 3, _inst_y + 4, "Select 2 Dice to Keep");
            
            // 2. Main Gold Text
            draw_set_color(c_gold);
            draw_set_alpha(_osc_alpha);
            draw_text(_inst_x, _inst_y, "Select 2 Dice to Keep");
            
            draw_set_alpha(1.0);
        } else if (dice_panel_h_extra > 50) {
            // CONFIRM BUTTON shows up as panel expands
            var _ui_alpha = clamp((dice_panel_h_extra - 50) / 70, 0, 1);
            draw_set_alpha(_ui_alpha);
            
            // SHOW CONFIRM BUTTON (Centered at bottom of expanded panel)
            var _conf_w = 260;
            var _conf_h = 80; // Further increased height for better text padding
            var _conf_x = (_gui_w / 2) - (_conf_w / 2);
            var _conf_y = _popup_y + _total_h - 125; // Shifted higher 
            
            // Prevent misclicks by only enabling interaction when fully expanded
            var _is_ready = (_ui_alpha > 0.95);
            
            if (draw_gui_button(_conf_x, _conf_y, _conf_w, _conf_h, spr_button_main, "Confirm Selection", c_white, fnt_gui_button_medium, _is_ready)) {
                var _fly_ptr = 0;
                dice_total = 0;
                confirm_unsel_idx = -1;
                
                // ─── Compute hover targets: 2 dice centered horizontally, above panel ───
                var _hover_gap    = 20; // gap between the 2 hovering dice
                var _hover_pair_w = (2 * _dw) + _hover_gap;
                var _hover_left_x = (_gui_w / 2) - (_hover_pair_w / 2); // X of left die
                var _hover_y      = _popup_y - 80; // just above panel container top
                
                for (var k = 0; k < 3; k++) {
                    if (dice_selected[k]) {
                        var _die_x = _popup_x + _margin + (k * (_dw + _gap));
                        var _die_y = _dice_y_slot + dice_select_y[k];
                        confirm_fly_values[_fly_ptr]  = dice_values[k];
                        // Where die IS right now (init of float-up)
                        confirm_dice_init_x[_fly_ptr] = _die_x;
                        confirm_dice_init_y[_fly_ptr] = _die_y;
                        // Where it hovers TO: centered, above panel
                        confirm_fly_start_x[_fly_ptr] = _hover_left_x + (_fly_ptr * (_dw + _hover_gap));
                        confirm_fly_start_y[_fly_ptr] = _hover_y;
                        dice_total += (dice_values[k] + 1);
                        _fly_ptr++;
                    } else {
                        confirm_unsel_idx = k;
                    }
                }

                
                // Kick off phase 1
                confirm_phase       = 1;
                confirm_hover_frame = 0;
                confirm_panel_frame = 0;
                confirm_panel_y_bonus = 0;
                confirm_panel_alpha   = 1.0;
                dice_can_exit = false;
                dice_phase = "IDLE";
                
                // ─── EXPLODING SPRITE: push chunks into dice_particles array ───
                if (confirm_unsel_idx != -1) {
                    var _ex_gui_x = _popup_x + _margin + (confirm_unsel_idx * (_dw + _gap));
                    var _ex_gui_y = _dice_y_slot;
                    var _ex_spr   = spr_dice;
                    var _ex_sub   = dice_values[confirm_unsel_idx];
                    var _ex_ww    = sprite_get_width(_ex_spr);
                    var _ex_hh    = sprite_get_height(_ex_spr);
                    var _chunk    = 8;
                    for (var _pi = 0; _pi < _ex_ww; _pi += _chunk) {
                        for (var _pj = 0; _pj < _ex_hh; _pj += _chunk) {
                            var _life = irandom_range(25, 45);
                            array_push(dice_particles, {
                                spr     : _ex_spr,
                                sub_img : _ex_sub,
                                chunk_xx: _pi,
                                chunk_yy: _pj,
                                chunk_sz: _chunk,
                                gui_x   : _ex_gui_x + (_pi * _dice_scale),
                                gui_y   : _ex_gui_y + (_pj * _dice_scale),
                                vel_x   : random_range(-5, 5),
                                vel_y   : random_range(-7, -1),
                                gravity : 0.25,
                                life    : _life,
                                life_max: _life,
                            });
                        }
                    }
                }
            }


            draw_set_alpha(1.0);
        }

        // 6. Auxiliary Side Buttons (Action Menu)
        var _side_w = 160; // Base width
        var _side_h = 60;  // Taller height so it's less elongated ("lonjong")
        var _side_gap = 16; // Gap between buttons
        
        // --- LEFT SIDE BUTTONS ---
        var _side_left_x = _popup_x - _side_w - 20; // 20px padding from left side of container
        var _side_left_y = _popup_y + ((_dh + (2 * _margin)) / 2) - (_side_h / 2); // Center a single button vertically
        
        if (draw_gui_button(_side_left_x, _side_left_y, _side_w, _side_h, spr_button_main, "View Map", c_white, fnt_main)) {
            show_debug_message("Action: View Map");
        }
        
        // --- RIGHT SIDE BUTTONS ---
        var _side_right_total_h = (2 * _side_h) + _side_gap;
        var _side_right_x = _popup_x + _total_w + 20; // 20px padding from right side of container
        var _side_right_y = _popup_y + ((_dh + (2 * _margin)) / 2) - (_side_right_total_h / 2); // Center 2 buttons vertically
        
        if (draw_gui_button(_side_right_x, _side_right_y, _side_w, _side_h, spr_button_red, "Re Roll", c_white, fnt_main)) {
            // TODO: Charge a resource cost before executing roll
            dice_phase = "ROLLING";
            dice_timer = irandom_range(40, 60);
            dice_selected[0] = false;
            dice_selected[1] = false;
            dice_selected[2] = false;
            dice_panel_h_extra = 0; // Reset panel expansion immediately
        }
        
        if (draw_gui_button(_side_right_x, _side_right_y + _side_h + _side_gap, _side_w, _side_h, spr_button_blue, "Use Fate Card", c_white, fnt_main)) {
            show_debug_message("Action: Use Fate Card");
        }
    }
}


// ─── CONFIRM ANIMATION OVERLAY (draws on top of everything else) ───
if (confirm_phase >= 1) {
    var _ca_margin  = 40;
    var _ca_gap     = 30;
    var _ca_scale   = 0.55;
    var _ca_dw      = sprite_get_width(spr_dice) * _ca_scale;
    var _ca_total_w = (3 * _ca_dw) + (2 * _ca_gap) + (2 * _ca_margin);
    var _ca_total_h = sprite_get_height(spr_dice) * _ca_scale + (2 * _ca_margin);
    var _ca_popup_x = (_gui_w / 2) - (_ca_total_w / 2);
    var _ca_base_py = (_gui_h / 2) - (_ca_total_h / 2);

    // Helper: draw a die with full gold outline (4px, 8-directional) + number label above
    var _draw_dice_gold = function(_spr, _sub, _x, _y, _sc, _alpha) {
        // NOTE: _ca_dw_inner computed here — GML closures can't capture outer locals
        var _dw_inner = sprite_get_width(_spr) * _sc;
        // Gold outline — 8-directional, 4px thick
        var _out = 4;
        gpu_set_fog(true, c_gold, 0, 0);
        draw_sprite_ext(_spr, _sub, _x - _out, _y,        _sc, _sc, 0, c_white, _alpha);
        draw_sprite_ext(_spr, _sub, _x + _out, _y,        _sc, _sc, 0, c_white, _alpha);
        draw_sprite_ext(_spr, _sub, _x,        _y - _out, _sc, _sc, 0, c_white, _alpha);
        draw_sprite_ext(_spr, _sub, _x,        _y + _out, _sc, _sc, 0, c_white, _alpha);
        draw_sprite_ext(_spr, _sub, _x - _out, _y - _out, _sc, _sc, 0, c_white, _alpha);
        draw_sprite_ext(_spr, _sub, _x + _out, _y - _out, _sc, _sc, 0, c_white, _alpha);
        draw_sprite_ext(_spr, _sub, _x - _out, _y + _out, _sc, _sc, 0, c_white, _alpha);
        draw_sprite_ext(_spr, _sub, _x + _out, _y + _out, _sc, _sc, 0, c_white, _alpha);
        gpu_set_fog(false, c_white, 0, 0);
        // Die face
        draw_sprite_ext(_spr, _sub, _x, _y, _sc, _sc, 0, c_white, _alpha);
        
        // Number label above the die
        var _num_str = string(_sub + 1);
        var _num_x   = _x + (_dw_inner / 2);
        var _num_y   = _y - 66;
        draw_set_font(fnt_gui_button_large);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        // Drop shadow
        draw_set_color(c_black); draw_set_alpha(_alpha * 0.5);
        draw_text(_num_x + 5, _num_y + 6, _num_str);
        draw_set_alpha(_alpha);
        // Black outline
        draw_set_color(c_black);
        draw_text(_num_x - 3, _num_y,     _num_str); draw_text(_num_x + 3, _num_y,     _num_str);
        draw_text(_num_x,     _num_y - 3, _num_str); draw_text(_num_x,     _num_y + 3, _num_str);
        draw_text(_num_x - 3, _num_y - 3, _num_str); draw_text(_num_x + 3, _num_y - 3, _num_str);
        draw_text(_num_x - 3, _num_y + 3, _num_str); draw_text(_num_x + 3, _num_y + 3, _num_str);
        // Gold text
        draw_set_color(c_gold);
        draw_text(_num_x, _num_y, _num_str);
        draw_set_alpha(1.0);
        draw_set_color(c_white);
        draw_set_halign(fa_left);
    };


    // ─── PHASE 1: Explosion hold — dice sit still, particles burst (8 frames) ───
    if (confirm_phase == 1) {
        draw_sprite_stretched(spr_dice_container, 0, _ca_popup_x, _ca_base_py, _ca_total_w, _ca_total_h);
        for (var f = 0; f < 2; f++) {
            _draw_dice_gold(spr_dice, confirm_fly_values[f], confirm_dice_init_x[f], confirm_dice_init_y[f], _ca_scale, 1.0);
        }
    }

    // ─── PHASE 2: Float-up — dice ease toward center-above-panel (12 frames) ───
    if (confirm_phase == 2) {
        draw_sprite_stretched(spr_dice_container, 0, _ca_popup_x, _ca_base_py, _ca_total_w, _ca_total_h);
        var _t2 = clamp(confirm_hover_frame / 12, 0, 1);
        var _t2e = 1.0 - power(1.0 - _t2, 3.0); // ease-out cubic
        for (var f = 0; f < 2; f++) {
            var _dx = lerp(confirm_dice_init_x[f], confirm_fly_start_x[f], _t2e);
            var _dy = lerp(confirm_dice_init_y[f], confirm_fly_start_y[f], _t2e);
            _draw_dice_gold(spr_dice, confirm_fly_values[f], _dx, _dy, _ca_scale, 1.0);
        }
    }

    // ─── PHASE 3: Panel slides out — dice hover at center with gentle bob ───
    if (confirm_phase == 3) {
        var _panel_y = _ca_base_py + confirm_panel_y_bonus;
        draw_set_alpha(confirm_panel_alpha);
        draw_sprite_stretched(spr_dice_container, 0, _ca_popup_x, _panel_y, _ca_total_w, _ca_total_h);
        draw_set_alpha(1.0);
        var _bob = sin(current_time / 280) * 5;
        for (var f = 0; f < 2; f++) {
            _draw_dice_gold(spr_dice, confirm_fly_values[f], confirm_fly_start_x[f], confirm_fly_start_y[f] + _bob, _ca_scale, 1.0);
        }
    }

    // ─── PHASE 4: Fly to pawn — arc trajectory, scale pulse, only fades near landing ───
    if (confirm_phase == 4 && instance_exists(obj_pawn)) {
        var _pawn_rx = obj_pawn.x;
        var _pawn_ry = obj_pawn.y + obj_pawn.y_offset;
        var _vx      = camera_get_view_x(view_camera[0]);
        var _vy      = camera_get_view_y(view_camera[0]);
        var _pawn_gx = _pawn_rx - _vx;
        var _pawn_gy = _pawn_ry - _vy;

        var _ft    = clamp(confirm_fly_frame / 30, 0, 1);
        var _tease = _ft < 0.5 ? 2 * _ft * _ft : 1.0 - power(-2.0 * _ft + 2.0, 2.0) / 2.0;

        // Fade only in last 25% of travel
        var _fly_alpha = (_ft > 0.75) ? lerp(1.0, 0.0, (_ft - 0.75) / 0.25) : 1.0;

        // Scale: pop up at start, shrink toward landing
        var _fly_scale = _ca_scale * (1.0 + sin(_ft * pi) * 0.35);

        for (var f = 0; f < 2; f++) {
            var _fx = lerp(confirm_fly_start_x[f], _pawn_gx, _tease);
            var _fy = lerp(confirm_fly_start_y[f], _pawn_gy, _tease);

            // Subtle arc upward, then down
            _fy -= sin(_ft * pi) * 60;

            var _frot = _ft * 20; // very slight tilt
            draw_sprite_ext(spr_dice, confirm_fly_values[f], _fx, _fy, _fly_scale, _fly_scale, _frot, c_white, _fly_alpha);
        }
    }

    draw_set_alpha(1.0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ─── STATS POPUP OVERLAY (Pawn characteristics) ───
if (stats_popup_alpha > 0) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    // Dim background
    draw_set_color(c_black);
    draw_set_alpha(stats_popup_alpha * 0.6);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    
    // Panel setup - Slide offset applied here
    var _p_w = 720;
    var _p_h = 580;
    var _p_x = (_gui_w / 2) - (_p_w / 2);
    var _p_y = (_gui_h / 2) - (_p_h / 2) + stats_popup_y_slide;
    
    draw_set_alpha(stats_popup_alpha);
    draw_sprite_stretched(spr_dice_container, 0, _p_x, _p_y, _p_w, _p_h);
    
    // Title
    draw_set_font(fnt_gui_button_large);
    draw_set_halign(fa_center); draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text(_p_x + _p_w/2, _p_y + 35, "Pawn Statistics");
    
    // Stats Rows
    var _row_y_start = _p_y + 130;
    var _row_gap     = 65;
    var _bar_w       = 380;
    var _bar_h       = 44;
    var _bar_x       = _p_x + 130;
    
    for (var i = 0; i < array_length(global.stat_data); i++) {
        var _s = global.stat_data[i];
        var _cy = _row_y_start + (i * _row_gap);
        
        // 1. Icon
        draw_sprite_ext(spr_stats, _s.icon, _p_x + 50, _cy - 10, 1, 1, 0, c_white, stats_popup_alpha);
        
        // 2. Bar Placeholder (Use spr_target_bar)
        draw_set_color(c_white); draw_set_alpha(stats_popup_alpha);
        draw_sprite_stretched(spr_target_bar, 0, _bar_x, _cy, _bar_w, _bar_h);
        
        // 3. Current Value
        var _val = 5;
        if (instance_exists(obj_controller)) {
            var _key = string_replace_all(string_lower(_s.name), " ", "_");
            _val = variable_struct_get(obj_controller.stats, _key);
        }
        
        // 4. Bar Fill (Adjusted to stay inside spr_target_bar borders)
        var _inner_pad_x = 12;
        var _inner_pad_y = 16;
        var _fill_max_w = _bar_w - (_inner_pad_x * 2);
        var _fw = (_val / 10) * _fill_max_w;
        if (_fw > 0) {
            draw_set_color(_s.color);
            // Shifted up by 2px to be perfectly centered on the spr_target_bar track
            var _yo = -4;
            draw_rectangle(_bar_x + _inner_pad_x, _cy + _inner_pad_y + _yo, _bar_x + _inner_pad_x + _fw, _cy + _bar_h - _inner_pad_y + _yo, false);
        }
        
        // 5. Value Text
        draw_set_font(fnt_main);
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(_bar_x + _bar_w + 30, _cy + (_bar_h/2), string(_val) + " / 10");
    }
    
    // Close Button ("X") - Crossed atop the corner
    var _cx_sz = 64;
    var _cx_x  = _p_x + _p_w - 5; // Slight overlap to the right
    var _cx_y  = _p_y + 5;         // Slight overlap to the top
    
    if (draw_gui_button(_cx_x - _cx_sz/2, _cx_y - _cx_sz/2, _cx_sz, _cx_sz, spr_panel_close, "", c_white, fnt_main, true)) {
        stats_popup_open = false;
    }
    
    draw_set_alpha(1.0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
if (shader_is_compiled(shd_game_fx)) {
    gpu_set_blendmode(bm_normal);
    shader_set(shd_game_fx);
    var _u_res = shader_get_uniform(shd_game_fx, "u_resolution");
    var _u_vig = shader_get_uniform(shd_game_fx, "u_vignette_mix");
    var _u_scn = shader_get_uniform(shd_game_fx, "u_scanline_mix");
    
    shader_set_uniform_f(_u_res, display_get_gui_width(), display_get_gui_height());
    shader_set_uniform_f(_u_vig, 0.0); // No Vignette (already applied to BG)
    shader_set_uniform_f(_u_scn, 1.0); // Apply Scanlines
    
    draw_rectangle_color(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, false);
    shader_reset();
}

// ─── JUICE EFFECTS (Screen Flash) ───
if (dice_flash_alpha > 0) {
    draw_set_color(c_white);
    draw_set_alpha(dice_flash_alpha);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1.0);
}

// ─── DICE EXPLOSION PARTICLES (drawn LAST — always on top of everything) ───
var _pcount = array_length(dice_particles);
if (_pcount > 0) {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    for (var _i = 0; _i < _pcount; _i++) {
        var _p = dice_particles[_i];
        var _alpha = clamp(_p.life / _p.life_max, 0, 1);
        draw_set_alpha(_alpha);
        // draw_sprite_part draws at 1:1 scale — we compensate by using chunk_sc to scale the output
        draw_sprite_part(_p.spr, _p.sub_img, _p.chunk_xx, _p.chunk_yy, _p.chunk_sz, _p.chunk_sz, _p.gui_x, _p.gui_y);
    }
    draw_set_alpha(1.0);
}
