function GuiModuleBottom(_ctrl) constructor {
    ctrl = _ctrl;

    bottom_y_offset = 500;
    stagger_turn_badge = 80;
    stagger_btn_center = 80;
    stagger_btn_left   = 80;
    stagger_btn_right  = 80;

    static step = function() {
        var _target_bottom_offset = (ctrl.gui_state == "MAIN" || ctrl.gui_state == "MOVING") ? 0 : 300;
        
        if (abs(bottom_y_offset - _target_bottom_offset) > 0.5) {
            bottom_y_offset = lerp(bottom_y_offset, _target_bottom_offset, ctrl.animation_speed);
        } else {
            bottom_y_offset = _target_bottom_offset;
        }
        
        var _spd = 0.10;
        if (ctrl.mod_topbar.intro_timer > 20) { stagger_turn_badge = lerp(stagger_turn_badge, 0, _spd); }
        if (ctrl.mod_topbar.intro_timer > 30) { stagger_btn_center = lerp(stagger_btn_center, 0, _spd); }
        if (ctrl.mod_topbar.intro_timer > 35) { stagger_btn_left   = lerp(stagger_btn_left,   0, _spd); }
        if (ctrl.mod_topbar.intro_timer > 38) { stagger_btn_right  = lerp(stagger_btn_right,  0, _spd); }

        if (abs(stagger_turn_badge)< 0.5) stagger_turn_badge = 0;
        if (abs(stagger_btn_center)< 0.5) stagger_btn_center = 0;
        if (abs(stagger_btn_left)  < 0.5) stagger_btn_left  = 0;
        if (abs(stagger_btn_right) < 0.5) stagger_btn_right = 0;
    }

    static draw_panel = function() {
         
         
        var _gap = GUI_BTN_GAP; 
        var _total_btn_w = (GUI_BTN_SIDE_W * 2) + GUI_BTN_MAIN_W + (_gap * 2);
        var _padding_x = 48;
        var _panel_w = _total_btn_w + (_padding_x * 2); 
        var _panel_h = GUI_PANEL_H;
        var _target_y = 855; 
        var _panel_draw_y = _target_y + bottom_y_offset;
        var _panel_x = room_width / 2 - (_panel_w / 2);

        draw_sprite_stretched(spr_gui_bottom_container, 0, _panel_x, _panel_draw_y, _panel_w, _panel_h);

        var _turn_str = "Turn 1 / 20";
        if (instance_exists(obj_controller)) {
            _turn_str = "Turn " + string(obj_controller.current_turn) + " / " + string(obj_controller.map_max_turns);
        }
        var _badge_angle = 0;
        var _badge_w = 200;
        var _badge_h = 80;
        var _badge_x = room_width / 2;
        var _badge_y = _panel_draw_y - 2 + stagger_turn_badge;

        draw_set_alpha(1.0);
        draw_sprite_ext(spr_container, 0, _badge_x, _badge_y + 10, _badge_w/200, _badge_h/100, _badge_angle, c_white, 1);

        draw_set_font(fnt_main);
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        draw_set_color(c_black); draw_set_alpha(0.3);
        draw_text_transformed(_badge_x + 2, _badge_y + 12, _turn_str, 1.6, 1.6, _badge_angle);
        draw_set_color(c_white); draw_set_alpha(1.0);
        draw_text_transformed(_badge_x, _badge_y + 8, _turn_str, 1.6, 1.6, _badge_angle);
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }

    static draw_buttons = function() {
         
        
         
        
        var _gap = GUI_BTN_GAP; 
        var _panel_h = GUI_PANEL_H;
        var _target_y = 855; 
        var _panel_draw_y = _target_y + bottom_y_offset;

        var _mid_y = _panel_draw_y + (_panel_h / 2) - 10; 
        var _main_y = _mid_y - (GUI_BTN_MAIN_H / 2);
        var _center_x = room_width / 2 - (GUI_BTN_MAIN_W / 2);
        var _left_x   = _center_x - _gap - GUI_BTN_SIDE_W;
        var _right_x  = _center_x + GUI_BTN_MAIN_W + _gap;

        if (ctrl.gui_state == "MOVING") {
            var _box_w = 400;
            var _box_h = 100;
            var _box_x = room_width / 2 - (_box_w / 2);
            var _box_y = _mid_y - (_box_h / 2);
            
            draw_sprite_stretched(spr_dice_container, 0, _box_x, _box_y, _box_w, _box_h);
            
            if (instance_exists(obj_board)) {
                draw_set_font(fnt_gui_button_large);
                draw_set_halign(fa_center); draw_set_valign(fa_middle);
                var _step_str = "Remaining: " + string(obj_board.steps_remaining);
                draw_set_color(c_black); draw_set_alpha(0.4);
                draw_text(_box_x + _box_w/2 + 4, _box_y + _box_h/2 - 6 + 5, _step_str); 
                draw_set_color(c_white); draw_set_alpha(1.0);
                draw_text(_box_x + _box_w/2, _box_y + _box_h/2 - 6, _step_str);
            }
        } else {
            if (draw_gui_button(_left_x, _main_y + stagger_btn_left, GUI_BTN_SIDE_W, GUI_BTN_SIDE_H, spr_button_red, "Inventory", c_white, fnt_gui_button_medium, ctrl.can_interact_gui)) {
                ctrl.gui_state = "PROPERTY";
            }

            var _roll_y = _main_y + stagger_btn_center;
            if (draw_gui_button(_center_x, _roll_y, GUI_BTN_MAIN_W, GUI_BTN_MAIN_H, spr_button_main, "", c_white, fnt_gui_button_medium, ctrl.can_interact_gui)) {
                if (ctrl.gui_state == "MAIN") {
                    ctrl.gui_state = "DICE";
                    ctrl.mod_dice.dice_phase = "ENTERING";
                    ctrl.mod_dice.dice_timer = 0;
                    ctrl.mod_dice.dice_pop_y = 1000;    
                    ctrl.mod_dice.dice_can_exit = false;
                    randomize();          
                }
            }

            var _wave_str = "Roll The Dice!";
            var _wave_len = string_length(_wave_str);
            draw_set_font(fnt_gui_button_medium);
            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);
            var _roll_hover = ctrl.can_interact_gui && point_in_rectangle(_mx, _my, _center_x, _roll_y, _center_x + GUI_BTN_MAIN_W, _roll_y + GUI_BTN_MAIN_H);
            var _roll_press = ctrl.can_interact_gui && _roll_hover && mouse_check_button(mb_left);
            var _juice_y = 0;
            if (_roll_hover && !_roll_press) _juice_y = -6;
            if (_roll_press) _juice_y = 2;
            var _total_w = string_width(_wave_str);
            var _start_x = _center_x + (GUI_BTN_MAIN_W / 2) - (_total_w / 2);
            var _face_h = GUI_BTN_MAIN_H - 16 + ((_roll_press) ? -2 : 0); 
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

            draw_gui_button(_right_x, _main_y + stagger_btn_right, GUI_BTN_SIDE_W, GUI_BTN_SIDE_H, spr_button_blue, "Shop", c_white, fnt_gui_button_medium, ctrl.can_interact_gui);
        }
    }
}