function GuiModuleSkills(_ctrl) constructor {
    ctrl = _ctrl;
    tooltip_alpha = 0;
    active_tooltip = -1;
    fill_lerp = 0;
    
    static step = function() {
        var _skills_target = ctrl.skills_popup_open ? 1.0 : 0.0;
        var _slide_target = ctrl.skills_popup_open ? 0.0 : 100.0;

        ctrl.skills_popup_alpha = lerp(ctrl.skills_popup_alpha, _skills_target, 0.15);
        if (abs(ctrl.skills_popup_alpha - _skills_target) < 0.005) ctrl.skills_popup_alpha = _skills_target;

        ctrl.skills_popup_y_slide = lerp(ctrl.skills_popup_y_slide, _slide_target, 0.15);
        if (abs(ctrl.skills_popup_y_slide - _slide_target) < 0.1) ctrl.skills_popup_y_slide = _slide_target;
        
        if (ctrl.skills_popup_alpha > 0.1) {
             fill_lerp = lerp(fill_lerp, 1.0, 0.12);
        } else {
             fill_lerp = 0;
        }

        if (!ctrl.skills_popup_open) {
            active_tooltip = -1; 
            tooltip_alpha = 0;
        }
    }

    static draw = function() {
        if (ctrl.skills_popup_alpha > 0) {
            var _gui_w = display_get_gui_width();
            var _gui_h = display_get_gui_height();
            var _mx    = device_mouse_x_to_gui(0);
            var _my    = device_mouse_y_to_gui(0);
            
            draw_set_color(c_black);
            draw_set_alpha(ctrl.skills_popup_alpha * 0.6);
            draw_rectangle(0, 0, _gui_w, _gui_h, false);
            
            var _num_stats = array_length(global.stat_data);
            var _p_w = 720;
            var _row_gap = 65;
            var _header_h = 120;
            var _footer_h = 60;
            var _p_h = _header_h + ((_num_stats - 1) * _row_gap) + 44 + _footer_h;
            
            var _p_x = (_gui_w / 2) - (_p_w / 2);
            var _p_y = (_gui_h / 2) - (_p_h / 2) + ctrl.skills_popup_y_slide;
            
            draw_set_alpha(ctrl.skills_popup_alpha);
            draw_sprite_stretched(spr_dice_container, 0, _p_x, _p_y, _p_w, _p_h);
            
            draw_set_font(fnt_gui_button_large);
            draw_set_halign(fa_center); draw_set_valign(fa_top);
            draw_set_color(c_white);
            draw_text(_p_x + _p_w/2, _p_y + 25, "Pawn Skills");
            
            var _row_y_start = _p_y + _header_h;
            var _bar_w       = 380;
            var _bar_h       = 44;

            // FIX 1: Measure actual text width instead of hardcoded estimate
            draw_set_font(fnt_main);
            var _txt_w_est = string_width("10 / 10") + 20;
            
            var _icon_sz         = 48;
            var _gap_1           = 30;
            var _gap_2           = 40;
            var _total_content_w = _icon_sz + _gap_1 + _bar_w + _gap_2 + _txt_w_est;
            
            // FIX 2: Center total content properly
            var _margin_x = (_p_w - _total_content_w) / 2;
            var _icon_x   = _p_x + _margin_x + (_icon_sz / 2);
            var _bar_x    = _p_x + _margin_x + _icon_sz + _gap_1;
            
            var _hovered_i = -1;
            
            for (var i = 0; i < array_length(global.stat_data); i++) {
                var _s  = global.stat_data[i];
                var _cy = _row_y_start + (i * _row_gap);
                var _is_hover = false;
                
                if (point_in_rectangle(_mx, _my, _icon_x - 30, _cy - 10, _icon_x + 30, _cy + _bar_h + 10)) {
                    _is_hover = true;
                    _hovered_i = i;
                    if (mouse_check_button_pressed(mb_left)) {
                        active_tooltip = i;
                    }
                }
                
                var _icon_alpha = _is_hover ? ctrl.skills_popup_alpha : (ctrl.skills_popup_alpha * 0.85);
                draw_sprite_ext(spr_skills, _s.icon, _icon_x, _cy + (_bar_h / 2), 1, 1, 0, c_white, _icon_alpha);
                
                draw_set_color(c_white);
                draw_set_alpha(ctrl.skills_popup_alpha);
                draw_sprite_stretched(spr_target_bar, 0, _bar_x, _cy, _bar_w, _bar_h);
                
                var _val = 5;
                if (instance_exists(obj_controller)) {
                    var _key = string_replace_all(string_lower(_s.name), " ", "_");
                    _val = variable_struct_get(obj_controller.stats, _key);
                }
                
                var _inner_pad_x = 12;
                var _fill_max_w  = _bar_w - (_inner_pad_x * 2);
                var _fw          = (_val / 10) * _fill_max_w * fill_lerp;
                
                // FIX 3: Fill bar centered vertically relative to _bar_h
                if (_fw > 0) {
                    draw_set_color(_s.color);
                    draw_set_alpha(ctrl.skills_popup_alpha);
                    var _fill_y1 = _cy + (_bar_h * 0.28);
                    var _fill_y2 = _cy + (_bar_h * 0.58);
                    draw_rectangle(_bar_x + _inner_pad_x, _fill_y1, _bar_x + _inner_pad_x + _fw, _fill_y2, false);
                }
                
                // FIX 4: Text vertically centered & left aligned properly
                draw_set_font(fnt_main);
                draw_set_halign(fa_left);
                draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_set_alpha(ctrl.skills_popup_alpha);
                draw_text(_bar_x + _bar_w + _gap_2, _cy + (_bar_h / 2), string(_val) + " / 10");
                
                if (active_tooltip == i || _is_hover) {
                    var _total_left  = _p_x + _margin_x;
                    var _total_right = _p_x + _margin_x + _total_content_w;
                    draw_set_color(_s.color);
                    draw_set_alpha(ctrl.skills_popup_alpha * 0.3);
                    draw_roundrect_ext(_total_left - 20, _cy - 12, _total_right + 20, _cy + _bar_h + 10, 20, 20, true);
                    draw_set_alpha(ctrl.skills_popup_alpha);
                }
            }
            
            // Close Button
            var _cx_sz = 64;
            var _cx_x  = _p_x + _p_w - 5; 
            var _cx_y  = _p_y + 5;         
            if (draw_gui_button(_cx_x - _cx_sz/2, _cx_y - _cx_sz/2, _cx_sz, _cx_sz, spr_panel_close, "", c_white, fnt_main, true)) {
                ctrl.skills_popup_open = false;
            }
            
            // Tooltip hover logic
            if (_hovered_i != -1) {
                active_tooltip = _hovered_i;
            } 
            if (_hovered_i == -1 && mouse_check_button_pressed(mb_left)) {
                active_tooltip = -1;
            }

            if (active_tooltip != -1) {
                tooltip_alpha = lerp(tooltip_alpha, 1.0, 0.2);
            } else {
                tooltip_alpha = lerp(tooltip_alpha, 0.0, 0.2);
            }

            if (tooltip_alpha > 0.01 && active_tooltip != -1) {
                var _d      = global.stat_data[active_tooltip];
                var _title  = _d.name;
                var _desc   = _d.desc;
                
                draw_set_font(fnt_main);
                var _title_w = string_width(_title) + 10;
                
                var _scale           = 1.0;
                var _sep             = 30;
                var _max_w_internal  = 420;
                
                var _desc_w_internal = string_width_ext(_desc, _sep, _max_w_internal);
                var _desc_h_internal = string_height_ext(_desc, _sep, _max_w_internal);
                var _desc_w_visual   = _desc_w_internal * _scale;
                var _desc_h_visual   = _desc_h_internal * _scale;
                
                var _pad_x = 24;
                var _pad_y = 20;
                var _tw    = max(_title_w, _desc_w_visual) + (_pad_x * 2); 
                var _th    = 40 + _desc_h_visual + _pad_y;
                
                var _t_row_y = _row_y_start + (active_tooltip * _row_gap);
                var _tx      = _icon_x - 30; 
                var _ty      = _t_row_y + _bar_h + 16; 
                
                if (_tx + _tw > _gui_w - 20) _tx = _gui_w - _tw - 20;
                if (_ty + _th > _gui_h - 20) _ty = _gui_h - _th - 20;
                
                draw_set_alpha(tooltip_alpha * ctrl.skills_popup_alpha);
                draw_set_color(C_DARKGRAY);
                draw_roundrect_ext(_tx, _ty, _tx + _tw, _ty + _th, 16, 16, false);
                draw_set_color(_d.color);
                draw_roundrect_ext(_tx, _ty, _tx + _tw, _ty + _th, 16, 16, true);
                
                draw_set_halign(fa_left); draw_set_valign(fa_top);
                draw_set_color(_d.color);
                draw_text(_tx + _pad_x, _ty + 12, _title);
                
                draw_set_color(c_white);
                draw_text_ext_transformed(_tx + _pad_x, _ty + 42, _desc, _sep, _max_w_internal, _scale, _scale, 0);
            }
            
            draw_set_alpha(1.0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}