// ─── PANEL OFFSET TARGETS ───
target_bottom_offset = (gui_state == "MAIN" || gui_state == "MOVING") ? 0 : 300;
var _target_prop_offset = (gui_state == "PROPERTY") ? 0 : 800;

if (abs(bottom_y_offset - target_bottom_offset) > 0.5) {
    bottom_y_offset = lerp(bottom_y_offset, target_bottom_offset, animation_speed);
} else {
    bottom_y_offset = target_bottom_offset;
}

// ─── INTRO STAGGER ANIMATION ───
intro_timer += 1;
var _spd = 0.10;

if (intro_timer > 5)  { top_y_offset = lerp(top_y_offset, top_y_target, _spd); if (abs(top_y_offset - top_y_target) < 0.5) top_y_offset = top_y_target; }
if (intro_timer > 15) { stagger_option    = lerp(stagger_option,    0, _spd); }
if (intro_timer > 25) { stagger_target_bar = lerp(stagger_target_bar, 0, _spd); }
if (intro_timer > 30) { stagger_cash       = lerp(stagger_cash,       0, _spd); }
if (intro_timer > 35) { stagger_map_stat   = lerp(stagger_map_stat,   0, _spd); }
if (intro_timer > 20) { stagger_turn_badge = lerp(stagger_turn_badge, 0, _spd); }
if (intro_timer > 30) { stagger_btn_center = lerp(stagger_btn_center, 0, _spd); }
if (intro_timer > 35) { stagger_btn_left   = lerp(stagger_btn_left,   0, _spd); }
if (intro_timer > 38) { stagger_btn_right  = lerp(stagger_btn_right,  0, _spd); }

if (abs(stagger_option)    < 0.5) stagger_option    = 0;
if (abs(stagger_target_bar)< 0.5) stagger_target_bar = 0;
if (abs(stagger_cash)      < 0.5) stagger_cash      = 0;
if (abs(stagger_map_stat)  < 0.5) stagger_map_stat  = 0;
if (abs(stagger_turn_badge)< 0.5) stagger_turn_badge = 0;
if (abs(stagger_btn_center)< 0.5) stagger_btn_center = 0;
if (abs(stagger_btn_left)  < 0.5) stagger_btn_left  = 0;
if (abs(stagger_btn_right) < 0.5) stagger_btn_right = 0;

// ─── PROPERTY PANEL ANIMATION ───
if (abs(property_y_offset - _target_prop_offset) > 0.5) {
    property_y_offset = lerp(property_y_offset, _target_prop_offset, animation_speed);
} else {
    property_y_offset = _target_prop_offset;
}

// Property Panel Scrolling
if (gui_state == "PROPERTY" && property_y_offset < 790) {
    var _scroll_speed = 65;
    if (mouse_wheel_up())   panel_scroll_target -= _scroll_speed;
    if (mouse_wheel_down()) panel_scroll_target += _scroll_speed;

    var _my = device_mouse_y_to_gui(0);
    var _panel_actual_y = _target_prop_offset + (room_height - (room_height * 0.6) + 50);
    if (mouse_check_button_pressed(mb_left) && _my > _panel_actual_y) {
        is_dragging_panel = true;
        drag_start_y  = _my;
        scroll_start  = panel_scroll_target;
    }
    if (is_dragging_panel) {
        if (mouse_check_button(mb_left)) {
            panel_scroll_target = scroll_start + (drag_start_y - _my);
        } else {
            is_dragging_panel = false;
        }
    }
    panel_scroll_target = clamp(panel_scroll_target, 0, panel_max_scroll);
    panel_scroll_y = lerp(panel_scroll_y, panel_scroll_target, 0.2);
} else {
    panel_scroll_target = 0;
    panel_scroll_y      = 0;
    is_dragging_panel   = false;
}

// ─── DICE POPUP Y (only animates when in DICE or while confirm anim still visible) ───
var _dice_target_y = (gui_state == "DICE") ? 0 : 1000;
// While confirm animation is playing, keep popup in view (phase 1-3), then let it slide in phase 4
if (confirm_phase >= 1 && confirm_phase <= 3) _dice_target_y = 0;
dice_pop_y = lerp(dice_pop_y, _dice_target_y, animation_speed);

// ─── DICE ROLL PHASES ───
if (gui_state == "DICE") {
    switch (dice_phase) {
        case "ENTERING":
            for (var k = 0; k < 3; k++) {
                dice_selected[k] = false;
                dice_select_y[k] = 0;
            }
            dice_panel_h_extra = 0;
            if (abs(dice_pop_y) < 5) {
                dice_pop_y = 0;
                dice_phase = "PAUSE";
                dice_timer = 20;
            }
            break;

        case "PAUSE":
            if (dice_timer > 0) { dice_timer--; }
            else { dice_phase = "ROLLING"; dice_timer = 60; }
            break;

        case "ROLLING":
            if (dice_timer > 0) {
                dice_timer--;
                for (var i = 0; i < 3; i++) dice_values[i] = irandom_range(0, 5);
            } else {
                dice_phase    = "FINISHED";
                dice_can_exit = true;
                dice_flash_alpha = 0.8;
            }
            break;

        case "FINISHED":
            var _sel_count = dice_selected[0] + dice_selected[1] + dice_selected[2];
            var _target_h  = (_sel_count == 2) ? 120 : 0;
            dice_panel_h_extra = lerp(dice_panel_h_extra, _target_h, 0.1);
            for (var i = 0; i < 3; i++) {
                var _ty = dice_selected[i] ? -30 : 0;
                if (dice_selected[i]) _ty += sin(current_time / 400) * 4;
                dice_select_y[i] = lerp(dice_select_y[i], _ty, 0.15);
            }
            break;
    }

} else if (confirm_phase == 0) {
    // Not in DICE and no confirm anim running — reset dice
    dice_phase    = "IDLE";
    dice_timer    = 0;
    dice_can_exit = false;
}

// ─── CONFIRM ANIMATION STATE MACHINE ───
switch (confirm_phase) {
    case 0: break; // idle

    case 1: // EXPLOSION HOLD: particles fly, dice stay at init pos (8 frames)
        confirm_hover_frame++;
        if (confirm_hover_frame >= 8) {
            confirm_hover_frame = 0; // reset for float-up use
            confirm_phase = 2;
        }
        break;

    case 2: // FLOAT UP: selected dice rise to center-hover (12 frames)
        confirm_hover_frame++;
        if (confirm_hover_frame >= 12) {
            confirm_hover_frame = 12; // clamp
            confirm_phase = 3;
            confirm_panel_frame = 0;
        }
        break;

    case 3: // PANEL OUT: panel slides down + fades, dice hover at center (15 frames)
        confirm_panel_frame++;
        var _t3 = clamp(confirm_panel_frame / 15, 0, 1);
        confirm_panel_y_bonus = lerp(0, 220, _t3);
        confirm_panel_alpha   = lerp(1.0, 0.0, _t3);
        if (confirm_panel_frame >= 15) {
            confirm_phase = 4;
            confirm_fly_frame = 0;
        }
        break;

    case 4: // FLY: dice travel to pawn with arc (30 frames)
        confirm_fly_frame++;
        if (confirm_fly_frame >= 30) {
            confirm_fly_frame = 30;
            confirm_phase = 5;
            confirm_launch_delay = 22;
            gui_state  = "MOVING";
            dice_pop_y = 1000;
        }
        break;

    case 5: // LAUNCH DELAY: wait for bottom panel before releasing pawn
        confirm_launch_delay--;
        if (confirm_launch_delay <= 0) {
            if (instance_exists(obj_board)) {
                obj_board.steps_remaining = dice_total;
            }
            // Cleanup all confirm state
            confirm_phase         = 0;
            confirm_hover_frame   = 0;
            confirm_unsel_frame   = 0;
            confirm_unsel_alpha   = 1.0;
            confirm_unsel_scale   = 1.0;
            confirm_pulse_frame   = 0;
            confirm_pulse_scale   = 1.0;
            confirm_fly_frame     = 0;
            confirm_panel_frame   = 0;
            confirm_panel_y_bonus = 0;
            confirm_panel_alpha   = 1.0;
            confirm_launch_delay  = 0;
        }
        break;
}

// ─── FLASH EFFECT ───
if (dice_flash_alpha > 0) {
    dice_flash_alpha = lerp(dice_flash_alpha, 0, 0.15);
    if (dice_flash_alpha < 0.01) dice_flash_alpha = 0;
}

// ─── MOVEMENT STATE: return to MAIN when pawn finishes ───
// Only check after confirm animation is fully done (confirm_phase == 0)
if (gui_state == "MOVING" && confirm_phase == 0) {
    if (instance_exists(obj_board)) {
        if (obj_board.steps_remaining <= 0 && !obj_board.anim_active) {
            // Increment Turn when pawn finishes moving
            if (instance_exists(obj_controller)) {
                obj_controller.current_turn++;
            }
            gui_state = "MAIN";
        }
    }
}


// ─── DICE EXPLOSION PARTICLES: update each frame ───
// Iterate backwards so we can safely remove dead particles
for (var _i = array_length(dice_particles) - 1; _i >= 0; _i--) {
    var _p = dice_particles[_i];
    _p.gui_x     += _p.vel_x;
    _p.gui_y     += _p.vel_y;
    _p.vel_y     += _p.gravity;
    _p.life--;
    if (_p.life <= 0) {
        array_delete(dice_particles, _i, 1);
    }
}

// ─── STATS POPUP TRANSITION ───
var _stats_target = stats_popup_open ? 1.0 : 0.0;
var _slide_target = stats_popup_open ? 0.0 : 100.0;

stats_popup_alpha = lerp(stats_popup_alpha, _stats_target, 0.15);
if (abs(stats_popup_alpha - _stats_target) < 0.005) stats_popup_alpha = _stats_target;

stats_popup_y_slide = lerp(stats_popup_y_slide, _slide_target, 0.15);
if (abs(stats_popup_y_slide - _slide_target) < 0.1) stats_popup_y_slide = _slide_target;

// ─── INTERACTION BLOCKING ───
// Main HUD buttons are blocked if:
// 1. A popup (Stats) is open or fading in
// 2. Dice selection state is active
// 3. Confirm animation is flying (dice in the air)
can_interact_gui = (!stats_popup_open && stats_popup_alpha <= 0 && gui_state != "DICE" && gui_state != "MOVING");
