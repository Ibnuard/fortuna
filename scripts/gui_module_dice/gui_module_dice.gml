function GuiModuleDice(_ctrl) constructor {
    ctrl = _ctrl;

    dice_values      = [0, 0, 0];
    dice_pop_y       = 1000;
    dice_can_exit    = false;
    dice_phase       = "IDLE"; 
    dice_timer       = 0;
    dice_flash_alpha = 0;
    dice_selected    = [false, false, false];
    dice_select_y    = [0, 0, 0];
    
    // -- Local Reveal FX --
    dice_pop_scale   = [1.0, 1.0, 1.0]; 
    dice_local_glow  = [0, 0, 0]; 
    dice_shake_mag   = 0;
    
    dice_panel_h_extra = 0;
    c_gold = C_PURE_GOLD;

    static step = function() {
        var _dice_target_y = (ctrl.gui_state == "DICE") ? 0 : 1000;
        if (ctrl.mod_confirm.confirm_phase >= 1 && ctrl.mod_confirm.confirm_phase <= 3) _dice_target_y = 0;
        dice_pop_y = lerp(dice_pop_y, _dice_target_y, ctrl.animation_speed);
        
        if (ctrl.gui_state == "DICE") {
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
                        
                        // -- Local Impact Trigger --
                        dice_shake_mag = 6; 
                        dice_flash_alpha = 0; // Hapus flash satu layar penuh
                        for (var i = 0; i < 3; i++) {
                            dice_pop_scale[i] = 1.35; 
                            dice_local_glow[i] = 1.0;
                        }
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
        } else if (ctrl.mod_confirm.confirm_phase == 0) {
            dice_phase    = "IDLE";
            dice_timer    = 0;
            dice_can_exit = false;
        }

        // Lerp Local FX
        for (var i = 0; i < 3; i++) {
            dice_pop_scale[i] = lerp(dice_pop_scale[i], 1.0, 0.15);
            dice_local_glow[i] = lerp(dice_local_glow[i], 0, 0.1);
        }
        dice_shake_mag = lerp(dice_shake_mag, 0, 0.15);

        if (dice_flash_alpha > 0) {
            dice_flash_alpha = lerp(dice_flash_alpha, 0, 0.15);
            if (dice_flash_alpha < 0.01) dice_flash_alpha = 0;
        }
    }

    static draw = function() {
        if ((ctrl.gui_state == "DICE" || dice_pop_y < 990) && ctrl.mod_confirm.confirm_phase == 0) {
            var _gui_w = display_get_gui_width();
            var _gui_h = display_get_gui_height();
            
            var _dice_overlay_alpha = lerp(0, 0.4, clamp(1.0 - (dice_pop_y / 1000), 0, 1));
            draw_set_color(c_black);
            draw_set_alpha(_dice_overlay_alpha);
            draw_rectangle(0, 0, _gui_w, _gui_h, false);
            draw_set_alpha(1.0);
            
            var _dice_scale = GUI_DICE_SCALE; 
            var _margin = 40; 
            var _gap = 30; 
            
            var _dw_base = sprite_get_width(spr_dice) * _dice_scale;
            var _dh_base = sprite_get_height(spr_dice) * _dice_scale;
            var _total_w = (3 * _dw_base) + (2 * _gap) + (2 * _margin);
            var _total_h = _dh_base + (2 * _margin) + dice_panel_h_extra; 
            
            var _popup_x = (_gui_w / 2) - (_total_w / 2);
            var _popup_y = (_gui_h / 2) - (_total_h / 2) + dice_pop_y;
            
            draw_sprite_stretched(spr_dice_container, 0, _popup_x, _popup_y, _total_w, _total_h);
            
            var _is_rolling = (dice_phase == "ROLLING");
            var _shake_raw = (_is_rolling ? 6 : 0) + dice_shake_mag;
            var _dice_y_slot = _popup_y + _margin;
            var _sel_count = dice_selected[0] + dice_selected[1] + dice_selected[2];
            
            for (var i = 0; i < 3; i++) {
                var _dice_x_slot = _popup_x + _margin + (i * (_dw_base + _gap));
                
                var _ds = _dice_scale * dice_pop_scale[i];
                var _dw_curr = sprite_get_width(spr_dice) * _ds;
                var _dh_curr = sprite_get_height(spr_dice) * _ds;
                
                // Centering inside slot (Static reference)
                var _dx = _dice_x_slot + (_dw_base / 2) - (_dw_curr / 2);
                var _dy = _dice_y_slot + dice_select_y[i] + (_dh_base / 2) - (_dh_curr / 2);
                
                if (_shake_raw > 0) {
                    _dx += random_range(-_shake_raw, _shake_raw);
                    _dy += random_range(-_shake_raw, _shake_raw);
                }
                
                var _die_alpha = 1.0;
                if (dice_phase == "FINISHED" && _sel_count == 2 && !dice_selected[i]) {
                    _die_alpha = 0.6; 
                }
                // -- Golden Selection Outline (Back Layer) --
                if (dice_selected[i] && dice_phase == "FINISHED" && ctrl.mod_confirm.confirm_phase == 0) {
                    var _out = 4;
                    gpu_set_fog(true, C_PURE_GOLD, 0, 0); 
                    draw_sprite_ext(spr_dice, dice_values[i], _dx - _out, _dy, _ds, _ds, 0, c_white, 0.7);
                    draw_sprite_ext(spr_dice, dice_values[i], _dx + _out, _dy, _ds, _ds, 0, c_white, 0.7);
                    draw_sprite_ext(spr_dice, dice_values[i], _dx, _dy - _out, _ds, _ds, 0, c_white, 0.7);
                    draw_sprite_ext(spr_dice, dice_values[i], _dx, _dy + _out, _ds, _ds, 0, c_white, 0.7);
                    gpu_set_fog(false, c_white, 0, 0); 
                }

                var _die_alpha = 1.0;
                if (dice_phase == "FINISHED" && _sel_count == 2 && !dice_selected[i]) {
                    _die_alpha = 0.6; 
                }
                draw_sprite_ext(spr_dice, dice_values[i], _dx, _dy, _ds, _ds, 0, c_white, _die_alpha);

                // -- Local Flash Glow (Front Layer) --
                if (dice_local_glow[i] > 0.01) {
                    var _fsc = _ds * 1.12; 
                    var _fdw = sprite_get_width(spr_dice) * _fsc;
                    var _fdh = sprite_get_height(spr_dice) * _fsc;
                    var _fdx = _dx + (_dw_curr / 2) - (_fdw / 2);
                    var _fdy = _dy + (_dh_curr / 2) - (_fdh / 2);
                    
                    gpu_set_blendmode(bm_add);
                    gpu_set_fog(true, c_white, 0, 0);
                    draw_sprite_ext(spr_dice, dice_values[i], _fdx, _fdy, _fsc, _fsc, 0, c_white, dice_local_glow[i] * 0.85);
                    gpu_set_fog(false, c_white, 0, 0);
                    gpu_set_blendmode(bm_normal);
                }

                
                if (dice_phase == "FINISHED" && dice_selected[i]) {
                    draw_set_font(fnt_gui_button_large); 
                    draw_set_halign(fa_center);
                    var _num_x = _dx + (_dw_curr / 2);
                    var _num_y = _dy - 70; 
                    var _num_str = string(dice_values[i] + 1);
                    
                    draw_set_color(c_black); draw_set_alpha(0.5);
                    draw_text(_num_x + 5, _num_y + 6, _num_str);
                    draw_set_alpha(1.0);
                    
                    draw_set_color(c_black);
                    draw_text(_num_x - 3, _num_y, _num_str);
                    draw_text(_num_x + 3, _num_y, _num_str);
                    draw_text(_num_x, _num_y - 3, _num_str);
                    draw_text(_num_x, _num_y + 3, _num_str);
                    draw_text(_num_x - 3, _num_y - 3, _num_str);
                    draw_text(_num_x + 3, _num_y - 3, _num_str);
                    draw_text(_num_x - 3, _num_y + 3, _num_str);
                    draw_text(_num_x + 3, _num_y + 3, _num_str);
                    
                    draw_set_color(c_gold);
                    draw_text(_num_x, _num_y, _num_str);
                }
                
                if (dice_phase == "FINISHED") {
                    var _mx = device_mouse_x_to_gui(0);
                    var _my = device_mouse_y_to_gui(0);
                    if (point_in_rectangle(_mx, _my, _dx, _dy, _dx + _dw_curr, _dy + _dh_curr)) {
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
            
            if (dice_phase == "FINISHED") {
                draw_set_font(fnt_main);
                draw_set_halign(fa_center);
                draw_set_valign(fa_top);
                
                if (_sel_count < 2) {
                    draw_set_font(fnt_gui_button_medium); 
                    var _osc_alpha = abs(sin(current_time/300));
                    var _inst_x = _gui_w / 2;
                    var _inst_y = _popup_y + _total_h + 25; 
                    
                    draw_set_color(c_black);
                    draw_set_alpha(_osc_alpha * 0.7);
                    draw_text(_inst_x + 3, _inst_y + 4, "Select 2 Dice to Keep");
                    
                    draw_set_color(c_gold);
                    draw_set_alpha(_osc_alpha);
                    draw_text(_inst_x, _inst_y, "Select 2 Dice to Keep");
                    
                    draw_set_alpha(1.0);
                } else if (dice_panel_h_extra > 50) {
                    var _ui_alpha = clamp((dice_panel_h_extra - 50) / 70, 0, 1);
                    draw_set_alpha(_ui_alpha);
                    
                    var _conf_w = 260;
                    var _conf_h = 80; 
                    var _conf_x = (_gui_w / 2) - (_conf_w / 2);
                    var _conf_y = _popup_y + _total_h - 125; 
                    
                    var _is_ready = (_ui_alpha > 0.95);
                    
                    if (draw_gui_button(_conf_x, _conf_y, _conf_w, _conf_h, spr_button_main, "Confirm Selection", c_white, fnt_gui_button_medium, _is_ready)) {
                        ctrl.mod_confirm.start_animation(dice_selected, dice_values, _popup_x, _dice_y_slot, _dw_base, _gap, _margin);
                        
                        dice_can_exit = false;
                        dice_phase = "IDLE";
                    }
                    draw_set_alpha(1.0);
                }
                
                var _side_w = 160; 
                var _side_h = 60;  
                var _side_gap = 16; 
                var _side_left_x = _popup_x - _side_w - 20; 
                var _side_left_y = _popup_y + ((_dh_base + (2 * _margin)) / 2) - (_side_h / 2); 
                
                if (draw_gui_button(_side_left_x, _side_left_y, _side_w, _side_h, spr_button_main, "View Map", c_white, fnt_main, true)) {
                    ctrl.map_popup_open = true;
                }
                
                var _side_right_total_h = (2 * _side_h) + _side_gap;
                var _side_right_x = _popup_x + _total_w + 20; 
                var _side_right_y = _popup_y + ((_dh_base + (2 * _margin)) / 2) - (_side_right_total_h / 2); 
                
                if (draw_gui_button(_side_right_x, _side_right_y, _side_w, _side_h, spr_button_red, "Re Roll", c_white, fnt_main, true)) {
                    dice_phase = "ROLLING";
                    dice_timer = irandom_range(40, 60);
                    dice_selected[0] = false;
                    dice_selected[1] = false;
                    dice_selected[2] = false;
                    dice_panel_h_extra = 0;
                }
                
                if (draw_gui_button(_side_right_x, _side_right_y + _side_h + _side_gap, _side_w, _side_h, spr_button_blue, "Use Fate Card", c_white, fnt_main, true)) {
                    show_debug_message("Action: Use Fate Card");
                }
            }
        }
    }
}