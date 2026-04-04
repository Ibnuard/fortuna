// Move in GUI space each frame
gui_x += vel_x;
gui_y += vel_y;

// Apply gravity
vel_y += gravity_str;

// Count down and destroy
life_timer--;
if (life_timer <= 0) instance_destroy();
