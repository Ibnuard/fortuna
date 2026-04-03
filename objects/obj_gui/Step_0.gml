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

// ─── DICE ROLL POPUP LOGIC ───
var _dice_target_y = (gui_state == "DICE") ? 0 : 1000;
dice_pop_y = lerp(dice_pop_y, _dice_target_y, animation_speed);

if (gui_state == "DICE") {
    switch (dice_phase) {
        case "ENTERING":
            // Reset selection state and panel height when roll starts
            for (var k = 0; k < 3; k++) {
                dice_selected[k] = false;
                dice_select_y[k] = 0;
            }
            dice_panel_h_extra = 0;
            
            // Wait for popup to nearly reach the target center
            if (abs(dice_pop_y) < 5) {
                dice_pop_y = 0;
                dice_phase = "PAUSE";
                dice_timer = 20; // 0.3s pause before rolling
            }
            break;
            
        case "PAUSE":
            if (dice_timer > 0) {
                dice_timer--;
            } else {
                dice_phase = "ROLLING";
                dice_timer = 60; // 1s shuffle duration
            }
            break;
            
        case "ROLLING":
            if (dice_timer > 0) {
                dice_timer--;
                // Randomize dice faces (0-5) while shaking
                for (var i = 0; i < 3; i++) {
                    dice_values[i] = irandom_range(0, 5);
                }
            } else {
                dice_phase = "FINISHED";
                dice_can_exit = true; 
                dice_flash_alpha = 0.8; // Trigger juice flash
            }
            break;
            
        case "FINISHED":
            // Expand panel height for the Confirm button
            dice_panel_h_extra = lerp(dice_panel_h_extra, 100, 0.1);
            
            // Animation logic for selection lift
            for (var i = 0; i < 3; i++) {
                var _target_y = dice_selected[i] ? -30 : 0;
                // Add a subtle 'float' if selected
                if (dice_selected[i]) _target_y += sin(current_time / 400) * 4;
                dice_select_y[i] = lerp(dice_select_y[i], _target_y, 0.15);
            }
            break;
    }



} else {
    // Reset state when not in DICE state
    dice_phase = "IDLE";
    dice_timer = 0;
    dice_can_exit = false;
}

// Gradually fade out the flash effect
if (dice_flash_alpha > 0) {
    dice_flash_alpha = lerp(dice_flash_alpha, 0, 0.15);
    if (dice_flash_alpha < 0.01) dice_flash_alpha = 0;
}



