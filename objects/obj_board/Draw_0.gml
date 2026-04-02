function loop_index(i) {
    var len = array_length(tiles);
    return (i mod len + len) mod len;
}

var mid        = floor(tile_count / 2);
var step_size  = tile_w + tile_gap;
var spr_w      = 130;
var spr_h      = 182;
var draw_order = [-2, -1, 2, 1, 0];

// ── PASS 0: shadow semua tile ──
for (var oi = 0; oi < array_length(draw_order); oi++) {
    var i      = draw_order[oi];
    var _x     = board_center_x + i * step_size + anim_offset;
    var half_w = tile_w / 2;
    if (_x + half_w <= board_x) continue;
    
    var dist_norm = clamp(abs(_x - board_center_x) / step_size, 0, 1);
    var lift      = lerp(lift_max, 0, dist_norm);
    var _y        = tile_y - lift;
    var tile_left = _x - half_w;
    var clip_px   = max(0, board_x - tile_left);
    var src_x     = clip_px / sc;
    var src_w     = spr_w - src_x;
    var draw_x    = tile_left + clip_px;
    if (src_w <= 0) continue;
    
    var shd_off = lerp(18, 8, dist_norm);
    draw_set_alpha(lerp(0.75, 0.32, dist_norm));
    draw_sprite_part_ext(
        tiles[loop_index(player_index + i)].sprite, 0,
        src_x, 0, src_w, spr_h,
        draw_x + shd_off, _y + shd_off,
        sc, sc, c_black, 1
    );
}

// ── PASS 1: semua tile ──
for (var oi = 0; oi < array_length(draw_order); oi++) {
    var i      = draw_order[oi];
    var _x     = board_center_x + i * step_size + anim_offset;
    var half_w = tile_w / 2;
    if (_x + half_w <= board_x) continue;
    
    var dist_norm = clamp(abs(_x - board_center_x) / step_size, 0, 1);
    var lift      = lerp(lift_max, 0, dist_norm);
    var _y        = tile_y - lift;
    var tile_left = _x - half_w;
    var clip_px   = max(0, board_x - tile_left);
    var src_x     = clip_px / sc;
    var src_w     = spr_w - src_x;
    var draw_x    = tile_left + clip_px;
    if (src_w <= 0) continue;
    
    draw_set_alpha(lerp(1.0, 0.68, dist_norm));
    draw_sprite_part_ext(
        tiles[loop_index(player_index + i)].sprite, 0,
        src_x, 0, src_w, spr_h,
        draw_x, _y,
        sc, sc, c_white, 1
    );
}

// ── PASS 2: border putih ──
{
    var closest_x    = board_center_x;
    var closest_dist = 999999;
    for (var i = -mid; i <= mid; i++) {
        var _x = board_center_x + i * step_size + anim_offset;
        var d  = abs(_x - board_center_x);
        if (d < closest_dist) { closest_dist = d; closest_x = _x; }
    }
    
    var dist_norm = clamp(closest_dist / step_size, 0, 1);
    var lift      = lerp(lift_max, 0, dist_norm);
    var bx        = closest_x - tile_w / 2;
    var by        = tile_y - lift;
    
    var gap       = 1;  // jarak dari tepi tile
    var thickness = 8;  // tebal border
    
    draw_set_alpha(1);
    for (var b = 0; b < thickness; b++) {
        draw_set_color(c_white);
        draw_rectangle(
            bx - gap - b, by - gap - b,
            bx + tile_w + gap + b, by + tile_h + gap + b,
            true
        );
    }
}

draw_set_alpha(1);
draw_set_color(c_white);