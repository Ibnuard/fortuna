// Initialize animation variables
bottom_y_offset = 500; // Starts 500 pixels below its target position
animation_speed = 0.13; // Smoothness multiplier (closer to 0 is smoother/slower)

// --- Panel States ---
gui_state = "MAIN"; // "MAIN" or "PROPERTY"
target_bottom_offset = 0; // Where main UI should go (0 = visible, 250 = hidden down)
property_y_offset = 800;  // Where prop UI currently is (0 = visible, 800 = hidden down)

// Property Panel Scrolling & Surfaces
panel_scroll_y = 0;
panel_scroll_target = 0;
panel_max_scroll = 0;
surf_panel = -1;
surf_topbar = -1; // Specific canvas for the CRT curved top bar

// Touch / Mouse Drag state
is_dragging_panel = false;
drag_start_y = 0;
scroll_start = 0;

// ─── INTRO ANIMATION (Slide + Stagger) ───
intro_timer = 0;           // Global frame counter for sequencing
top_y_offset = -220;       // Top bar starts above screen
top_y_target = 0;          // Target: flush with top

// Stagger offsets for individual elements (start off-screen/invisible)
// Top bar elements
stagger_option = -60;       // Option button Y offset
stagger_target_bar = -60;   // Target bar + label Y offset  
stagger_cash = -60;         // Cash display Y offset
stagger_map_stat = -60;     // Map/Stat buttons Y offset

// Bottom panel elements
stagger_turn_badge = 80;    // Turn badge Y offset (starts below)
stagger_btn_center = 80;    // Roll button
stagger_btn_left = 80;      // Inventory button
stagger_btn_right = 80;     // Shop button

// ─── DICE ROLL POPUP ───
dice_values = [0, 0, 0];       // Current face values (0-5)
dice_roll_timer = 0;           // Timer to stop rolling/shuffling
dice_pop_y = 1000;             // Vertical offset for popup (starts below screen)
dice_can_exit = false;         // Flag to allow clicking away after roll ends

