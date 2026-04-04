function GuiModuleStats(_ctrl) constructor {
    ctrl = _ctrl;
    tooltip_alpha = 0;
    active_tooltip = -1;
    
    static step = function() {
        var _stats_target = ctrl.stats_popup_open ? 1.0 : 0.0;
        var _slide_target = ctrl.stats_popup_open ? 0.0 : 100.0;

        ctrl.stats_popup_alpha = lerp(ctrl.stats_popup_alpha, _stats_target, 0.15);
        if (abs(ctrl.stats_popup_alpha - _stats_target) < 0.005) ctrl.stats_popup_alpha = _stats_target;

        ctrl.stats_popup_y_slide = lerp(ctrl.stats_popup_y_slide, _slide_target, 0.15);
        if (abs(ctrl.stats_popup_y_slide - _slide_target) < 0.1) ctrl.stats_popup_y_slide = _slide_target;
        
        // Reset tooltip when closed
        if (!ctrl.stats_popup_open) {
            active_tooltip = -1; 
            tooltip_alpha = 0;
        }
    }

    static draw = function() {
        if (ctrl.stats_popup_alpha > 0) {
            var _gui_w = display_get_gui_width();
            var _gui_h = display_get_gui_height();
            var _mx    = device_mouse_x_to_gui(0);
            var _my    = device_mouse_y_to_gui(0);
            
            draw_set_color(c_black);
            draw_set_alpha(ctrl.stats_popup_alpha * 0.6);
            draw_rectangle(0, 0, _gui_w, _gui_h, false);
            
            var _p_w = 720;
            var _p_h = 580;
            var _p_x = (_gui_w / 2) - (_p_w / 2);
            var _p_y = (_gui_h / 2) - (_p_h / 2) + ctrl.stats_popup_y_slide;
            
            draw_set_alpha(ctrl.stats_popup_alpha);
            draw_sprite_stretched(spr_dice_container, 0, _p_x, _p_y, _p_w, _p_h);
            
            draw_set_font(fnt_gui_button_large);
            draw_set_halign(fa_center); draw_set_valign(fa_top);
            draw_set_color(c_white);
            draw_text(_p_x + _p_w/2, _p_y + 35, "Pawn Statistics");
            
            var _row_y_start = _p_y + 130;
            var _row_gap     = 65;
            var _bar_w       = 380;
            var _bar_h       = 44;
            
            // X Centering Fix: Displaced by approx +35px
            var _icon_x      = _p_x + 85; 
            var _bar_x       = _p_x + 165;
            
            var _hovered_i   = -1;
            
            for (var i = 0; i < array_length(global.stat_data); i++) {
                var _s = global.stat_data[i];
                var _cy = _row_y_start + (i * _row_gap);
                var _is_hover = false;
                
                // Collision Detection Box for Hover/Touch (Icon ONLY)
                var _icon_size = 48; // Estimate
                if (point_in_rectangle(_mx, _my, _icon_x - 20, _cy - 20, _icon_x + _icon_size + 20, _cy + _icon_size + 10)) {
                    _is_hover = true;
                    _hovered_i = i;
                    
                    // Allow touch click on mobile
                    if (mouse_check_button_pressed(mb_left)) {
                        active_tooltip = i;
                    }
                }
                
                var _icon_alpha = _is_hover ? ctrl.stats_popup_alpha : (ctrl.stats_popup_alpha * 0.85);

                draw_sprite_ext(spr_stats, _s.icon, _icon_x, _cy - 10, 1, 1, 0, c_white, _icon_alpha);
                
                draw_set_color(c_white); draw_set_alpha(ctrl.stats_popup_alpha);
                draw_sprite_stretched(spr_target_bar, 0, _bar_x, _cy, _bar_w, _bar_h);
                
                var _val = 5;
                if (instance_exists(obj_controller)) {
                    var _key = string_replace_all(string_lower(_s.name), " ", "_");
                    _val = variable_struct_get(obj_controller.stats, _key);
                }
                
                var _inner_pad_x = 12;
                var _inner_pad_y = 16;
                var _fill_max_w = _bar_w - (_inner_pad_x * 2);
                var _fw = (_val / 10) * _fill_max_w;
                if (_fw > 0) {
                    draw_set_color(_s.color);
                    var _yo = -4;
                    draw_rectangle(_bar_x + _inner_pad_x, _cy + _inner_pad_y + _yo, _bar_x + _inner_pad_x + _fw, _cy + _bar_h - _inner_pad_y + _yo, false);
                }
                
                draw_set_font(fnt_main);
                draw_set_halign(fa_left); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_bar_x + _bar_w + 30, _cy + (_bar_h/2), string(_val) + " / 10");
                
                // Draw a subtle border if active tooltip is this stat
                if (active_tooltip == i || _is_hover) {
                    draw_set_color(_s.color);
                    draw_set_alpha(ctrl.stats_popup_alpha * 0.3);
                    draw_roundrect_ext(_icon_x - 30, _cy - 12, _bar_x + _bar_w + 120, _cy + _bar_h + 10, 20, 20, true);
                    draw_set_alpha(ctrl.stats_popup_alpha);
                }
            }
            
            // X (Close) Button
            var _cx_sz = 64;
            var _cx_x  = _p_x + _p_w - 5; 
            var _cx_y  = _p_y + 5;         
            
            if (draw_gui_button(_cx_x - _cx_sz/2, _cx_y - _cx_sz/2, _cx_sz, _cx_sz, spr_panel_close, "", c_white, fnt_main, true)) {
                ctrl.stats_popup_open = false;
            }
            
            // Tooltip Logic ----------------------------------------------------
            
            // Mouse moves updates hover automatically
            if (_hovered_i != -1) {
                 active_tooltip = _hovered_i;
            } 
            
            // Defocus if clicked outside
            if (_hovered_i == -1 && mouse_check_button_pressed(mb_left)) {
                 active_tooltip = -1;
            }

            if (active_tooltip != -1) {
                tooltip_alpha = lerp(tooltip_alpha, 1.0, 0.2);
            } else {
                tooltip_alpha = lerp(tooltip_alpha, 0.0, 0.2);
            }

            if (tooltip_alpha > 0.01 && active_tooltip != -1) {
                 var _d = global.stat_data[active_tooltip];
                 var _title = _d.name;
                 var _desc  = _d.desc;
                 
                 // Kalkulasi Lebar Judul
                 draw_set_font(fnt_main);
                 var _title_w = string_width(_title) + 10; // Extra breathing room
                 
                 // Kembalikan Skala menjadi 1.0 untuk piksel sempurna (Readability)
                 var _scale = 1.0;
                 var _sep = 30; // Spasi antar baris yang lebih lega
                 var _max_w_internal = 420; // Lebarkan toleransi wrapping agar tidak terlalu memanjang ke bawah
                 
                 var _desc_w_internal = string_width_ext(_desc, _sep, _max_w_internal);
                 var _desc_h_internal = string_height_ext(_desc, _sep, _max_w_internal);
                 
                 var _desc_w_visual = _desc_w_internal * _scale;
                 var _desc_h_visual = _desc_h_internal * _scale;
                 
                 // Tentukan Dimensi Tooltip Dinamis
                 var _pad_x = 24;
                 var _pad_y = 20;
                 var _tw = max(_title_w, _desc_w_visual) + (_pad_x * 2); 
                 var _th = 40 + _desc_h_visual + _pad_y;
                 
                 // Static positioning (Lurus dengan outline)
                 var _t_row_y = _row_y_start + (active_tooltip * _row_gap);
                 var _tx = _icon_x - 30; 
                 var _ty = _t_row_y + _bar_h + 16; 
                 
                 // Edge clamps supaya tidak tembus pinggiran layarnya (termasuk offset pinggiran board)
                 if (_tx + _tw > _gui_w - 20) _tx = _gui_w - _tw - 20;
                 if (_ty + _th > _gui_h - 20) _ty = _gui_h - _th - 20;
                 
                 // Dibungkus Alpha Global & Hover
                 draw_set_alpha(tooltip_alpha * ctrl.stats_popup_alpha);
                 draw_set_color(C_DARKGRAY);
                 draw_roundrect_ext(_tx, _ty, _tx + _tw, _ty + _th, 16, 16, false);
                 
                 draw_set_color(_d.color);
                 draw_roundrect_ext(_tx, _ty, _tx + _tw, _ty + _th, 16, 16, true);
                 
                 // Draw Judul
                 draw_set_halign(fa_left); draw_set_valign(fa_top);
                 draw_set_color(_d.color);
                 draw_text(_tx + _pad_x, _ty + 12, _title);
                 
                 // Draw Deskripsi Tanpa Distorsi Pixel (Scale 1.0)
                 draw_set_color(c_white);
                 draw_text_ext_transformed(_tx + _pad_x, _ty + 42, _desc, _sep, _max_w_internal, _scale, _scale, 0);
            }
            // ------------------------------------------------------------------
            
            draw_set_alpha(1.0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}