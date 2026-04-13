function GuiModuleMap(_ctrl) constructor {
    ctrl = _ctrl;
    hovered_index  = -1;
    selected_index = -1;
    preview_alpha  = 0.0;
    
    static step = function() {
        var _target = ctrl.map_popup_open ? 1.0 : 0.0;
        var _slide_target = ctrl.map_popup_open ? 0.0 : 80.0;
        
        ctrl.map_popup_alpha = lerp(ctrl.map_popup_alpha, _target, 0.15);
        if (abs(ctrl.map_popup_alpha - _target) < 0.005) ctrl.map_popup_alpha = _target;
        
        ctrl.map_popup_y_slide = lerp(ctrl.map_popup_y_slide, _slide_target, 0.15);
        if (abs(ctrl.map_popup_y_slide - _slide_target) < 0.1) ctrl.map_popup_y_slide = _slide_target;

        // Interaction Block
        if (ctrl.map_popup_alpha > 0.8 && instance_exists(obj_board)) {
            var _gui_w = display_get_gui_width();
            var _gui_h = display_get_gui_height();
            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);
            
            var _board_size_px = 340; 
            var _header_h = 120;
            var _edge_padding = 80;
            var _p_w = _board_size_px + (_edge_padding * 2);
            var _p_h = _board_size_px + _header_h + _edge_padding;
            var _p_x = (_gui_w / 2) - (_p_w / 2);
            var _p_y = (_gui_h / 2) - (_p_h / 2) + ctrl.map_popup_y_slide;
            var _bx = _p_x + _edge_padding;
            var _by = _p_y + _header_h;
            
            var _total_tiles = array_length(obj_board.tiles);
            var _grid_size = (_total_tiles + 4) / 4;
            var _tiles_px = _board_size_px / _grid_size;
            var _edge_len = _grid_size - 1;
            
            hovered_index = -1;
            for (var i = 0; i < _total_tiles; i++) {
                var _tx_grid = 0, _ty_grid = 0;
                if (i < _edge_len) { _tx_grid = _edge_len - i; _ty_grid = _edge_len; }
                else if (i < 2 * _edge_len) { _tx_grid = 0; _ty_grid = _edge_len - (i - _edge_len); }
                else if (i < 3 * _edge_len) { _tx_grid = i - 2 * _edge_len; _ty_grid = 0; }
                else { _tx_grid = _edge_len; _ty_grid = i - 3 * _edge_len; }
                
                var _rx = _bx + (_tx_grid * _tiles_px);
                var _ry = _by + (_ty_grid * _tiles_px);
                
                if (point_in_rectangle(_mx, _my, _rx, _ry, _rx + _tiles_px, _ry + _tiles_px)) {
                    hovered_index = i;
                    if (mouse_check_button_pressed(mb_left)) {
                        selected_index = (selected_index == i) ? -1 : i; // Toggle selection
                    }
                }
            }
            
            // Defocus if click empty center or outside
            if (mouse_check_button_pressed(mb_left) && hovered_index == -1) {
                selected_index = -1;
            }
        } else {
            hovered_index = -1;
            selected_index = -1;
        }
        
        var _p_target = (hovered_index != -1 || selected_index != -1) ? 1.0 : 0.0;
        preview_alpha = lerp(preview_alpha, _p_target, 0.2);
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
        var _board_size_px = 340; 
        var _header_h = 120; 
        var _edge_padding = 80;
        
        var _p_w = _board_size_px + (_edge_padding * 2);
        var _p_h = _board_size_px + _header_h + _edge_padding;
        
        var _p_x = (_gui_w / 2) - (_p_w / 2);
        var _p_y = (_gui_h / 2) - (_p_h / 2) + ctrl.map_popup_y_slide;
        
        draw_set_alpha(ctrl.map_popup_alpha);
        draw_sprite_stretched(spr_container, 0, _p_x, _p_y, _p_w, _p_h);
        
        // Close Button
        var _cx_sz = 64;
        var _cx_x  = _p_x + _p_w - 5; 
        var _cx_y  = _p_y + 5;         
        if (draw_gui_button(_cx_x - _cx_sz/2, _cx_y - _cx_sz/2, _cx_sz, _cx_sz, spr_panel_close, "", c_white, fnt_main_18, true)) {
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
        var _title_y = _p_y + 25;
        
        draw_set_font(fnt_main_54);
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
                
                // Hover/Selection Highlight
                if (i == hovered_index || i == selected_index) {
                    draw_set_color(c_yellow); draw_set_alpha(0.3 * ctrl.map_popup_alpha);
                    draw_rectangle(_render_x, _render_y, _render_x + _tiles_px, _render_y + _tiles_px, false);
                    draw_set_alpha(1.0);
                }
            }
            
            // 3. Draw Pawn (Separate Pass for Depth)
            var _pi = obj_board.player_index;
            var _ptx = 0, _pty = 0;
            if (_pi < _edge_len) { _ptx = _edge_len - _pi; _pty = _edge_len; }
            else if (_pi < 2 * _edge_len) { _ptx = 0; _pty = _edge_len - (_pi - _edge_len); }
            else if (_pi < 3 * _edge_len) { _ptx = _pi - 2 * _edge_len; _pty = 0; }
            else { _ptx = _edge_len; _pty = _pi - 3 * _edge_len; }
            
            var _ppx = _bx + (_ptx * _tiles_px) + (_tiles_px / 2);
            var _ppy = _by + (_pty * _tiles_px) + (_tiles_px / 2);
            
            var _psp = spr_pawn;
            var _psc = (_tiles_px * 0.6) / sprite_get_height(_psp); 
            var _pw = sprite_get_width(_psp) * _psc;
            var _ph = sprite_get_height(_psp) * _psc;
            var _idle_y = sin(current_time * 0.005) * (8 * ctrl.map_popup_alpha);
            var _final_x = _ppx - (_pw / 2);
            var _final_y = _ppy - _ph + _idle_y;
            
            draw_sprite_ext(_psp, 0, _final_x + 3, _final_y - _idle_y + 3, _psc, _psc, 0, c_black, 0.3 * ctrl.map_popup_alpha);
            draw_sprite_ext(_psp, 0, _final_x, _final_y, _psc, _psc, 0, c_white, ctrl.map_popup_alpha);

            // 4. Tile Preview Tooltip -------------------------------------------
            if (preview_alpha > 0.01) {
                var _act_i = (selected_index != -1) ? selected_index : hovered_index;
                if (_act_i != -1) {
                    var _data = obj_board.tiles[_act_i];
                    var _at_x = 0, _at_y = 0;
                    if (_act_i < _edge_len) { _at_x = _edge_len - _act_i; _at_y = _edge_len; }
                    else if (_act_i < 2 * _edge_len) { _at_x = 0; _at_y = _edge_len - (_act_i - _edge_len); }
                    else if (_act_i < 3 * _edge_len) { _at_x = _act_i - 2 * _edge_len; _at_y = 0; }
                    else { _at_x = _edge_len; _at_y = _act_i - 3 * _edge_len; }
                    
                    var _tile_x = _bx + (_at_x * _tiles_px);
                    var _tile_y = _by + (_at_y * _tiles_px);
                    
                    // Tooltip Dimens
                    var _tw = 260;
                    var _th = 400;
                    var _gap = 20;
                    var _tx = 0, _ty = 0;
                    
                    // Relative Position (Point Inwards)
                    if (_act_i < _edge_len) { // Bottom
                        _tx = _tile_x + (_tiles_px/2) - (_tw/2);
                        _ty = _tile_y - _th - _gap;
                    } else if (_act_i < 2 * _edge_len) { // Left
                        _tx = _tile_x + _tiles_px + _gap;
                        _ty = _tile_y + (_tiles_px/2) - (_th/2);
                    } else if (_act_i < 3 * _edge_len) { // Top
                        _tx = _tile_x + (_tiles_px/2) - (_tw/2);
                        _ty = _tile_y + _tiles_px + _gap;
                    } else { // Right
                        _tx = _tile_x - _tw - _gap;
                        _ty = _tile_y + (_tiles_px/2) - (_th/2);
                    }
                    
                    // Clamp to keep inside Map Panel
                    _tx = clamp(_tx, _p_x + 10, _p_x + _p_w - _tw - 10);
                    _ty = clamp(_ty, _p_y + 80, _p_y + _p_h - _th - 10);
                    
                    var _a = preview_alpha * ctrl.map_popup_alpha;
                    var _is_owned = (_data.owner != -1);
                    
                    // Stats-style Background (Rounded Rect)
                    draw_set_alpha(_a);
                    draw_set_color(#1A1A1A); // Dark charcoal
                    draw_roundrect_ext(_tx, _ty, _tx + _tw, _ty + _th, 16, 16, false);
                    
                    var _border_col = _is_owned ? c_lime : c_ltgray;
                    draw_set_color(_border_col);
                    draw_roundrect_ext(_tx, _ty, _tx + _tw, _ty + _th, 16, 16, true);
                    
                    // Header: Ownership
                    draw_set_font(fnt_main_18); draw_set_halign(fa_center);
                    draw_set_alpha(0.8 * _a);
                    draw_text(_tx + _tw/2, _ty + 15, _is_owned ? "[ OWNED ]" : "[ NOT OWNED ]");
                    
                    // Center: Tile Card (Respect Aspect Ratio)
                    var _isp = _data.sprite;
                    var _orig_w = 130;
                    var _orig_h = 182;
                    
                    // Slightly larger as requested
                    var _card_w = _tw - 60;
                    var _isc    = _card_w / _orig_w;
                    var _card_h = _orig_h * _isc;
                    
                    var _card_x = _tx + (_tw/2) - (_card_w/2);
                    var _card_y = _ty + 50;
                    
                    // 1. Draw Base Tile
                    draw_set_alpha(_a);
                    draw_sprite_ext(_isp, 0, _card_x, _card_y, _isc, _isc, 0, c_white, _a);
                    
                    // 2. Draw Icon on Tile (Reproduction of board logic)
                    var _icon_idx = _data.type;
                    var _icon_sc  = _isc * 0.75;
                    var _icon_sw  = sprite_get_width(spr_tile_icons) * _icon_sc;
                    var _icon_x   = _card_x + (_card_w/2) - (_icon_sw/2);
                    var _icon_y   = _card_y + (4 * _isc);
                    draw_sprite_ext(spr_tile_icons, _icon_idx, _icon_x, _icon_y, _icon_sc, _icon_sc, 0, c_white, _a);
                    
                    // 3. Nama Tile (Inside Card Body)
                    var _label_y = _card_y + (_card_h / 2) + (12 * _isc);
                    var _label_str = string_upper(_data.name);
                    var _label_scale_x = 1.0;
                    var _label_scale_y = 1.0;
                    var _label_sep     = 32 * _isc;
                    var _label_w_limit = (_card_w - (20 * _isc)) / _label_scale_x;
                    
                    draw_set_color(c_black); draw_set_alpha(0.4 * _a);
                    draw_text_ext_transformed(_card_x + _card_w/2 + 2, _label_y + 2, _label_str, _label_sep, _label_w_limit, _label_scale_x, _label_scale_y, 0);
                    draw_set_color(c_white); draw_set_alpha(_a);
                    draw_text_ext_transformed(_card_x + _card_w/2, _label_y, _label_str, _label_sep, _label_w_limit, _label_scale_x, _label_scale_y, 0);
                    
                    // 4. Harga / Info (Inside Card Bottom)
                    var _info_y   = _card_y + _card_h - (22 * _isc);
                    var _info_str = "";
                    switch(_data.type) {
                        case TileType.Start:   _info_str = "+ $1000"; break;
                        case TileType.Fate:    _info_str = "DRAW";    break;
                        case TileType.Market:  _info_str = "SHOP";    break;
                        case TileType.Casino:  _info_str = "BET";     break;
                        case TileType.Jail:    _info_str = "OOPS";    break;
                        case TileType.Property: _info_str = "$" + string(_data.price); break;
                    }
                    
                    var _info_scale_x = 1.0;
                    var _info_scale_y = 1.0;
                    
                    draw_set_color(c_black); draw_set_alpha(0.5 * _a);
                    draw_text_transformed(_card_x + _card_w/2 + 2, _info_y + 2, _info_str, _info_scale_x, _info_scale_y, 0);
                    draw_set_color(c_white); draw_set_alpha(_a);
                    draw_text_transformed(_card_x + _card_w/2, _info_y, _info_str, _info_scale_x, _info_scale_y, 0);

                    // Footer: X to GO (Outside Card)
                    var _total = array_length(obj_board.tiles);
                    var _dist = (_act_i - obj_board.player_index + _total) % _total;
                    
                    draw_set_color(c_white); draw_set_alpha(0.3 * _a);
                    draw_line(_tx + 30, _ty + _th - 45, _tx + _tw - 30, _ty + _th - 45);
                    
                    draw_set_alpha(_a);
                    draw_set_color(#FFD700);
                    draw_text(_tx + _tw/2, _ty + _th - 35, string(_dist) + " STEPS TO GO");
                }
            }
        }
        
        draw_set_alpha(1.0);
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }
}
