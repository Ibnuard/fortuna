function GuiModuleConfirm(_ctrl) constructor {
    ctrl = _ctrl;

    confirm_phase = 0;
    confirm_unsel_frame = 0;
    confirm_unsel_alpha = 1.0;
    confirm_unsel_scale = 1.0;
    confirm_unsel_idx   = -1;

    confirm_hover_frame   = 0;          
    confirm_dice_init_x   = [0, 0];     
    confirm_dice_init_y   = [0, 0];     

    confirm_pulse_frame = 0;
    confirm_pulse_scale = 1.0;

    confirm_fly_frame   = 0;
    confirm_fly_start_x = [0, 0];  
    confirm_fly_start_y = [0, 0];
    confirm_fly_values  = [0, 0];

    confirm_panel_frame   = 0;
    confirm_panel_y_bonus = 0;
    confirm_panel_alpha   = 1.0;
    confirm_launch_delay = 0;

    dice_total = 0;

    static start_animation = function(_dice_selected, _dice_values, _popup_x, _dice_y_slot, _dw, _gap, _margin) {
        var _fly_ptr = 0;
        dice_total = 0;
        confirm_unsel_idx = -1;
        var _gui_w = display_get_gui_width();
        var _popup_y = (_gui_w / 2) - 100; // rough approximation, overwritten smoothly
        // More precise mapping needed...
        
        var _hover_gap    = 20; 
        var _hover_pair_w = (2 * _dw) + _hover_gap;
        var _hover_left_x = (_gui_w / 2) - (_hover_pair_w / 2); 
        var _hover_y      = ctrl.mod_dice.dice_pop_y + (display_get_gui_height()/2) - 200; 
        
        for (var k = 0; k < 3; k++) {
            if (_dice_selected[k]) {
                var _die_x = _popup_x + _margin + (k * (_dw + _gap));
                var _die_y = _dice_y_slot + ctrl.mod_dice.dice_select_y[k];
                confirm_fly_values[_fly_ptr]  = _dice_values[k];
                confirm_dice_init_x[_fly_ptr] = _die_x;
                confirm_dice_init_y[_fly_ptr] = _die_y;
                confirm_fly_start_x[_fly_ptr] = _hover_left_x + (_fly_ptr * (_dw + _hover_gap));
                confirm_fly_start_y[_fly_ptr] = _hover_y;
                dice_total += (_dice_values[k] + 1);
                _fly_ptr++;
            } else {
                confirm_unsel_idx = k;
            }
        }
        
        confirm_phase       = 1;
        confirm_hover_frame = 0;
        confirm_panel_frame = 0;
        confirm_panel_y_bonus = 0;
        confirm_panel_alpha   = 1.0;
        
        if (confirm_unsel_idx != -1) {
            var _ex_gui_x = _popup_x + _margin + (confirm_unsel_idx * (_dw + _gap));
            var _ex_gui_y = _dice_y_slot;
            var _ex_spr   = spr_dice;
            var _ex_sub   = _dice_values[confirm_unsel_idx];
            var _ex_ww    = sprite_get_width(_ex_spr);
            var _ex_hh    = sprite_get_height(_ex_spr);
            var _chunk    = 8;
            for (var _pi = 0; _pi < _ex_ww; _pi += _chunk) {
                for (var _pj = 0; _pj < _ex_hh; _pj += _chunk) {
                    var _life = irandom_range(25, 45);
                    array_push(ctrl.mod_fx.dice_particles, {
                        spr     : _ex_spr,
                        sub_img : _ex_sub,
                        chunk_xx: _pi,
                        chunk_yy: _pj,
                        chunk_sz: _chunk,
                        gui_x   : _ex_gui_x + (_pi * 0.55),
                        gui_y   : _ex_gui_y + (_pj * 0.55),
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

    static step = function() {
        switch (confirm_phase) {
            case 0: break; 
            case 1: 
                confirm_hover_frame++;
                if (confirm_hover_frame >= 8) {
                    confirm_hover_frame = 0; 
                    confirm_phase = 2;
                }
                break;
            case 2: 
                confirm_hover_frame++;
                if (confirm_hover_frame >= 12) {
                    confirm_hover_frame = 12; 
                    confirm_phase = 3;
                    confirm_panel_frame = 0;
                }
                break;
            case 3: 
                confirm_panel_frame++;
                var _t3 = clamp(confirm_panel_frame / 15, 0, 1);
                confirm_panel_y_bonus = lerp(0, 220, _t3);
                confirm_panel_alpha   = lerp(1.0, 0.0, _t3);
                if (confirm_panel_frame >= 15) {
                    confirm_phase = 4;
                    confirm_fly_frame = 0;
                }
                break;
            case 4: 
                confirm_fly_frame++;
                if (confirm_fly_frame >= 30) {
                    confirm_fly_frame = 30;
                    confirm_phase = 5;
                    confirm_launch_delay = 22;
                    ctrl.gui_state  = "MOVING";
                    ctrl.mod_dice.dice_pop_y = 1000;
                }
                break;
            case 5: 
                confirm_launch_delay--;
                if (confirm_launch_delay <= 0) {
                    if (instance_exists(obj_board)) {
                        obj_board.steps_remaining = dice_total;
                    }
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

        if (ctrl.gui_state == "MOVING" && confirm_phase == 0) {
            if (instance_exists(obj_board)) {
                if (obj_board.steps_remaining <= 0 && !obj_board.anim_active) {
                    if (instance_exists(obj_controller)) {
                        obj_controller.current_turn++;
                    }
                    ctrl.gui_state = "MAIN";
                }
            }
        }
    }

    static draw = function() {
        if (confirm_phase >= 1) {
            var _gui_w = display_get_gui_width();
            var _gui_h = display_get_gui_height();
            var _ca_margin  = 40;
            var _ca_gap     = 30;
            var _ca_scale   = 0.55;
            var _ca_dw      = sprite_get_width(spr_dice) * _ca_scale;
            var _ca_total_w = (3 * _ca_dw) + (2 * _ca_gap) + (2 * _ca_margin);
            var _ca_total_h = sprite_get_height(spr_dice) * _ca_scale + (2 * _ca_margin);
            var _ca_popup_x = (_gui_w / 2) - (_ca_total_w / 2);
            var _ca_base_py = (_gui_h / 2) - (_ca_total_h / 2);

            var _draw_dice_gold = function(_spr, _sub, _x, _y, _sc, _alpha) {
                var _dw_inner = sprite_get_width(_spr) * _sc;
                var _out = 4;
                var _c_gold = make_color_rgb(255, 215, 0);
                gpu_set_fog(true, _c_gold, 0, 0);
                draw_sprite_ext(_spr, _sub, _x - _out, _y,        _sc, _sc, 0, c_white, _alpha);
                draw_sprite_ext(_spr, _sub, _x + _out, _y,        _sc, _sc, 0, c_white, _alpha);
                draw_sprite_ext(_spr, _sub, _x,        _y - _out, _sc, _sc, 0, c_white, _alpha);
                draw_sprite_ext(_spr, _sub, _x,        _y + _out, _sc, _sc, 0, c_white, _alpha);
                draw_sprite_ext(_spr, _sub, _x - _out, _y - _out, _sc, _sc, 0, c_white, _alpha);
                draw_sprite_ext(_spr, _sub, _x + _out, _y - _out, _sc, _sc, 0, c_white, _alpha);
                draw_sprite_ext(_spr, _sub, _x - _out, _y + _out, _sc, _sc, 0, c_white, _alpha);
                draw_sprite_ext(_spr, _sub, _x + _out, _y + _out, _sc, _sc, 0, c_white, _alpha);
                gpu_set_fog(false, c_white, 0, 0);
                draw_sprite_ext(_spr, _sub, _x, _y, _sc, _sc, 0, c_white, _alpha);
                
                var _num_str = string(_sub + 1);
                var _num_x   = _x + (_dw_inner / 2);
                var _num_y   = _y - 66;
                draw_set_font(fnt_gui_button_large);
                draw_set_halign(fa_center); draw_set_valign(fa_top);
                draw_set_color(c_black); draw_set_alpha(_alpha * 0.5);
                draw_text(_num_x + 5, _num_y + 6, _num_str);
                draw_set_alpha(_alpha);
                draw_set_color(c_black);
                draw_text(_num_x - 3, _num_y,     _num_str); draw_text(_num_x + 3, _num_y,     _num_str);
                draw_text(_num_x,     _num_y - 3, _num_str); draw_text(_num_x,     _num_y + 3, _num_str);
                draw_text(_num_x - 3, _num_y - 3, _num_str); draw_text(_num_x + 3, _num_y - 3, _num_str);
                draw_text(_num_x - 3, _num_y + 3, _num_str); draw_text(_num_x + 3, _num_y + 3, _num_str);
                draw_set_color(_c_gold);
                draw_text(_num_x, _num_y, _num_str);
                draw_set_alpha(1.0); draw_set_color(c_white); draw_set_halign(fa_left);
            };

            if (confirm_phase == 1) {
                draw_sprite_stretched(spr_dice_container, 0, _ca_popup_x, _ca_base_py, _ca_total_w, _ca_total_h);
                for (var f = 0; f < 2; f++) {
                    _draw_dice_gold(spr_dice, confirm_fly_values[f], confirm_dice_init_x[f], confirm_dice_init_y[f], _ca_scale, 1.0);
                }
            }
            if (confirm_phase == 2) {
                draw_sprite_stretched(spr_dice_container, 0, _ca_popup_x, _ca_base_py, _ca_total_w, _ca_total_h);
                var _t2 = clamp(confirm_hover_frame / 12, 0, 1);
                var _t2e = 1.0 - power(1.0 - _t2, 3.0); 
                for (var f = 0; f < 2; f++) {
                    var _dx = lerp(confirm_dice_init_x[f], confirm_fly_start_x[f], _t2e);
                    var _dy = lerp(confirm_dice_init_y[f], confirm_fly_start_y[f], _t2e);
                    _draw_dice_gold(spr_dice, confirm_fly_values[f], _dx, _dy, _ca_scale, 1.0);
                }
            }
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
            if (confirm_phase == 4 && instance_exists(obj_pawn)) {
                var _pawn_rx = obj_pawn.x;
                var _pawn_ry = obj_pawn.y + obj_pawn.y_offset;
                var _vx      = camera_get_view_x(view_camera[0]);
                var _vy      = camera_get_view_y(view_camera[0]);
                var _pawn_gx = _pawn_rx - _vx;
                var _pawn_gy = _pawn_ry - _vy;

                var _ft    = clamp(confirm_fly_frame / 30, 0, 1);
                var _tease = _ft < 0.5 ? 2 * _ft * _ft : 1.0 - power(-2.0 * _ft + 2.0, 2.0) / 2.0;
                var _fly_alpha = (_ft > 0.75) ? lerp(1.0, 0.0, (_ft - 0.75) / 0.25) : 1.0;
                var _fly_scale = _ca_scale * (1.0 + sin(_ft * pi) * 0.35);

                for (var f = 0; f < 2; f++) {
                    var _fx = lerp(confirm_fly_start_x[f], _pawn_gx, _tease);
                    var _fy = lerp(confirm_fly_start_y[f], _pawn_gy, _tease);
                    _fy -= sin(_ft * pi) * 60;
                    var _frot = _ft * 20; 
                    draw_sprite_ext(spr_dice, confirm_fly_values[f], _fx, _fy, _fly_scale, _fly_scale, _frot, c_white, _fly_alpha);
                }
            }
            draw_set_alpha(1.0); draw_set_halign(fa_left); draw_set_valign(fa_top);
        }
    }
}