// Smoothly animate the offset towards 0 (target position)
if (bottom_y_offset > 0.5) {
    bottom_y_offset = lerp(bottom_y_offset, 0, animation_speed);
} else {
    bottom_y_offset = 0;
}
