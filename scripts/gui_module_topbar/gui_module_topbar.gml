function GuiModuleTopbar(_ctrl) constructor {
    ctrl = _ctrl;

    // State
    intro_timer = 0;
    top_y_offset = -220;
    top_y_target = 0;
    
    stagger_option     = -60;
    stagger_target_bar = -60;
    stagger_cash       = -60;
    stagger_map_stat   = -60;
    
    surf_topbar = -1;

    static step = function() {
        intro_timer += 1;
        var _spd = 0.10;
        
        if (intro_timer > 5)  { top_y_offset = lerp(top_y_offset, top_y_target, _spd); if (abs(top_y_offset - top_y_target) < 0.5) top_y_offset = top_y_target; }
        if (intro_timer > 15) { stagger_option    = lerp(stagger_option,    0, _spd); }
        if (intro_timer > 25) { stagger_target_bar = lerp(stagger_target_bar, 0, _spd); }
        if (intro_timer > 30) { stagger_cash       = lerp(stagger_cash,       0, _spd); }
        if (intro_timer > 35) { stagger_map_stat   = lerp(stagger_map_stat,   0, _spd); }
        
        if (abs(stagger_option)    < 0.5) stagger_option    = 0;
        if (abs(stagger_target_bar)< 0.5) stagger_target_bar = 0;
        if (abs(stagger_cash)      < 0.5) stagger_cash      = 0;
        if (abs(stagger_map_stat)  < 0.5) stagger_map_stat  = 0;
    }

    static draw = function() {
        if (!surface_exists(surf_topbar)) {
            surf_topbar = surface_create(room_width, GUI_TOPBAR_H);
        }
        
        surface_set_target(surf_topbar);
        draw_clear_alpha(c_black, 0);
        draw_sprite_stretched(spr_gui_top_bar, 0, 0, 5, room_width, GUI_TOPBAR_H); 
        
        var _center_y = GUI_TOPBAR_H / 2; 
        var _visual_mid_y = _center_y - 3; 
        var _inner_gap = 12;
        
        draw_set_font(fnt_main); 
        var _label_str = "Target";
        draw_set_font(fnt_gui_button_medium); 
        var _label_x = GUI_PAD_X + GUI_BTN_MAP_W + 30; 
        var _label_w = string_width(_label_str);
        
        var _str_cur = "$0";
        var _str_tgt = " / $0";
        if (instance_exists(obj_controller)) {
            _str_cur = obj_controller.format_money(obj_controller.player_cash);
            _str_tgt = " / " + obj_controller.format_money(obj_controller.map_target);
        } else {
            _str_cur = "$5.000";
            _str_tgt = " / $15.000";
        }
        
        draw_set_font(fnt_gui_button_medium); 
        var _cur_w = string_width(_str_cur);
        var _tgt_w_text = string_width(_str_tgt);
        var _total_num_w = _cur_w + _tgt_w_text;
        var _num_x_start = room_width - GUI_PAD_X - (GUI_BTN_SM_W * 3) - (_inner_gap * 2) - _total_num_w - 40; 
        
        var _tgt_x = _label_x + _label_w + 20; 
        var _tgt_w = (_num_x_start - 20) - _tgt_x; 
        var _tgt_h = GUI_BTN_MAP_H; 
        var _tgt_y = _center_y - (_tgt_h / 2); 
        
        draw_set_font(fnt_gui_button_medium); 
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_color(C_DARKGRAY); 
        draw_text(_label_x + 3, _visual_mid_y + 4, _label_str); 
        draw_set_color(c_white); 
        draw_text(_label_x, _visual_mid_y, _label_str);
        
        var _fill_pct = 0.41; 
        var _inner_y1 = _tgt_y + 12; 
        var _inner_y2 = _tgt_y + _tgt_h - 18; 
        var _fill_pad = 4;
        var _fill_w = (_tgt_w - 24) * _fill_pct; 
        draw_set_color(C_EMERALD); 
        draw_rectangle(_tgt_x + 12, _inner_y1 + _fill_pad, _tgt_x + 12 + _fill_w, _inner_y2 - _fill_pad, false);
        draw_set_color(c_white);
        draw_sprite_stretched(spr_target_bar, 0, _tgt_x, _tgt_y, _tgt_w, _tgt_h);
        
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_font(fnt_gui_button_medium); 
        draw_set_color(c_black); draw_set_alpha(0.3);
        draw_text(_num_x_start + 3, _visual_mid_y + 4, _str_cur); 
        draw_set_alpha(1.0);
        draw_set_color(C_MAIN_GOLD); 
        draw_text(_num_x_start, _visual_mid_y, _str_cur);
        
        draw_set_font(fnt_gui_button_medium); 
        var _tgt_num_x = _num_x_start + _cur_w;
        draw_set_color(c_black); draw_set_alpha(0.3);
        draw_text(_tgt_num_x + 3, _visual_mid_y + 4, _str_tgt); 
        draw_set_alpha(1.0);
        draw_set_color(c_white);
        draw_text(_tgt_num_x, _visual_mid_y, _str_tgt);
        
        draw_set_halign(fa_left); draw_set_valign(fa_top);
        surface_reset_target();
        
        var _tex = surface_get_texture(surf_topbar);
        draw_primitive_begin_texture(pr_trianglestrip, _tex);
        var _segments = 24; 
        var _curve_intensity = -5; 
        for (var i = 0; i <= _segments; i++) {
            var _ratio = i / _segments;
            var _x = _ratio * room_width;
            var _arc = sin(_ratio * pi);
            var _y_offset = _arc * _curve_intensity; 
            draw_vertex_texture(_x, top_y_offset + 0 + _y_offset, _ratio, 0); 
            draw_vertex_texture(_x, top_y_offset + GUI_TOPBAR_H + _y_offset, _ratio, 1); 
        }
        draw_primitive_end();
    }
    
    static draw_buttons = function() {
        var _gui_w = display_get_gui_width();
        
        var _pad_x     = GUI_PAD_X; 
        var _sm_btn_w  = GUI_BTN_SM_W;
        var _sm_btn_h  = GUI_BTN_SM_H;
        var _inner_gap = 12;

        // --- NEW LAYOUT: [MAP] [PAUSE] ---
        // Far Right: Pause Button (Sprite only)
        var _pause_w     = 56; // Square pause button
        var _pause_x     = _gui_w - _pad_x - _pause_w;
        var _top_btn_y   = top_y_offset + (GUI_TOPBAR_H / 2) - (_sm_btn_h / 2) + stagger_map_stat;
        
        if (draw_gui_button(_pause_x, _top_btn_y, _pause_w, _sm_btn_h, spr_button_pause, "", c_white, fnt_main, ctrl.can_interact_gui)) {
            // Options/Pause click logic here
        }

        // Left of Pause: Map Button (Orange)
        var _map_top_x = _pause_x - _inner_gap - _sm_btn_w;
        if (draw_gui_button(_map_top_x, _top_btn_y, _sm_btn_w, _sm_btn_h, spr_button_orange, "Map", c_white, fnt_main, ctrl.can_interact_gui)) {
            ctrl.map_popup_open = true;
        }
    }
    
    static cleanup = function() {
        if (surface_exists(surf_topbar)) surface_free(surf_topbar);
    }
}