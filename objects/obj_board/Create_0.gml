// Board Rendering

board_x = BOARD_PAD_X; // Symmetric padding from screen edges
board_y = BOARD_PAD_Y;
board_h = BOARD_AREA_H;

var board_area_w = room_width - (board_x * 2); // Full width minus symmetric padding

tile_gap = BOARD_TILE_GAP;
var total_gap  = tile_gap * 8; // 8 gaps between 9 tiles
var tile_scr_w = floor((board_area_w - total_gap) / 9);
sc = tile_scr_w / 130;

tile_w = floor(130 * sc);
tile_h = floor(240 * sc); // Tinggi ditingkatkan agar mengisi ruang board area lebih baik
tile_count = 9;

board_center_x = board_x + board_area_w / 2;
tile_y = board_y + (board_h - tile_h) / 2;

tiles = map_get_tiles(1);
player_index    = 0;
steps_remaining = 0;

anim_active = false;
anim_t      = 0.0;
anim_speed = BOARD_SPEED;
anim_offset = 0.0;

intro_active = true;
intro_anim_t = 0.0;

lift_max = BOARD_LIFT_MAX;

// Cari obj_pawn yang sudah ada di room
pawn = instance_find(obj_pawn, 0);
if (instance_exists(pawn)) {
    pawn.pawn_sprite = spr_pawn;
    pawn.hop_height = PAWN_HOP_H;
    pawn.hop_speed = PAWN_HOP_SPD;
}

// Ganti warna background room secara otomatis (menggantikan sprite BG yg dihapus)
var _layers = layer_get_all();
for (var i = 0; i < array_length(_layers); i++) {
    var _elms = layer_get_all_elements(_layers[i]);
    if (is_array(_elms)) {
        for (var j = 0; j < array_length(_elms); j++) {
            if (layer_get_element_type(_elms[j]) == layerelementtype_background) {
                layer_background_blend(_elms[j], #0D2E19);
            }
        }
    }
}
