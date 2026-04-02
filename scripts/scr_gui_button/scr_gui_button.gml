/// @function draw_gui_button(_x, _y, _w, _h, _sprite, _text, [_text_color], [_font])
/// @description Draws a styled button with text at the specified coordinates
function draw_gui_button(_x, _y, _w, _h, _sprite, _text, _text_color = c_white, _font = fnt_gui_button_large) {
    // Draw the button stretched
    draw_sprite_stretched(_sprite, 0, _x, _y, _w, _h);
    
    // Set text properties
    draw_set_font(_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _text_x = _x + (_w / 2);
    
    // Calculate the exact center of the top "face" area 
    // (nine-slice preserves a 40px 3D bottom border, so we subtract it)
    var _face_h = _h - 10;
    var _text_y = _y + (_face_h / 2);
    
    // Drop shadow
    draw_set_color(c_black);
    draw_set_alpha(0.3);
    draw_text(_text_x, _text_y + 4, _text);
    draw_set_alpha(1.0);
    
    // Main text
    draw_set_color(_text_color);
    draw_text(_text_x, _text_y, _text);
    
    // Reset alignment to prevent bugs elsewhere
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
