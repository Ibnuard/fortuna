function GuiModuleStats(_ctrl) constructor {
    ctrl = _ctrl;
    
    static step = function() {
        var _stats_target = ctrl.stats_popup_open ? 1.0 : 0.0;
        var _slide_target = ctrl.stats_popup_open ? 0.0 : 100.0;

        ctrl.stats_popup_alpha = lerp(ctrl.stats_popup_alpha, _stats_target, 0.15);
        if (abs(ctrl.stats_popup_alpha - _stats_target) < 0.005) ctrl.stats_popup_alpha = _stats_target;

        ctrl.stats_popup_y_slide = lerp(ctrl.stats_popup_y_slide, _slide_target, 0.15);
        if (abs(ctrl.stats_popup_y_slide - _slide_target) < 0.1) ctrl.stats_popup_y_slide = _slide_target;
    }

    static draw = function() {
        if (ctrl.stats_popup_alpha > 0.01) {
            var _gui_w = display_get_gui_width();
            var _gui_h = display_get_gui_height();
            
            // Dim background
            draw_set_color(c_black);
            draw_set_alpha(ctrl.stats_popup_alpha * 0.6);
            draw_rectangle(0, 0, _gui_w, _gui_h, false);
            
            var _num_stats = array_length(global.pawn_stats_data);
            var _p_w = 620; // Narrower panel for a compact feel
            var _row_gap = 72; 
            var _header_h = 110;
            var _footer_h = 40;
            var _p_h = _header_h + (_num_stats * _row_gap) + _footer_h;
            
            var _p_x = (_gui_w / 2) - (_p_w / 2);
            var _p_y = (_gui_h / 2) - (_p_h / 2) + ctrl.stats_popup_y_slide;
            
            // Main Panel
            draw_set_alpha(ctrl.stats_popup_alpha);
            draw_sprite_stretched(spr_container, 0, _p_x, _p_y, _p_w, _p_h);
            
            // Header
            draw_set_font(fnt_main_54);
            draw_set_halign(fa_center); draw_set_valign(fa_top);
            draw_set_color(c_white);
            draw_text(_p_x + _p_w/2, _p_y + 25, "Pawn Statistics");
            
            var _row_y_start = _p_y + _header_h;
            
            // FIXED ALIGNMENT POINTS (Compact & Justified)
            var _icon_col_x  = _p_x + 60; 
            var _label_col_x = _icon_col_x + 50; 
            var _colon_col_x = _label_col_x + 280; // Fixed vertical line for colons
            var _value_col_x = _p_x + _p_w - 60;   // Right-aligned column
            
            for (var i = 0; i < _num_stats; i++) {
                var _s = global.pawn_stats_data[i];
                var _cy = _row_y_start + (i * _row_gap);
                
                var _val = 0;
                var _val_str = "0";
                
                if (instance_exists(obj_controller)) {
                    var _key = "";
                    switch(_s.name) {
                        case "Total Property Owned": _key = "properties_owned"; break;
                        case "Total House":          _key = "houses_owned"; break;
                        case "Total Hotel":          _key = "hotels_owned"; break;
                        case "Income / Turn":       _key = "passive_income"; break;
                        case "Tax Rate":             _key = "tax_rate"; break;
                        case "Tax / Turn":           _key = "tax_per_turn"; break;
                        case "Net / Turn":           _key = "net_income"; break;
                    }
                    
                    if (_key != "") {
                        _val = variable_struct_get(obj_controller.pawn_stats, _key);
                    }
                    
                    if (_s.type == "currency") {
                        _val_str = obj_controller.format_money(_val);
                    } else if (_s.type == "percent") {
                        _val_str = string(_val) + "%";
                    } else {
                        _val_str = string(_val);
                    }
                }
                
                var _icon_scale    = 0.7;
                var _v_mid         = _cy + (_row_gap / 2) - 10;
                var _lbl_txt_scale = 1.0;
                var _val_txt_scale = 1.0;
                
                // Draw Icon
                draw_sprite_ext(spr_stats, _s.icon, _icon_col_x, _v_mid, _icon_scale, _icon_scale, 0, c_white, ctrl.stats_popup_alpha);
                
                // Draw Label
                draw_set_font(fnt_main_18);
                draw_set_halign(fa_left); draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text_transformed(_label_col_x, _v_mid, _s.name, _lbl_txt_scale, _lbl_txt_scale, 0);
                draw_text_transformed(_colon_col_x, _v_mid, ":", _lbl_txt_scale, _lbl_txt_scale, 0);
                
                // Draw Value (Right Aligned - Larger & Clearer)
                draw_set_halign(fa_right);
                draw_set_color(C_MAIN_GOLD);
                draw_text_transformed(_value_col_x, _v_mid, _val_str, _val_txt_scale, _val_txt_scale, 0);
            }
            
            // Close Button
            var _cx_sz = 64;
            var _cx_x  = _p_x + _p_w - 5; 
            var _cx_y  = _p_y + 5;         
            if (draw_gui_button(_cx_x - _cx_sz/2, _cx_y - _cx_sz/2, _cx_sz, _cx_sz, spr_panel_close, "", c_white, fnt_main_18, true)) {
                ctrl.stats_popup_open = false;
            }
            
            draw_set_alpha(1.0);
            draw_set_halign(fa_left); draw_set_valign(fa_top);
        }
    }
}
