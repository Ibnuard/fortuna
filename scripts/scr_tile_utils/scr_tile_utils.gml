// Hitung rent aktual saat player landing.
// Sudah include building level.
function tile_calc_rent(_tile) {
    if (_tile.type != TileType.Property) return 0;
    if (_tile.is_mortgaged)               return 0;

    return _tile.rent_table[_tile.building_level];
}