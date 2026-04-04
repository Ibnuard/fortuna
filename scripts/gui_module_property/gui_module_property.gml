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
        var _fate_max = 6;
        var _prop_max = 12;
        var _fate_filled = 2;
        var _prop_filled = 5;

        var _card_spr = spr_card_placeholder;
        var _card_scale = 0.74; 
        var _card_w = sprite_get_width(_card_spr) * _card_scale;
        var _card_h = sprite_get_height(_card_spr) * _card_scale;
        var _card_gap = 16;
        var _columns = clamp(max(_fate_max, _prop_max), 5, 6);
        var _total_cards_w = (_card_w * _columns) + (_card_gap * max(0, _columns - 1));

        var _prop_panel_w = _total_cards_w + 100; 
        var _prop_panel_h = room_height * 0.7; 
        var _prop_panel_x = room_width / 2 - (_prop_panel_w / 2);
        var _submerged_amt = 150; 
        var _prop_target_y = room_height - _prop_panel_h + _submerged_amt; 
        var _prop_panel_y = _prop_target_y + property_y_offset;

        if (property_y_offset < 790) {
            var _overlay_alpha = lerp(0.4, 0, clamp(property_y_offset / 800, 0, 1));
            draw_set_color(c_black);
            draw_set_alpha(_overlay_alpha);
            draw_rectangle(0, 0, room_width, room_height, false);
            draw_set_color(c_white);
            draw_set_alpha(1.0);
            
            draw_sprite_stretched(spr_gui_bottom_container, 0, _prop_panel_x, _prop_panel_y, _prop_panel_w, _prop_panel_h);
            
            var _close_scale = 0.65;
            var _close_w = sprite_get_width(spr_panel_close) * _close_scale;
            var _close_h = sprite_get_height(spr_panel_close) * _close_scale;
            var _close_x = _prop_panel_x + _prop_panel_w - (_close_w * 0.7);
            var _close_y = _prop_panel_y - (_close_h * 0.3);
            
            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);
            var _close_hover = point_in_rectangle(_mx, _my, _close_x, _close_y, _close_x + _close_w, _close_y + _close_h);
            var _close_pressed = _close_hover && mouse_check_button(mb_left);
            
            if (_close_hover) {
                if (mouse_check_button_pressed(mb_left)) is_dragging_panel = false;
                if (mouse_check_button_released(mb_left)) ctrl.gui_state = "MAIN";
            }
            
            var _draw_scale = _close_scale;
            var _draw_x = _close_x;
            var _draw_y = _close_y;
            if (_close_pressed) {
                _draw_scale = _close_scale * 0.9;
                var _shrink_w = _close_w - (sprite_get_width(spr_panel_close) * _draw_scale);
                var _shrink_h = _close_h - (sprite_get_height(spr_panel_close) * _draw_scale);
                _draw_x += _shrink_w / 2;
                _draw_y += _shrink_h / 2;
            }
            
            draw_sprite_ext(spr_panel_close, 0, _draw_x, _draw_y, _draw_scale, _draw_scale, 0, c_white, 1);
            if (_close_hover && !_close_pressed) {
                gpu_set_blendmode(bm_add);
                draw_sprite_ext(spr_panel_close, 0, _draw_x, _draw_y, _draw_scale, _draw_scale, 0, c_white, 0.25);
                gpu_set_blendmode(bm_normal);
            }
            
            var _inner_w = _total_cards_w;
            var _inner_h = _prop_panel_h - _submerged_amt - 100; 
            var _inner_x = _prop_panel_x + 50; 
            var _inner_y = _prop_panel_y + 50; 
            
            if (_inner_w > 0 && _inner_h > 0) {
                if (!surface_exists(surf_panel)) {
                    surf_panel = surface_create(_inner_w, _inner_h);
                } else if (surface_get_width(surf_panel) != _inner_w || surface_get_height(surf_panel) != _inner_h) {
                    surface_free(surf_panel);
                    surf_panel = surface_create(_inner_w, _inner_h);
                }
                
                surface_set_target(surf_panel);
                draw_clear_alpha(c_black, 0);
                
                var _draw_cursor_y = -panel_scroll_y; 
                draw_set_font(fnt_main);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                var _text_x = _inner_w / 2;
                var _origin_x = sprite_get_xoffset(_card_spr) * _card_scale;
                var _origin_y = sprite_get_yoffset(_card_spr) * _card_scale;
                
                _draw_cursor_y += 15; 
                var _fate_str = "Fate Cards (" + string(_fate_filled) + "/" + string(_fate_max) + ")";
                draw_set_color(c_black); draw_set_alpha(0.3); draw_text(_text_x + 2, _draw_cursor_y + 3, _fate_str);
                draw_set_color(c_white); draw_set_alpha(1.0); draw_text(_text_x, _draw_cursor_y, _fate_str);
                _draw_cursor_y += 25 + _origin_y; 
                
                for (var i = 0; i < _fate_max; i++) {
                    var _col = i mod _columns;
                    var _row = i div _columns;
                    var _cx = (_col * (_card_w + _card_gap)) + _origin_x;
                    var _cy = _draw_cursor_y + (_row * (_card_h + _card_gap));
                    draw_sprite_ext(_card_spr, 0, _cx, _cy, _card_scale, _card_scale, 0, c_white, 1);
                }
                
                var _fate_rows = ceil(_fate_max / _columns);
                _draw_cursor_y += (_fate_rows * (_card_h + _card_gap)) - _origin_y;
                
                _draw_cursor_y += 20; 
                var _prop_str = "Properties (" + string(_prop_filled) + "/" + string(_prop_max) + ")";
                draw_set_color(c_black); draw_set_alpha(0.3); draw_text(_text_x + 2, _draw_cursor_y + 3, _prop_str);
                draw_set_color(c_white); draw_set_alpha(1.0); draw_text(_text_x, _draw_cursor_y, _prop_str);
                _draw_cursor_y += 25 + _origin_y; 
                
                for (var i = 0; i < _prop_max; i++) {
                    var _col = i mod _columns;
                    var _row = i div _columns;
                    var _cx = (_col * (_card_w + _card_gap)) + _origin_x;
                    var _cy = _draw_cursor_y + (_row * (_card_h + _card_gap));
                    draw_sprite_ext(_card_spr, 0, _cx, _cy, _card_scale, _card_scale, 0, c_white, 1);
                }
                
                var _prop_rows = ceil(_prop_max / _columns);
                _draw_cursor_y += (_prop_rows * (_card_h + _card_gap)) - _origin_y;
                _draw_cursor_y += 15; 
                
                surface_reset_target();
                draw_surface(surf_panel, _inner_x, _inner_y);
                
                var _total_content_height = (_draw_cursor_y + panel_scroll_y); 
                if (_total_content_height > _inner_h) {
                    panel_max_scroll = _total_content_height - _inner_h;
                } else {
                    panel_max_scroll = 0;
                }
                draw_set_halign(fa_left); draw_set_valign(fa_top);
            }
        }
    }

    static cleanup = function() {
        if (surface_exists(surf_panel)) surface_free(surf_panel);
    }
}
