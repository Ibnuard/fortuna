function GuiModuleMap(_ctrl) constructor {
    ctrl = _ctrl;
    
    static step = function() {
        var _target = ctrl.map_popup_open ? 1.0 : 0.0;
        var _slide_target = ctrl.map_popup_open ? 0.0 : 80.0;
        
        ctrl.map_popup_alpha = lerp(ctrl.map_popup_alpha, _target, 0.15);
        if (abs(ctrl.map_popup_alpha - _target) < 0.005) ctrl.map_popup_alpha = _target;
        
        ctrl.map_popup_y_slide = lerp(ctrl.map_popup_y_slide, _slide_target, 0.15);
        if (abs(ctrl.map_popup_y_slide - _slide_target) < 0.1) ctrl.map_popup_y_slide = _slide_target;
    }
    
    static draw = function() {
        if (ctrl.map_popup_alpha <= 0) return;
        
        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        
        // Dim Background
        draw_set_color(c_black);
        draw_set_alpha(ctrl.map_popup_alpha * 0.7);
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
        
        // --- DYNAMIC DIMENSIONS (Increased for Pawn clearance) ---
        var _board_size_px = 440; 
        var _header_h = 160; // More vertical space as requested
        var _edge_padding = 100;
        
        var _p_w = _board_size_px + (_edge_padding * 2);
        var _p_h = _board_size_px + _header_h + _edge_padding;
        
        var _p_x = (_gui_w / 2) - (_p_w / 2);
        var _p_y = (_gui_h / 2) - (_p_h / 2) + ctrl.map_popup_y_slide;
        
        draw_set_alpha(ctrl.map_popup_alpha);
        draw_sprite_stretched(spr_dice_container, 0, _p_x, _p_y, _p_w, _p_h);
        
        // Close Button
        var _cx_sz = 64;
        var _cx_x  = _p_x + _p_w - 5; 
        var _cx_y  = _p_y + 5;         
        if (draw_gui_button(_cx_x - _cx_sz/2, _cx_y - _cx_sz/2, _cx_sz, _cx_sz, spr_panel_close, "", c_white, fnt_main, true)) {
            ctrl.map_popup_open = false;
        }

        // Header
        var _level_num = 1;
        if (instance_exists(obj_board)) {
            var _tc = array_length(obj_board.tiles);
            if (_tc == 16) _level_num = 1;
            else if (_tc == 20) _level_num = 2;
            else if (_tc == 24) _level_num = 3;
        }
        
        var _map_name = "Map Indonesia";
        if (_level_num == 2) _map_name = "Map Asia";
        if (_level_num == 3) _map_name = "Map World";
        
        var _title_x = _p_x + _p_w/2;
        var _title_y = _p_y + 50;
        
        draw_set_font(fnt_gui_button_large);
        draw_set_halign(fa_center); draw_set_valign(fa_top);
        
        // Title Shadow
        draw_set_color(c_black); draw_set_alpha(0.5 * ctrl.map_popup_alpha);
        draw_text(_title_x + 4, _title_y + 4, _map_name);
        
        // Title Main
        draw_set_color(c_white); draw_set_alpha(ctrl.map_popup_alpha);
        draw_text(_title_x, _title_y, _map_name);
        
        // --- Map Board (Centered with Pawn clearance) ---
        var _bx = _p_x + _edge_padding;
        var _by = _p_y + _header_h;
        
        if (instance_exists(obj_board)) {
            var _total_tiles = array_length(obj_board.tiles);
            var _grid_size   = (_total_tiles + 4) / 4;
            var _tiles_px    = _board_size_px / _grid_size;
            var _edge_len    = _grid_size - 1;
            
            // 2. Draw Active Tiles (Perimeter Logic)
            for (var i = 0; i < _total_tiles; i++) {
                var _tx_grid = 0, _ty_grid = 0;
                
                // Continuous Perimeter Mapping
                if (i < _edge_len) { _tx_grid = _edge_len - i; _ty_grid = _edge_len; }
                else if (i < 2 * _edge_len) { _tx_grid = 0; _ty_grid = _edge_len - (i - _edge_len); }
                else if (i < 3 * _edge_len) { _tx_grid = i - 2 * _edge_len; _ty_grid = 0; }
                else { _tx_grid = _edge_len; _ty_grid = i - 3 * _edge_len; }
                
                var _render_x = _bx + (_tx_grid * _tiles_px);
                var _render_y = _by + (_ty_grid * _tiles_px);
                
                var _tile_data = obj_board.tiles[i];
                var _tile_sprite = _tile_data.sprite;
                var _scale_x = (_tiles_px - 8) / sprite_get_width(_tile_sprite);
                var _scale_y = (_tiles_px - 8) / sprite_get_height(_tile_sprite);
                
                // Shadow
                draw_set_color(c_black); draw_set_alpha(0.4 * ctrl.map_popup_alpha);
                draw_rectangle(_render_x + 8, _render_y + 8, _render_x + _tiles_px, _render_y + _tiles_px, false);
                
                // Tile
                draw_set_alpha(ctrl.map_popup_alpha);
                draw_sprite_ext(_tile_sprite, 0, _render_x + 4, _render_y + 4, _scale_x, _scale_y, 0, c_white, ctrl.map_popup_alpha);
                
                // Active Tile Highlight (White Border)
                if (i == obj_board.player_index) {
                    draw_set_color(c_white);
                    for (var _th = 0; _th < 4; _th++) {
                        draw_rectangle(_render_x + 2 + _th, _render_y + 2 + _th, _render_x + _tiles_px - 2 - _th, _render_y + _tiles_px - 2 - _th, true);
                    }
                }
            }
            
            // 3. Draw Pawn (Separate Pass for Depth)
            var i = obj_board.player_index;
            var _tx_grid = 0, _ty_grid = 0;
            if (i < _edge_len) { _tx_grid = _edge_len - i; _ty_grid = _edge_len; }
            else if (i < 2 * _edge_len) { _tx_grid = 0; _ty_grid = _edge_len - (i - _edge_len); }
            else if (i < 3 * _edge_len) { _tx_grid = i - 2 * _edge_len; _ty_grid = 0; }
            else { _tx_grid = _edge_len; _ty_grid = i - 3 * _edge_len; }
            
            var _px = _bx + (_tx_grid * _tiles_px) + (_tiles_px / 2);
            var _py = _by + (_ty_grid * _tiles_px) + (_tiles_px / 2);
            
            var _psp = spr_pawn;
            var _psc = (_tiles_px * 0.6) / sprite_get_height(_psp); // Smaller as requested
            var _pw = sprite_get_width(_psp) * _psc;
            var _ph = sprite_get_height(_psp) * _psc;
            
            var _idle_y = sin(current_time * 0.005) * (8 * ctrl.map_popup_alpha);
            var _final_x = _px - (_pw / 2);
            var _final_y = _py - _ph + _idle_y;
            
            // Shadow
            draw_sprite_ext(_psp, 0, _final_x + 3, _final_y - _idle_y + 3, _psc, _psc, 0, c_black, 0.3 * ctrl.map_popup_alpha);
            // Main
            draw_sprite_ext(_psp, 0, _final_x, _final_y, _psc, _psc, 0, c_white, ctrl.map_popup_alpha);
        }
        
        draw_set_alpha(1.0);
    }
}
