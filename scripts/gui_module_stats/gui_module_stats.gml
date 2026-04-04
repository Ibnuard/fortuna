function GuiModuleStats(_ctrl) constructor {
    ctrl = _ctrl;
    
    // Kept in obj_gui logically maybe? No, let's put in ctrl if other objects read it, OR here:
    // It's local here but triggered via obj_gui? The toggle is usually from mod_topbar reading `ctrl.stats_popup_open`
    // We already moved `ctrl.stats_popup_open = true` in mod_topbar! So obj_gui still needs to store the core variables.

    static step = function() {
        var _stats_target = ctrl.stats_popup_open ? 1.0 : 0.0;
        var _slide_target = ctrl.stats_popup_open ? 0.0 : 100.0;

        ctrl.stats_popup_alpha = lerp(ctrl.stats_popup_alpha, _stats_target, 0.15);
        if (abs(ctrl.stats_popup_alpha - _stats_target) < 0.005) ctrl.stats_popup_alpha = _stats_target;

        ctrl.stats_popup_y_slide = lerp(ctrl.stats_popup_y_slide, _slide_target, 0.15);
        if (abs(ctrl.stats_popup_y_slide - _slide_target) < 0.1) ctrl.stats_popup_y_slide = _slide_target;
    }

    static draw = function() {
        if (ctrl.stats_popup_alpha > 0) {
            var _gui_w = display_get_gui_width();
            var _gui_h = display_get_gui_height();
            
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
            var _bar_x       = _p_x + 130;
            
            for (var i = 0; i < array_length(global.stat_data); i++) {
                var _s = global.stat_data[i];
                var _cy = _row_y_start + (i * _row_gap);
                
                draw_sprite_ext(spr_stats, _s.icon, _p_x + 50, _cy - 10, 1, 1, 0, c_white, ctrl.stats_popup_alpha);
                
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
            }
            
            var _cx_sz = 64;
            var _cx_x  = _p_x + _p_w - 5; 
            var _cx_y  = _p_y + 5;         
            
            if (draw_gui_button(_cx_x - _cx_sz/2, _cx_y - _cx_sz/2, _cx_sz, _cx_sz, spr_panel_close, "", c_white, fnt_main, true)) {
                ctrl.stats_popup_open = false;
            }
            
            draw_set_alpha(1.0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}