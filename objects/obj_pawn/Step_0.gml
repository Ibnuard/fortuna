if (is_hopping) {
    hop_t    += hop_speed;
    y_offset  = -sin(min(hop_t, 1.0) * pi) * hop_height;
    if (hop_t >= 1.0) {
        is_hopping = false;
        hop_t      = 0.0;
        y_offset   = 0;
    }
} else {
    // Idle bob hanya saat tidak hop
    idle_t   += idle_speed;
    y_offset  = -abs(sin(idle_t * pi)) * idle_height;
}