// Determine target offsets based on state
target_bottom_offset = (gui_state == "MAIN") ? 0 : 300; // Slide main UI down if not in main state
var _target_prop_offset = (gui_state == "PROPERTY") ? 0 : 800; // Slide prop UI up if active

// Smoothly animate the main panel
if (abs(bottom_y_offset - target_bottom_offset) > 0.5) {
    bottom_y_offset = lerp(bottom_y_offset, target_bottom_offset, animation_speed);
} else {
    bottom_y_offset = target_bottom_offset;
}

// ─── INTRO STAGGER ANIMATION ───
intro_timer += 1;
var _spd = 0.10; // Smooth lerp speed for stagger elements

// Top bar slide-in
if (intro_timer > 5) {
    top_y_offset = lerp(top_y_offset, top_y_target, _spd);
    if (abs(top_y_offset - top_y_target) < 0.5) top_y_offset = top_y_target;
}

// Staggered top bar elements (each waits a bit longer)
if (intro_timer > 15) { stagger_option    = lerp(stagger_option,    0, _spd); }
if (intro_timer > 25) { stagger_target_bar = lerp(stagger_target_bar, 0, _spd); }
if (intro_timer > 30) { stagger_cash       = lerp(stagger_cash,       0, _spd); }
if (intro_timer > 35) { stagger_map_stat   = lerp(stagger_map_stat,   0, _spd); }

// Staggered bottom panel elements
if (intro_timer > 20) { stagger_turn_badge = lerp(stagger_turn_badge, 0, _spd); }
if (intro_timer > 30) { stagger_btn_center = lerp(stagger_btn_center, 0, _spd); }
if (intro_timer > 35) { stagger_btn_left   = lerp(stagger_btn_left,   0, _spd); }
if (intro_timer > 38) { stagger_btn_right  = lerp(stagger_btn_right,  0, _spd); }

// Snap small values to 0
if (abs(stagger_option) < 0.5) stagger_option = 0;
if (abs(stagger_target_bar) < 0.5) stagger_target_bar = 0;
if (abs(stagger_cash) < 0.5) stagger_cash = 0;
if (abs(stagger_map_stat) < 0.5) stagger_map_stat = 0;
if (abs(stagger_turn_badge) < 0.5) stagger_turn_badge = 0;
if (abs(stagger_btn_center) < 0.5) stagger_btn_center = 0;
if (abs(stagger_btn_left) < 0.5) stagger_btn_left = 0;
if (abs(stagger_btn_right) < 0.5) stagger_btn_right = 0;

// Smoothly animate the property panel
if (abs(property_y_offset - _target_prop_offset) > 0.5) {
    property_y_offset = lerp(property_y_offset, _target_prop_offset, animation_speed);
} else {
    property_y_offset = _target_prop_offset;
}

// Property Panel Scrolling Interactivity
if (gui_state == "PROPERTY" && property_y_offset < 790) {
    var _scroll_speed = 65; // Scroll speed sensitivity per notch
    
    if (mouse_wheel_up()) panel_scroll_target -= _scroll_speed;
    if (mouse_wheel_down()) panel_scroll_target += _scroll_speed;
    
    // --- Mobile Touch/Drag Scrolling ---
    var _my = device_mouse_y_to_gui(0);
    var _panel_actual_y = _target_prop_offset + (room_height - (room_height * 0.6) + 50);
    
    if (mouse_check_button_pressed(mb_left) && _my > _panel_actual_y) {
        is_dragging_panel = true;
        drag_start_y = _my;
        scroll_start = panel_scroll_target;
    }
    
    if (is_dragging_panel) {
        if (mouse_check_button(mb_left)) {
            // Drag smoothly based on delta
            panel_scroll_target = scroll_start + (drag_start_y - _my);
        } else {
            is_dragging_panel = false;
        }
    }
    
    // Clamp so we can't scroll past the bounds
    panel_scroll_target = clamp(panel_scroll_target, 0, panel_max_scroll);
    
    // Rubber-band smooth scrolling
    panel_scroll_y = lerp(panel_scroll_y, panel_scroll_target, 0.2);
} else {
    // Reset when hidden
    panel_scroll_target = 0;
    panel_scroll_y = 0;
    is_dragging_panel = false;
}
