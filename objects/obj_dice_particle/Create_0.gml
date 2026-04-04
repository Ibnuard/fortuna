// Variables set by the spawner (obj_gui), do not change defaults here
spr      = spr_dice;  // which sprite to draw
sub_img  = 0;         // which subimage (die face)
chunk_xx = 0;         // left edge of this chunk in the sprite
chunk_yy = 0;         // top edge of this chunk in the sprite
chunk_sz = 4;         // pixel size of this chunk

// GUI-space position (NOT room x/y — this lives in GUI layer)
gui_x = 0;
gui_y = 0;

// Velocity in GUI pixels per frame
vel_x = random_range(-5, 5);
vel_y = random_range(-6, -1);

// Gravity pulling chunk down
gravity_str = 0.25;

// Lifetime
life_max   = irandom_range(25, 45);
life_timer = life_max;
