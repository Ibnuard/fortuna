/// @description Modular Step Logic

mod_fx.step();
mod_topbar.step();
mod_bottom.step();
mod_property.step();
mod_confirm.step();
mod_dice.step();
mod_stats.step();
mod_map.step();

// ─── INTERACTION BLOCKING ───
// Main HUD buttons are blocked if:
// 1. A popup (Stats/Map) is open or fading in
// 2. Dice selection state is active
// 3. Confirm animation is flying (dice in the air)
can_interact_gui = (!stats_popup_open && stats_popup_alpha <= 0 && !map_popup_open && map_popup_alpha <= 0 && gui_state != "DICE" && gui_state != "MOVING");
