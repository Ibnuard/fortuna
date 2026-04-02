if (intro_active) {
    intro_anim_t = min(intro_anim_t + 0.02, 1.0);
    if (intro_anim_t >= 1.0) {
        intro_active = false;
    }
}

if (keyboard_check_pressed(vk_space) && !anim_active && steps_remaining == 0 && !intro_active) {
    steps_remaining = irandom_range(1, 4);
}

if (steps_remaining > 0 && !anim_active) {
    // Mulai animasi tile berikutnya
    anim_active = true;
    anim_t = 0.0;
	
	pawn_is_hopping = true;
    pawn_hop_t      = 0.0;
}

if (anim_active) {
    anim_t += anim_speed;
    
    // Easing: ease-out cubic supaya ada momentum lalu melambat
    var t_ease = 1 - power(1 - min(anim_t, 1.0), 3);
    
    // Tile bergerak dari 0 ke -(tile_w + tile_gap) = satu step ke kiri
    var step_size = tile_w + tile_gap;
    anim_offset = lerp(0, -step_size, t_ease);
    
    if (anim_t >= 1.0) {
        // Snap selesai
        anim_offset = 0;
        anim_active = false;
        anim_t = 0.0;
        
        var len = array_length(tiles);
        player_index = (player_index + 1) mod len;
        steps_remaining--;
        
        if (steps_remaining <= 0) {
            steps_remaining = 0;
            show_debug_message("LAND DI TILE: " + string(player_index));
        }
    }
}


// Animasi hop pawn — parabola naik lalu turun
var closest_x    = board_center_x;
var closest_dist = 999999;
for (var i = -floor(tile_count/2); i <= floor(tile_count/2); i++) {
    var _x = board_center_x + i * (tile_w + tile_gap) + anim_offset;
    var d  = abs(_x - board_center_x);
    if (d < closest_dist) { closest_dist = d; closest_x = _x; closest_i = i; }
}

var dist_norm   = clamp(closest_dist / (tile_w + tile_gap), 0, 1);
var lift        = lerp(lift_max, 0, dist_norm);
var tile_top_y  = tile_y - lift;

var local_t_p = clamp((intro_anim_t - ((closest_i + 2) * 0.1)) / 0.6, 0, 1);
var t_ease_p = 1 - power(1 - local_t_p, 3);
var intro_offset_p = lerp(-1200, 0, t_ease_p);

// target_y = tepi atas border putih (border = gap 3 + thickness 8 = 11px di atas tile)
pawn.target_x = closest_x;
pawn.target_y = tile_top_y - (3 + 8) + intro_offset_p; // gap + thickness dari border pass

// Trigger hop
if (anim_active && anim_t <= anim_speed) {
    pawn.is_hopping = true;
    pawn.hop_t      = 0.0;
    pawn.y_offset   = 0;
    pawn.idle_t     = 0; // reset idle saat hop
}