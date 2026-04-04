// Ensure Gameplay Controller exists
if (!instance_exists(obj_controller)) {
    instance_create_layer(0, 0, "Instances", obj_controller);
}

// Initialize animation variables
bottom_y_offset = 500; // Starts 500 pixels below its target position
animation_speed = 0.13; // Smoothness multiplier (closer to 0 is smoother/slower)

// --- Panel States ---
gui_state = "MAIN"; // "MAIN" | "DICE" | "MOVING" | "PROPERTY"
target_bottom_offset = 0;
property_y_offset = 800;

// Property Panel Scrolling & Surfaces
panel_scroll_y = 0;
panel_scroll_target = 0;
panel_max_scroll = 0;
surf_panel = -1;
surf_topbar = -1;

// Touch / Mouse Drag state
is_dragging_panel = false;
drag_start_y = 0;
scroll_start = 0;

// ─── INTRO ANIMATION (Slide + Stagger) ───
intro_timer = 0;
top_y_offset = -220;
top_y_target = 0;

stagger_option     = -60;
stagger_target_bar = -60;
stagger_cash       = -60;
stagger_map_stat   = -60;

stagger_turn_badge = 80;
stagger_btn_center = 80;
stagger_btn_left   = 80;
stagger_btn_right  = 80;

// ─── DICE ROLL POPUP ───
dice_values      = [0, 0, 0];
dice_pop_y       = 1000;
dice_can_exit    = false;
dice_phase       = "IDLE"; // IDLE | ENTERING | PAUSE | ROLLING | FINISHED
dice_timer       = 0;
dice_flash_alpha = 0;
dice_selected    = [false, false, false];
dice_select_y    = [0, 0, 0];
dice_panel_h_extra = 0;
c_gold = make_color_rgb(255, 215, 0);

// ─── CONFIRM ANIMATION STATE MACHINE ───
// Phases advance strictly one after the other, driven by frame counters.
// confirm_phase: 0=idle, 1=unsel_fade, 2=sel_pulse, 3=fly, 4=panel_out, 5=pawn_move
confirm_phase = 0;

// Phase 1: Unselected die alpha 1→0, scale 1→0.8, over 10 frames
confirm_unsel_frame = 0;
confirm_unsel_alpha = 1.0;
confirm_unsel_scale = 1.0;
confirm_unsel_idx   = -1;

// Phase 1 float-up: selected dice rise from popup to hover position
confirm_hover_frame   = 0;          // 0..12
confirm_dice_init_x   = [0, 0];     // where dice were in popup slot when confirm clicked
confirm_dice_init_y   = [0, 0];     // same for Y

// Phase 2: Selected dice zoom pulse (kept for compatibility, not currently used)
confirm_pulse_frame = 0;
confirm_pulse_scale = 1.0;

// Phase 3: Dice fly to pawn, 20 frames
confirm_fly_frame   = 0;
confirm_fly_start_x = [0, 0];  // hover target position (also fly-from position)
confirm_fly_start_y = [0, 0];
confirm_fly_values  = [0, 0];

// Phase 4: Panel slides out, 15 frames
confirm_panel_frame   = 0;
confirm_panel_y_bonus = 0;
confirm_panel_alpha   = 1.0;

// Phase 5: Launch delay — wait for bottom panel before releasing pawn
confirm_launch_delay = 0;

dice_total = 0;

// ─── DICE EXPLOSION PARTICLES (managed entirely in obj_gui for correct draw order) ───
dice_particles = [];

// ─── STATS POPUP ───
stats_popup_open  = false;
stats_popup_alpha = 0.0;
stats_popup_y_slide = 100; // Slide offset (starts from bottom)
can_interact_gui = true;
