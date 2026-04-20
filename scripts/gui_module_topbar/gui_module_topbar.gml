function GuiModuleTopbar(_ctrl) constructor {
    ctrl = _ctrl;

    // State
    intro_timer = 0;
    top_y_offset = -220;
    top_y_target = 24; // Changed from 0 to 24 for top margin
    
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
        var _gui_w = display_get_gui_width();
        var _surf_h = GUI_TOPBAR_H + 80; // Adjusted for taller bar
        
        if (!surface_exists(surf_topbar)) {
            surf_topbar = surface_create(_gui_w, _surf_h);
        }
        
        surface_set_target(surf_topbar);
        draw_clear_alpha(c_black, 0);
        
        var _marg_x = 36; 
        var _bar_w  = _gui_w - (_marg_x * 2);
        var _draw_y_in_surf = 20; // 20px top padding in surface
        draw_sprite_stretched(spr_gui_top_bar, 0, _marg_x, _draw_y_in_surf, _bar_w, GUI_TOPBAR_H); 
        
        var _center_y = _draw_y_in_surf + (GUI_TOPBAR_H / 2); 
        var _visual_mid_y = _center_y + 4; // Adjusted to +4 for better centering of size 32 font

        // --- Draw Map Icon & Progress Plate (Left Side) ---
        var _map_sc     = 0.7; 
        var _map_icon_x = _marg_x + 89; 
        
        // 1. Draw Plate Background (spr_container)
        var _plate_w = 260; // Increased from 210 to 260 for better horizontal margin
        var _plate_h = 76; 
        var _plate_x = _map_icon_x - 30; // Integrate behind circular icon
        var _plate_y = _center_y - (_plate_h / 2);
        draw_sprite_stretched(spr_container, 0, _plate_x, _plate_y, _plate_w, _plate_h);

        // 2. Map Icon (Circular container on top)
        draw_sprite_ext(spr_map_0, 0, _map_icon_x, _center_y, _map_sc, _map_sc, 0, c_white, 1);
        
        // 3. Plate Text (Horizontal Map 1/5)
        var _cur_m = "1";
        var _tot_m = "5";
        if (instance_exists(obj_controller)) {
            _cur_m = string(obj_controller.map_index);
            _tot_m = string(obj_controller.map_total);
        }
        
        var _txt_x_start = _plate_x + 105; // Shifted right for better balance
        var _txt_y_mid   = _center_y + 4;
        var _shd_off     = 3; // Shadow offset
        
        draw_set_valign(fa_middle); draw_set_halign(fa_left);
        
        // --- DRAW SHADOWS FIRST ---
        draw_set_alpha(0.4); draw_set_color(c_black);
        draw_set_font(fnt_main_18);
        draw_text(_txt_x_start + _shd_off, _txt_y_mid + _shd_off, "Map ");
        var _lx_s = _txt_x_start + string_width("Map ");
        draw_set_font(fnt_main_32);
        draw_text(_lx_s + _shd_off, _txt_y_mid + _shd_off, _cur_m + "/" + _tot_m);
        draw_set_alpha(1.0);

        // --- DRAW MAIN TEXT ---
        // "Map " prefix
        draw_set_font(fnt_main_18);
        draw_set_color(c_white);
        draw_text(_txt_x_start, _txt_y_mid - 2, "Map "); // Small -2px offset for visual alignment
        var _lx = _txt_x_start + string_width("Map ");
        
        // Numbers
        draw_set_font(fnt_main_32);
        draw_set_color(C_MAIN_GOLD);
        draw_text(_lx, _txt_y_mid, _cur_m);
        var _nx = _lx + string_width(_cur_m);
        
        draw_set_color(c_white);
        draw_text(_nx, _txt_y_mid, "/" + _tot_m);
        
        // --- Calculate Total Width for Centering ---
        draw_set_font(fnt_main_32); 
        var _label_str = "Target";
        var _label_w = string_width(_label_str);
        
        var _str_cur = "$0";
        var _str_tgt = " / $0";
        if (instance_exists(obj_controller)) {
            _str_cur = obj_controller.format_money(obj_controller.player_cash);
            _str_tgt = " / " + obj_controller.format_money(obj_controller.map_target);
        }
        
        var _cur_w = string_width(_str_cur);
        var _tgt_w_full_text = string_width(_str_tgt);
        
        var _bar_tgt_w = 420; // Progress bar width
        var _gap1 = 25; // Gap between label and bar
        var _gap2 = 25; // Gap between bar and numbers
        
        var _total_group_w = _label_w + _gap1 + _bar_tgt_w + _gap2 + _cur_w + _tgt_w_full_text;
        
        // Starting X for Centered Layout
        var _group_start_x = (_gui_w / 2) - (_total_group_w / 2);
        
        var _label_x = _group_start_x;
        var _tgt_x   = _label_x + _label_w + _gap1;
        var _tgt_h   = 46; 
        var _tgt_y   = _center_y - (_tgt_h / 2); 
        var _num_x_start = _tgt_x + _bar_tgt_w + _gap2;
        
        // --- Draw Centered Elements ---
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_color(C_DARKGRAY); 
        draw_text(_label_x + 3, _visual_mid_y + 4, _label_str); 
        draw_set_color(c_white); 
        draw_text(_label_x, _visual_mid_y, _label_str);
        
        var _fill_pct = 0.41; 
        var _fill_pad = 4;
        var _fill_w = (_bar_tgt_w - 24) * _fill_pct; 
        draw_set_color(C_EMERALD); 
        draw_rectangle(_tgt_x + 12, _tgt_y + _fill_pad + 6, _tgt_x + 12 + _fill_w, _tgt_y + _tgt_h - _fill_pad - 6, false);
        draw_set_color(c_white);
        draw_sprite_stretched(spr_target_bar, 0, _tgt_x, _tgt_y, _bar_tgt_w, _tgt_h);
        
        draw_set_halign(fa_left); draw_set_valign(fa_middle);
        draw_set_color(c_black); draw_set_alpha(0.3);
        draw_text(_num_x_start + 3, _visual_mid_y + 4, _str_cur); 
        draw_set_alpha(1.0);
        draw_set_color(C_MAIN_GOLD); 
        draw_text(_num_x_start, _visual_mid_y, _str_cur);
        
        var _tgt_num_x = _num_x_start + _cur_w;
        draw_set_color(c_black); draw_set_alpha(0.3);
        draw_text(_tgt_num_x + 3, _visual_mid_y + 4, _str_tgt); 
        draw_set_alpha(1.0);
        draw_set_color(c_white);
        draw_text(_tgt_num_x, _visual_mid_y, _str_tgt);
        
        draw_set_halign(fa_left); draw_set_valign(fa_top);
        surface_reset_target();
        
        var _tex = surface_get_texture(surf_topbar);
        var _segments = 128; 
        var _curve_intensity = -10; 
        
        gpu_set_tex_filter(true);
        draw_primitive_begin_texture(pr_trianglestrip, _tex);
        for (var i = 0; i <= _segments; i++) {
            var _ratio = i / _segments;
            var _x = _ratio * _gui_w;
            var _arc = sin(_ratio * pi);
            var _y_off = _arc * _curve_intensity; 
            draw_vertex_texture_color(_x, top_y_offset + _y_off, _ratio, 0, c_white, 1); 
            draw_vertex_texture_color(_x, top_y_offset + _surf_h + _y_off, _ratio, 1, c_white, 1); 
        }
        draw_primitive_end();
        gpu_set_tex_filter(false);
    }
    
    static draw_buttons = function() {
        var _gui_w = display_get_gui_width();
        var _marg_x    = 36; 
        var _bar_w     = _gui_w - (_marg_x * 2);
        
        // --- High-Fidelity Button Sizes ---
        var _btn_h     = 60; 
        var _map_w     = 120; // Slightly wider for the new sprite
        var _pause_w   = 60; 
        
        var _surf_v_offset = 20; 
        var _top_btn_y = top_y_offset + _surf_v_offset + (GUI_TOPBAR_H / 2) - (_btn_h / 2) + stagger_map_stat;
        
        // Increased safety margin from the right edge (from 70 to 100)
        var _pause_x   = _marg_x + _bar_w - 100; 
        
        // Draw Pause Button
        if (draw_gui_button(_pause_x, _top_btn_y, _pause_w, _btn_h, spr_button_pause, "", c_white, fnt_main_18, ctrl.can_interact_gui)) {
        }

        // Draw Map Button
        var _gap_size = 18; 
        var _group_gap = 60; // Increased gap to separate Pause from Map/Skills group
        var _map_top_x = _pause_x - _group_gap - _map_w;
        if (draw_gui_button(_map_top_x, _top_btn_y, _map_w, _btn_h, spr_btn_top_bar, "Map", c_white, fnt_main_18, ctrl.can_interact_gui)) {
            ctrl.map_popup_open = true;
        }

        // Draw Skills Button
        var _skills_w = 120;
        var _skills_x = _map_top_x - _gap_size - _skills_w;
        if (draw_gui_button(_skills_x, _top_btn_y, _skills_w, _btn_h, spr_btn_top_bar_skills, "Skills", c_white, fnt_main_18, ctrl.can_interact_gui)) {
            ctrl.skills_popup_open = true;
        }
    }
    
    static cleanup = function() {
        if (surface_exists(surf_topbar)) surface_free(surf_topbar);
    }
}