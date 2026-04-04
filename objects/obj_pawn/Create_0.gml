pawn_sprite   = spr_pawn;
hop_height = PAWN_HOP_H;
hop_speed = PAWN_HOP_SPD;

y_offset      = 0;
hop_t         = 0.0;
is_hopping    = false;

// Idle bob
idle_t        = 0.0;
idle_speed = PAWN_IDLE_SPD; // kecepatan naik turun idle
idle_height = PAWN_IDLE_H;   // pixel naik turun

target_x      = 0;
target_y      = 0;   // ini adalah Y tepi ATAS border putih