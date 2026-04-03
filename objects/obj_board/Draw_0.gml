function loop_index(i) {
    var len = array_length(tiles);
    return (i mod len + len) mod len;
}

var mid        = floor(tile_count / 2); // 4 for 9 tiles
var step_size  = tile_w + tile_gap;
var spr_w      = 130;
var spr_h      = 182;

// Draw order: outside-in so center tile renders on top
var draw_order = [-4, 4, -3, 3, -2, 2, -1, 1, 0];

// ── PASS 0: shadow semua tile ──
for (var oi = 0; oi < array_length(draw_order); oi++) {
    var i      = draw_order[oi];
    var _x     = board_center_x + i * step_size + anim_offset;
    
    var dist_norm = clamp(abs(_x - board_center_x) / (step_size * mid), 0, 1);
    
    var base_shd_x = 6;
    var base_shd_y = 15;
    
    var shd_draw_y = tile_y + base_shd_y;
    
    var local_t = clamp((intro_anim_t - ((abs(i)) * 0.08)) / 0.6, 0, 1);
    var t_ease = 1 - power(1 - local_t, 3);
    shd_draw_y += lerp(-1200, 0, t_ease);
    
    var half_w = tile_w / 2;
    var draw_x = _x - half_w;
    var shd_draw_x = draw_x + base_shd_x + lerp(8, 0, dist_norm);
    
    draw_set_alpha(lerp(0.65, 0.25, dist_norm));
    draw_sprite_part_ext(
        tiles[loop_index(player_index + i)].sprite, 0,
        0, 0, spr_w, spr_h,
        shd_draw_x, shd_draw_y,
        sc, sc, c_black, 1
    );
}

// ── PASS 1: semua tile ──
for (var oi = 0; oi < array_length(draw_order); oi++) {
    var i      = draw_order[oi];
    var _x     = board_center_x + i * step_size + anim_offset;
    
    var dist_norm = clamp(abs(_x - board_center_x) / (step_size * mid), 0, 1);
    var lift      = lerp(lift_max, 0, dist_norm);
    var _y        = tile_y - lift;

    var local_t = clamp((intro_anim_t - ((abs(i)) * 0.08)) / 0.6, 0, 1);
    var t_ease = 1 - power(1 - local_t, 3);
    _y += lerp(-1200, 0, t_ease);

    var half_w = tile_w / 2;
    var draw_x = _x - half_w;
    
    draw_set_alpha(lerp(1.0, 0.60, dist_norm));
    draw_sprite_part_ext(
        tiles[loop_index(player_index + i)].sprite, 0,
        0, 0, spr_w, spr_h,
        draw_x, _y,
        sc, sc, c_white, 1
    );
}

// ── PASS 2: border putih pada tile tengah ──
{
    var closest_x    = board_center_x;
    var closest_dist = 999999;
    var closest_i    = 0;
    for (var i = -mid; i <= mid; i++) {
        var _x = board_center_x + i * step_size + anim_offset;
        var d  = abs(_x - board_center_x);
        if (d < closest_dist) { closest_dist = d; closest_x = _x; closest_i = i; }
    }
    
    var dist_norm = clamp(closest_dist / step_size, 0, 1);
    var lift      = lerp(lift_max, 0, dist_norm);
    var bx        = closest_x - tile_w / 2;
    var by        = tile_y - lift;
    
    var local_t = clamp((intro_anim_t - ((abs(closest_i)) * 0.08)) / 0.6, 0, 1);
    var t_ease = 1 - power(1 - local_t, 3);
    by += lerp(-1200, 0, t_ease);
    
    var gap       = 1;
    var thickness = 8;
    
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