// ── TILE STRUCT ────────────────────────────────────
function Tile(
    _type,          // TileType enum
    _sprite,        // sprite asset
    _name,          // string label
    _price  = 0,   // harga beli (Property only)
    _rent   = 0,   // sewa base (Property only)
    _group  = TileGroup.Evemt  // warna group (Property only)
) constructor {
    type   = _type;
    sprite = _sprite;
    name   = _name;
    price  = _price;
    rent   = _rent;
    group  = _group;

    // Computed — rent naik per level bangunan
    // [base, toko, hotel]
    rent_table = [_rent, _rent * 3, _rent * 8];

    // Runtime state (berubah saat gameplay)
    owner          = -1;   // -1 = tidak ada pemilik
    building_level = 0;    // 0=tanah, 1=toko, 2=hotel
    is_mortgaged   = false;
}