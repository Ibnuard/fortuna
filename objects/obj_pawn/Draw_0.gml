var pw = sprite_exists(pawn_sprite) ? sprite_get_width(pawn_sprite)  : 36;
var ph = sprite_exists(pawn_sprite) ? sprite_get_height(pawn_sprite) : 36;

// Posisi: center X, tepat di atas border (target_y adalah tepi atas border)
var draw_x = target_x - pw / 2;
var draw_y = target_y - ph + y_offset; // naik dari tepi atas border

// Shadow kotak offset — sama style dengan tiles
draw_set_alpha(lerp(0.5, 0.15, abs(y_offset) / max(hop_height, 1)));
draw_set_color(c_black);
draw_rectangle(
    draw_x + 6, draw_y + 6,
    draw_x + pw + 6, draw_y + ph + 6,
    false
);

// Sprite pawn
draw_set_alpha(1);
if (sprite_exists(pawn_sprite)) {
    draw_sprite_ext(pawn_sprite, 0,
        draw_x, draw_y,
        1, 1, 0, c_white, 1
    );
} else {
    // Placeholder kotak
    draw_set_color(c_white);
    draw_rectangle(draw_x, draw_y, draw_x + pw, draw_y + ph, false);
    draw_set_color(make_color_rgb(180, 180, 180));
    draw_rectangle(draw_x, draw_y, draw_x + pw, draw_y + ph, true);
}

draw_set_alpha(1);
draw_set_color(c_white);