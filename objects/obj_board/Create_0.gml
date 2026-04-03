// Board Rendering

board_x  = 40; // Symmetric padding from screen edges
board_y  = 200;
board_h  = 680;

var board_area_w = room_width - (board_x * 2); // Full width minus symmetric padding

tile_gap = 12;
var total_gap  = tile_gap * 8; // 8 gaps between 9 tiles
var tile_scr_w = floor((board_area_w - total_gap) / 9);
sc = tile_scr_w / 130;

tile_w = floor(130 * sc);
tile_h = floor(182 * sc);
tile_count = 9;

board_center_x = board_x + board_area_w / 2;
tile_y = board_y + (board_h - tile_h) / 2;

tiles = map_get_tiles(1);
player_index    = 0;
steps_remaining = 0;

anim_active = false;
anim_t      = 0.0;
anim_speed  = 1 / 12;
anim_offset = 0.0;

intro_active = true;
intro_anim_t = 0.0;

lift_max    = 18;

// Cari obj_pawn yang sudah ada di room
pawn = instance_find(obj_pawn, 0);
if (instance_exists(pawn)) {
    pawn.pawn_sprite = spr_pawn;
    pawn.hop_height  = 28;
    pawn.hop_speed   = 1 / 12;
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
