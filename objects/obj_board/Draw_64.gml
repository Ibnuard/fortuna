/// @description Draw Board on GUI Layer
// All board rendering now uses GUI coordinates (1920x1080) for cross-platform consistency

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
    
    // Juicy Idle Animation (Floating Wave)
    var _idle_y = sin((current_time * 0.002) + (i * 0.6)) * 8;
    
    // Scale sangat subtle (3-5%)
    var _w_sc = lerp(1, 0.96, dist_norm); 
    var _h_sc = lerp(1, 0.97, dist_norm);
    
    var current_w = tile_w * _w_sc;
    var current_h = tile_h * _h_sc;
    
    var base_shd_x = 6;
    var base_shd_y = 15;
    
    var shd_draw_y = tile_y + base_shd_y; 
    
    var local_t = clamp((intro_anim_t - ((abs(i)) * 0.08)) / 0.6, 0, 1);
    var t_ease = 1 - power(1 - local_t, 3);
    shd_draw_y += lerp(-1200, 0, t_ease);
    
    var half_w = current_w / 2;
    var draw_x = _x - half_w;
    var shd_draw_x = draw_x + base_shd_x + lerp(8, 0, dist_norm);
    
    draw_set_alpha(lerp(0.65, 0.25, dist_norm));
    draw_sprite_stretched_ext(
        tiles[loop_index(player_index + i)].sprite, 0,
        shd_draw_x, shd_draw_y,
        current_w, current_h,
        c_black, 1
    );
}

// ── PASS 1: semua tile ──
for (var oi = 0; oi < array_length(draw_order); oi++) {
    var i      = draw_order[oi];
    var _tile = tiles[loop_index(player_index + i)];
    var _x     = board_center_x + i * step_size + anim_offset;
    
    var dist_norm = clamp(abs(_x - board_center_x) / (step_size * mid), 0, 1);
    var _alpha = lerp(1.0, 0.60, dist_norm);
    
    var _w_sc = lerp(1, 0.96, dist_norm);
    var _h_sc = lerp(1, 0.97, dist_norm);
    var current_w = tile_w * _w_sc;
    var current_h = tile_h * _h_sc;
    
    var lift      = lift_max * (1 - power(dist_norm, 2)); // Parabolic curve untuk efek cekung yang lebih 'juicy'
    
    // Juicy Idle Animation (Floating Wave)
    var _idle_y = sin((current_time * 0.002) + (i * 0.6)) * 8;
    var _y        = tile_y - lift + _idle_y;

    var local_t = clamp((intro_anim_t - ((abs(i)) * 0.08)) / 0.6, 0, 1);
    var t_ease = 1 - power(1 - local_t, 3);
    _y += lerp(-1200, 0, t_ease);

    var half_w = current_w / 2;
    var draw_x = _x - half_w;
    
    // ── CARD DRAWING PASS ──
    var _is_glass = (_tile.owner == -1 && _tile.type == TileType.Property);
    var _base_alpha = _is_glass ? 0.75 : 1.0;
    
    draw_set_alpha(_base_alpha * lerp(1.0, 0.60, dist_norm));
    draw_sprite_stretched_ext(
        _tile.sprite, 0,
        draw_x, _y,
        current_w, current_h,
        c_white, 1
    );

    // ── GLASS CARD EFFECTS (Unowned Only) ──
    if (_is_glass) {
        // 1. Specular Border (Glass Edge)
        draw_set_color(c_white);
        draw_set_alpha(0.3 * _alpha);
        draw_roundrect_ext(draw_x, _y, draw_x + current_w, _y + current_h, 8*sc, 8*sc, true);
        
        // 2. Contained Shimmer (Reflection)
        var _shimmer_period = 4000;
        var _shimmer_dur    = 1200;
        var _time           = current_time % _shimmer_period;
        
        if (_time < _shimmer_dur) {
            var _prog = _time / _shimmer_dur;
            var _sweep_x = lerp(-100 * sc, current_w + 100 * sc, _prog);
            var _sweep_w = 30 * sc;
            
            gpu_set_blendmode(bm_add);
            draw_set_alpha(0.15 * _alpha);
            
            // Clean diagonal sweep strictly aligned to card face
            draw_primitive_begin(pr_trianglestrip);
            var _tilt = 40 * sc;
            
            // We draw the sweep but clamp values to stay visually bounded
            var _x1 = draw_x + _sweep_x;
            var _x2 = _x1 + _sweep_w;
            
            draw_set_color(c_white);
            draw_vertex(clamp(_x2, draw_x, draw_x + current_w), _y);
            draw_vertex(clamp(_x1, draw_x, draw_x + current_w), _y);
            draw_vertex(clamp(_x2 - _tilt, draw_x, draw_x + current_w), _y + current_h);
            draw_vertex(clamp(_x1 - _tilt, draw_x, draw_x + current_w), _y + current_h);
            draw_primitive_end();
            
            gpu_set_blendmode(bm_normal);
        }
    }
    
    draw_set_alpha(1.0);
    
    // ── DRAW TILE ICON ──
    var _icon_idx = _tile.type; // 1-to-1 mapping confirmed
    
    // Konpensasi origin Top-Left agar tetap Center secara visual
    var _icon_sc  = sc * 0.75; // Sesuai update manual user
    var _icon_sc_x = _icon_sc * _w_sc;
    var _icon_sc_y = _icon_sc * _h_sc;
    
    var _icon_sw  = sprite_get_width(spr_tile_icons) * _icon_sc_x;
    var _icon_sh  = sprite_get_height(spr_tile_icons) * _icon_sc_y;
    
    var _icon_x   = _x - (_icon_sw / 2); // Menggunakan _x (center) langsung
    var _icon_y   = _y + (12 * sc * _h_sc); // Disesuaikan untuk tinggi tile baru
    
    // Draw icon with same alpha and lift as the tile
    draw_sprite_ext(spr_tile_icons, _icon_idx, _icon_x, _icon_y, _icon_sc_x, _icon_sc_y, 0, c_white, lerp(1.0, 0.60, dist_norm));
    
    // ── DRAW TILE TEXT (LABEL & INFO) ──
    draw_set_font(fnt_main_18);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    var _label_y = _y + (current_h / 2) + (12 * sc * _h_sc); // Diturunkan agar lebih ke tengah bodi tile
    var _label_str = string_upper(_tile.name);
    var _label_scale_x = 1.0;
    var _label_scale_y = 1.0;
    var _label_sep   = 32 * _h_sc; // Dalam unit font asli (akan di-scale otomatis oleh fungsi draw)
    var _label_w     = (current_w - (20 * sc)) / _label_scale_x; // Kalkulasi limit lebar vs skala font
    
    // Shadow pass
    draw_set_color(c_black); draw_set_alpha(_alpha * 0.4);
    draw_text_ext_transformed(_x + 2, _label_y + 2, _label_str, _label_sep, _label_w, _label_scale_x, _label_scale_y, 0);
    
    // Main pass
    draw_set_color(c_white); draw_set_alpha(_alpha);
    draw_text_ext_transformed(_x, _label_y, _label_str, _label_sep, _label_w, _label_scale_x, _label_scale_y, 0);
    
    // 2. Info / Harga (Bottom Body)
    var _info_y   = _y + current_h - (22 * sc * _h_sc); // Lebih ditarik ke arah bottom
    var _info_str = "";
    
    switch(_tile.type) {
        case TileType.Start:   _info_str = "+ $1000"; break;
        case TileType.Fate:    _info_str = "DRAW";    break;
        case TileType.Market:  _info_str = "SHOP";    break;
        case TileType.Casino:  _info_str = "BET";     break;
        case TileType.Jail:    _info_str = "OOPS";    break;
        case TileType.Property: _info_str = "$" + string(_tile.price); break;
    }
    
    var _info_scale_x = 1.0;
    var _info_scale_y = 1.0;
    var _info_color = c_white; // Reverted back to white for all tiles
    
    // Shadow pass
    draw_set_color(c_black); draw_set_alpha(_alpha * 0.5);
    draw_text_transformed(_x + 2, _info_y + 2, _info_str, _info_scale_x, _info_scale_y, 0);
    
    // Main pass
    draw_set_color(_info_color); draw_set_alpha(_alpha);
    draw_text_transformed(_x, _info_y, _info_str, _info_scale_x, _info_scale_y, 0);
    
    draw_set_alpha(1.0); draw_set_valign(fa_top);
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
    var radius    = 12 * sc; // Proportional radius
    
    draw_set_alpha(1);
    for (var b = 0; b < thickness; b++) {
        draw_set_color(c_white);
        draw_roundrect_ext(
            bx - gap - b, by - gap - b,
            bx + tile_w + gap + b, by + tile_h + gap + b,
            radius, radius,
            true
        );
    }
}

draw_set_alpha(1);
draw_set_color(c_white);
