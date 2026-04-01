// Kembalikan rent multiplier berdasarkan area group.
function tile_group_multiplier(_group) {
    switch (_group) {
        case TileGroup.Cheap:  return 1.0;
        case TileGroup.Mid:    return 1.5;
        case TileGroup.Upper:  return 2.0;
        case TileGroup.Elite:  return 3.0;
        default:               return 0; // None / Event = tidak ada rent
    }
}

// Hitung rent aktual saat player landing.
// Sudah include building level + area multiplier.
function tile_calc_rent(_tile) {
    if (_tile.type != TileType.Property) return 0;
    if (_tile.is_mortgaged)               return 0;

    var _base_rent  = _tile.rent_table[_tile.building_level];
    var _multiplier = tile_group_multiplier(_tile.group);
    return floor(_base_rent * _multiplier);
}

// Kembalikan nama area untuk display di HUD.
function tile_group_name(_group) {
    switch (_group) {
        case TileGroup.Cheap:  return "Area Murah";
        case TileGroup.Mid:    return "Area Menengah";
        case TileGroup.Upper:  return "Area Atas";
        case TileGroup.Elite:  return "Area Elit";
        default:               return "";
    }
}