function map_get_tiles(_level) {
    switch (_level) {

    case 1: return [
        add_start   (spr_tile_start,  "Start"),
        add_property(spr_tile_prop,   "Gang Mawar",    400,  40,  TileGroup.Cheap),
        add_fate    (spr_tile_fate,   "Fate"),
        add_property(spr_tile_prop,   "Jl. Kenanga",   600,  60,  TileGroup.Cheap),
        add_casino  (spr_tile_casino, "Casino"),
        add_property(spr_tile_prop,   "Jl. Sudirman Blok M",  1200, 120, TileGroup.Mid),
        add_market  (spr_tile_market, "Market"),
        add_property(spr_tile_prop,   "Jl. Thamrin",   1400, 140, TileGroup.Mid),
        add_jail    (spr_tile_jail,   "Jail"),
        add_fate    (spr_tile_fate,   "Fate"),
        add_property(spr_tile_prop,   "Jl. Senayan",   1600, 160, TileGroup.Mid),
        add_fate    (spr_tile_fate,   "Fate"),
    ];
    }
}