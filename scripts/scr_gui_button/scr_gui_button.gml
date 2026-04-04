/// @function draw_gui_button(_x, _y, _w, _h, _sprite, _text, [_text_color], [_font])
/// @description Draws a styled button with text at the specified coordinates
function draw_gui_button(_x, _y, _w, _h, _sprite, _text, _text_color = c_white, _font = fnt_gui_button_large) {
    
    // DYNAMIC SIZING: Ensure button is at least wide enough for the text
    draw_set_font(_font);
    var _req_w = string_width(_text) + 60; // Extra padding
    if (_req_w > _w) {
        _x -= (_req_w - _w) / 2; // Keep it centered
        _w = _req_w;
    }
    
    // -- IM-GUI INTRACTION LOGIC --
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    // Evaluate hitbox on the ORIGINAL static coordinates to prevent jittering
    var _hover = point_in_rectangle(_mx, _my, _x, _y, _x + _w, _y + _h);
    var _pressed = _hover && mouse_check_button(mb_left);
    var _clicked = _hover && mouse_check_button_released(mb_left);
    
    // JUICE: Float up on hover
    if (_hover && !_pressed) {
        _y -= 6; // Angkat tombol sedikit ke atas
    }
    
    // JUICE: Dip in on press
    if (_pressed) {
        var _squash = 2;
        _y += _squash; // Turunkan atap tombol
        _h -= _squash; // Penyet tingginya sehingga 9-slice tertekan
    }

    // Draw the button stretched
    draw_sprite_stretched(_sprite, 0, _x, _y, _w, _h);
    
    // JUICE: Glow on hover
    if (_hover && !_pressed) {
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(_sprite, 0, _x, _y, _w / sprite_get_width(_sprite), _h / sprite_get_height(_sprite), 0, c_white, 0.15);
        gpu_set_blendmode(bm_normal);
    }
    
    // Set text properties
    draw_set_font(_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _text_x = _x + (_w / 2);
    
    // Calculate the exact center of the top "face" area 
    // (nine-slice preserves a bottom 3D border, so we subtract to find the true vertical face center)
    var _face_h = _h - 16;
    var _text_y = _y + (_face_h / 2);
    
    // Drop shadow
    draw_set_color(c_black);
    draw_set_alpha(0.3);
    draw_text(_text_x + 3, _text_y + 4, _text);
    draw_set_alpha(1.0);
    
    // Main text
    draw_set_color(_text_color);
    draw_text(_text_x, _text_y, _text);
    
    // Reset alignment to prevent bugs elsewhere
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    return _clicked;
}
