pawn_sprite   = spr_pawn;
hop_height    = 28;
hop_speed     = 1 / 12;

y_offset      = 0;
hop_t         = 0.0;
is_hopping    = false;

// Idle bob
idle_t        = 0.0;
idle_speed    = 0.02; // kecepatan naik turun idle
idle_height   = 4;   // pixel naik turun

target_x      = 0;
target_y      = 0;   // ini adalah Y tepi ATAS border putih