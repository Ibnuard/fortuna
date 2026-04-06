function GuiModuleProperty(_ctrl) constructor {
    ctrl = _ctrl;

    property_y_offset = 800;
    panel_scroll_y = 0;
    panel_scroll_target = 0;
    panel_max_scroll = 0;
    surf_panel = -1;
    is_dragging_panel = false;
    drag_start_y = 0;
    scroll_start = 0;

    static step = function() {
        var _target_prop_offset = (ctrl.gui_state == "PROPERTY") ? 0 : 800;
        
        if (abs(property_y_offset - _target_prop_offset) > 0.5) {
            property_y_offset = lerp(property_y_offset, _target_prop_offset, ctrl.animation_speed);
        } else {
            property_y_offset = _target_prop_offset;
        }

        if (ctrl.gui_state == "PROPERTY" && property_y_offset < 790) {
            var _scroll_speed = 65;
            if (mouse_wheel_up())   panel_scroll_target -= _scroll_speed;
            if (mouse_wheel_down()) panel_scroll_target += _scroll_speed;

            var _my = device_mouse_y_to_gui(0);
            var _panel_actual_y = _target_prop_offset + (room_height - (room_height * 0.6) + 50);
            
            if (mouse_check_button_pressed(mb_left) && _my > _panel_actual_y) {
                is_dragging_panel = true;
                drag_start_y  = _my;
                scroll_start  = panel_scroll_target;
            }
            
            if (is_dragging_panel) {
                if (mouse_check_button(mb_left)) {
                    panel_scroll_target = scroll_start + (drag_start_y - _my);
                } else {
                    is_dragging_panel = false;
                }
            }
            
            panel_scroll_target = clamp(panel_scroll_target, 0, panel_max_scroll);
            panel_scroll_y = lerp(panel_scroll_y, panel_scroll_target, 0.2);
        } else {
            panel_scroll_target = 0;
            panel_scroll_y      = 0;
            is_dragging_panel   = false;
        }
    }

    static draw = function() {
        if (property_y_offset > 795) return;
        
        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _mx    = device_mouse_x_to_gui(0);
        var _my    = device_mouse_y_to_gui(0);
        
        // --- Overlay Background ---
        var _overlay_alpha = lerp(0.5, 0, clamp(property_y_offset / 800, 0, 1));
        draw_set_color(c_black);
        draw_set_alpha(_overlay_alpha);
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
        
        // --- Panel Dimensions (Compact Look - Slightly taller for spacing) ---
        var _p_w = 620;
        var _p_h = 630;
        var _p_x = (_gui_w / 2) - (_p_w / 2);
        var _p_y = (_gui_h / 2) - (_p_h / 2) + property_y_offset;
        
        draw_set_alpha(1.0);
        draw_sprite_stretched(spr_container, 0, _p_x, _p_y, _p_w, _p_h);
        
        // --- Title (Top) ---
        draw_set_font(fnt_gui_button_large);
        draw_set_halign(fa_center); draw_set_valign(fa_top);
        draw_set_color(c_white);
        draw_text(_p_x + _p_w/2, _p_y + 25, "Property");
        
        // --- Close Button ---
        var _cx_sz = 64;
        if (draw_gui_button(_p_x + _p_w - 5 - (_cx_sz/2), _p_y + 5 - (_cx_sz/2), _cx_sz, _cx_sz, spr_panel_close, "", c_white, fnt_main, true)) {
            ctrl.gui_state = "MAIN";
            ctrl.active_tile_index = -1;
        }

        // --- Tile Interaction Content ---
        if (instance_exists(obj_board) && ctrl.active_tile_index != -1) {
            var _tiles = obj_board.tiles;
            var _tile = _tiles[ctrl.active_tile_index];
            
            // 1. Render Tile Card (IDLE ANIMATION & DROP SHADOW)
            var _card_scale = 1.5; 
            var _card_w     = 130 * _card_scale;
            var _card_h     = 182 * _card_scale;
            
            // Floating Logic (Idle Animation)
            var _float_y    = sin(current_time * 0.003) * 8; 
            var _card_y_base = floor(_p_y + 140); // 20% area gap
            var _card_x     = floor(_p_x + (_p_w / 2) - (_card_w / 2));
            var _card_y     = floor(_card_y_base + _float_y);
            
            // Drop Shadow (Drawn first)
            var _shd_off = 12;
            draw_sprite_ext(_tile.sprite, 0, _card_x + _shd_off, _card_y + _shd_off, _card_scale, _card_scale, 0, c_black, 0.4);
            
            // Base Card
            draw_sprite_ext(_tile.sprite, 0, _card_x, _card_y, _card_scale, _card_scale, 0, c_white, 1);
            
            // Icon on Card
            var _icon_sc = _card_scale * 0.75;
            var _icon_w  = sprite_get_width(spr_tile_icons) * _icon_sc;
            draw_sprite_ext(spr_tile_icons, _tile.type, floor(_card_x + (_card_w/2) - (_icon_w/2)), floor(_card_y + (4 * _card_scale)), _icon_sc, _icon_sc, 0, c_white, 1);
            
            // Name on Card
            draw_set_font(fnt_main);
            draw_set_halign(fa_center); draw_set_valign(fa_middle);
            var _lbl_sc = 1.0 * _card_scale;
            draw_set_color(c_white);
            draw_text_transformed(floor(_card_x + _card_w/2), floor(_card_y + (_card_h/2) + 12), string_upper(_tile.name), _lbl_sc, _lbl_sc, 0);
            
            // Price on Card Bottom
            draw_set_valign(fa_middle);
            var _price_str = obj_controller.format_money(_tile.price);
            var _price_sc  = 0.9 * _card_scale;
            draw_text_transformed(floor(_card_x + _card_w/2), floor(_card_y + _card_h - (22 * _card_scale)), _price_str, _price_sc, _price_sc, 0);
            
            // 2. Info Text (Benefits - STATIC POSITION)
            var _info_y = floor(_card_y_base + _card_h + 55); // More gap
            var _level   = _tile.building_level;
            var _rent_val = _tile.rent;
            var _phase_idx = clamp(_level, 0, 2);
            _rent_val = _tile.rent_table[_phase_idx];
            
            var _val_str = obj_controller.format_money(_rent_val);
            var _psv_str = obj_controller.format_money(floor(_rent_val * 0.5));
            if (_level > 0) _psv_str += "/run";
            
            draw_set_font(fnt_main);
            
            // Income on Landing (Labels: White, Values: Gold + Large)
            var _inc_lbl = "Income on Landing ";
            var _inc_lbl_sc = 1.1;
            var _inc_val_sc = 1.65; // Extra Large
            
            var _inc_lbl_w = string_width(_inc_lbl) * _inc_lbl_sc;
            var _inc_val_w = string_width(_val_str) * _inc_val_sc;
            var _inc_total_w = _inc_lbl_w + _inc_val_w;
            var _inc_x = floor((_p_x + _p_w/2) - (_inc_total_w/2));
            
            draw_set_halign(fa_left); draw_set_valign(fa_middle);
            draw_set_color(c_white);
            draw_text_transformed(_inc_x, _info_y, _inc_lbl, _inc_lbl_sc, _inc_lbl_sc, 0);
            draw_set_color(C_MAIN_GOLD);
            draw_text_transformed(_inc_x + _inc_lbl_w, _info_y, _val_str, _inc_val_sc, _inc_val_sc, 0);
            
            // Income per Run (Labels: White, Values: Gold + Large)
            var _run_lbl = "Income per Run ";
            var _run_lbl_sc = 0.95;
            var _run_val_sc = 1.4; // Large
            
            var _run_lbl_w = string_width(_run_lbl) * _run_lbl_sc;
            var _run_val_w = string_width(_psv_str) * _run_val_sc;
            var _run_total_w = _run_lbl_w + _run_val_w;
            var _run_x = floor((_p_x + _p_w/2) - (_run_total_w/2));
            
            draw_set_color(c_white);
            draw_text_transformed(_run_x, _info_y + 44, _run_lbl, _run_lbl_sc, _run_lbl_sc, 0);
            draw_set_color(C_MAIN_GOLD);
            draw_text_transformed(_run_x + _run_lbl_w, _info_y + 44, _psv_str, _run_val_sc, _run_val_sc, 0);
            
            // 3. Buttons (30% area margin from bottom)
            var _btn_w = 150;
            var _btn_h = 60;
            var _btn_gap = 20;
            var _btns_x_start = _p_x + (_p_w / 2) - ((_btn_w * 3 + _btn_gap * 2) / 2);
            var _btn_y = _p_y + _p_h - 100;
            
            var _is_owned = (_tile.owner != -1);
            
            if (!_is_owned) {
                // --- UNOWNED: BUY (Orange) | SKIP (Red) | NEGO (Blue) ---
                // Button 1: BUY
                var _can_buy = (obj_controller.player_cash >= _tile.price);
                if (draw_gui_button(_btns_x_start, _btn_y, _btn_w, _btn_h, spr_button_orange, "Buy", c_white, fnt_main, _can_buy)) {
                    obj_controller.player_cash -= _tile.price;
                    _tile.owner = 0; 
                    ctrl.gui_state = "MAIN";
                    ctrl.active_tile_index = -1;
                }
                
                // Button 2: SKIP (Price Penalty)
                if (draw_gui_button(_btns_x_start + _btn_w + _btn_gap, _btn_y, _btn_w, _btn_h, spr_button_red, "Skip", c_white, fnt_main, true)) {
                    _tile.price = floor(_tile.price * 1.25); // 25% price hike
                    ctrl.gui_state = "MAIN";
                    ctrl.active_tile_index = -1;
                }

                // Button 3: NEGO (Locked by Skills)
                var _can_nego = (obj_controller.stats.charisma >= 5 && obj_controller.stats.negotiation >= 5);
                var _nego_price = floor(_tile.price * 0.65); // 35% discount
                if (draw_gui_button(_btns_x_start + (_btn_w + _btn_gap) * 2, _btn_y, _btn_w, _btn_h, spr_button_blue, "Nego", c_white, fnt_main, _can_nego && obj_controller.player_cash >= _nego_price)) {
                    obj_controller.player_cash -= _nego_price;
                    _tile.owner = 0;
                    ctrl.gui_state = "MAIN";
                    ctrl.active_tile_index = -1;
                }
            } else {
                // --- OWNED: UPGRADE (Orange) | SELL (Red) | SKIP (Blue) ---
                // Button 1: UPGRADE
                var _can_up = (_tile.building_level < 2);
                var _up_cost = floor(_tile.price * 0.75);
                var _up_label = (_tile.building_level == 0) ? "House" : "Hotel";
                if (_tile.building_level == 2) _up_label = "MAX";
                
                if (draw_gui_button(_btns_x_start, _btn_y, _btn_w, _btn_h, spr_button_orange, _up_label, c_white, fnt_main, _can_up && obj_controller.player_cash >= _up_cost)) {
                    obj_controller.player_cash -= _up_cost;
                    _tile.building_level++;
                    ctrl.gui_state = "MAIN";
                    ctrl.active_tile_index = -1;
                }
                
                // Button 2: SELL
                if (draw_gui_button(_btns_x_start + _btn_w + _btn_gap, _btn_y, _btn_w, _btn_h, spr_button_red, "Sell", c_white, fnt_main, true)) {
                    obj_controller.player_cash += floor(_tile.price * 0.85); // 85% back
                    _tile.owner = -1;
                    _tile.building_level = 0;
                    ctrl.gui_state = "MAIN";
                    ctrl.active_tile_index = -1;
                }

                // Button 3: SKIP (Get Income)
                if (draw_gui_button(_btns_x_start + (_btn_w + _btn_gap) * 2, _btn_y, _btn_w, _btn_h, spr_button_blue, "Income", c_white, fnt_main, true)) {
                    obj_controller.player_cash += floor(_rent_val * 0.4); // 40% income on pass
                    ctrl.gui_state = "MAIN";
                    ctrl.active_tile_index = -1;
                }
            }
        }
        
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }

    static cleanup = function() {
        if (surface_exists(surf_panel)) surface_free(surf_panel);
    }
}
