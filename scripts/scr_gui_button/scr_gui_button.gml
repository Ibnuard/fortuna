/// @function draw_gui_button(_x, _y, _w, _h, _sprite, _text)
/// @description Draws a styled button with text at the specified coordinates
function draw_gui_button(_x, _y, _w, _h, _sprite, _text) {
    // Draw the button stretched
    draw_sprite_stretched(_sprite, 0, _x, _y, _w, _h);
    
    // Set text properties
    draw_set_font(fnt_gui_button);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _text_x = _x + (_w / 2);
    var _text_y = _y + (_h / 2);
    
    // Drop shadow
    draw_set_color(c_black);
    draw_set_alpha(0.3);
    draw_text(_text_x, _text_y + 4, _text);
    draw_set_alpha(1.0);
    
    // Main text
    draw_set_color(c_white);
    draw_text(_text_x, _text_y, _text);
    
    // Reset alignment to prevent bugs elsewhere
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
