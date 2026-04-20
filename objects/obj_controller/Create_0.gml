/// @description Global Gameplay Data Controller

// ─── MAP DATA (DUMMY MAP 1) ───
map_target    = 15000;
map_max_turns = 20;
current_turn  = 1;

// ─── PLAYER DATA ───
player_cash   = 5000;
map_index     = 1;
map_total     = 5;

// Pawn Skills (Dummy Pawn) - Ordered to match spr_skills indices
stats = {
    money_management: 5, // index 0
    luck:             5, // index 1
    charisma:         5, // index 2
    risk_tolerance:   5, // index 3
    negotiation:      5  // index 4
};

pawn_stats = {
    properties_owned: 0,
    houses_owned:     0,
    hotels_owned:     0,
    passive_income:   0,
    tax_rate:         5,
    tax_per_turn:     0,
    net_income:       0
};

// ─── UTILS ───
// Function to format currency
function format_money(_amount) {
    // Basic formatting: $12.400 style
    var _str = string(abs(_amount));
    var _len = string_length(_str);
    var _res = "";
    var _count = 0;
    
    for (var i = _len; i >= 1; i--) {
        _res = string_char_at(_str, i) + _res;
        _count++;
        if (_count == 3 && i > 1) {
            _res = "." + _res;
            _count = 0;
        }
    }
    
    return "$" + _res;
}
