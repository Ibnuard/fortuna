// Board Rendering

board_x  = 320;
board_y  = 200;
board_h  = 680;

var board_area_w = room_width - board_x;

tile_gap = 14;
var total_gap  = tile_gap * 4;
var tile_scr_w = floor((board_area_w * 0.95 - total_gap) / 5);
sc = tile_scr_w / 130;

tile_w = floor(130 * sc);
tile_h = floor(182 * sc);
tile_count = 5;

board_center_x = board_x + board_area_w / 2;
tile_y = board_y + (board_h - tile_h) / 2;

tiles = map_get_tiles(1);
player_index    = 0;
steps_remaining = 0;

anim_active = false;
anim_t      = 0.0;
anim_speed  = 1 / 12;
anim_offset = 0.0;

lift_max    = 18;

// Cari obj_pawn yang sudah ada di room
pawn = instance_find(obj_pawn, 0);
pawn.pawn_sprite = spr_pawn;
pawn.hop_height  = 28;
pawn.hop_speed   = 1 / 12;