// Initialize animation variables
bottom_y_offset = 500; // Starts 500 pixels below its target position
animation_speed = 0.13; // Smoothness multiplier (closer to 0 is smoother/slower)

// --- Panel States ---
gui_state = "MAIN"; // "MAIN" or "PROPERTY"
target_bottom_offset = 0; // Where main UI should go (0 = visible, 250 = hidden down)
property_y_offset = 800;  // Where prop UI currently is (0 = visible, 800 = hidden down)
