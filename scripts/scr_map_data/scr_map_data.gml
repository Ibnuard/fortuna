function map_get_tiles(_level) {
    switch (_level) {

    case 1: return [
        add_start   (spr_tile_start,  "START"),
        add_property(spr_tile_prop,   "MONAS",         400,  40),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "BOROBUDUR",     600,  60),
        
        add_jail    (spr_tile_jail,   "JAIL"),
        add_property(spr_tile_prop,   "Jl. KENANGA",   800,  80),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "Jl. SUDIRMAN",  1200, 120),
        
        add_casino  (spr_tile_casino, "CASINO"),
        add_property(spr_tile_prop,   "RAJA AMPAT",    1600, 160),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "DANAU TOBA",    1800, 180),
        
        add_market  (spr_tile_market, "MARKET"),
        add_property(spr_tile_prop,   "Jl. THAMRIN",   2000, 200),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "LABUAN BAJO",   2400, 240),
    ];

    case 2: return [
        add_start   (spr_tile_start,  "START"),
        add_property(spr_tile_prop,   "CITY A1",       500,  50),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "CITY A2",       700,  70),
        add_property(spr_tile_prop,   "CITY A3",       900,  90),
        
        add_jail    (spr_tile_jail,   "JAIL"),
        add_property(spr_tile_prop,   "CITY B1",       1100, 110),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "CITY B2",       1300, 130),
        add_property(spr_tile_prop,   "CITY B3",       1500, 150),
        
        add_casino  (spr_tile_casino, "CASINO"),
        add_property(spr_tile_prop,   "CITY C1",       1700, 170),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "CITY C2",       1900, 190),
        add_property(spr_tile_prop,   "CITY C3",       2100, 210),
        
        add_market  (spr_tile_market, "MARKET"),
        add_property(spr_tile_prop,   "CITY D1",       2300, 230),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "CITY D2",       2500, 250),
        add_property(spr_tile_prop,   "CITY D3",       2700, 270),
    ];

    case 3: return [
        add_start   (spr_tile_start,  "START"),
        add_property(spr_tile_prop,   "META A1",       600,  60),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "META A2",       800,  80),
        add_property(spr_tile_prop,   "META A3",       1000, 100),
        add_property(spr_tile_prop,   "META A4",       1200, 120),
        
        add_jail    (spr_tile_jail,   "JAIL"),
        add_property(spr_tile_prop,   "META B1",       1400, 140),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "META B2",       1600, 160),
        add_property(spr_tile_prop,   "META B3",       1800, 180),
        add_property(spr_tile_prop,   "META B4",       2000, 200),
        
        add_casino  (spr_tile_casino, "CASINO"),
        add_property(spr_tile_prop,   "META C1",       2200, 220),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "META C2",       2400, 240),
        add_property(spr_tile_prop,   "META C3",       2600, 260),
        add_property(spr_tile_prop,   "META C4",       2800, 280),
        
        add_market  (spr_tile_market, "MARKET"),
        add_property(spr_tile_prop,   "META D1",       3000, 300),
        add_fate    (spr_tile_fate,   "FATE"),
        add_property(spr_tile_prop,   "META D2",       3200, 320),
        add_property(spr_tile_prop,   "META D3",       3400, 340),
        add_property(spr_tile_prop,   "META D4",       3600, 360),
    ];

    }
}