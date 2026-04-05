// Ensure Gameplay Controller exists
if (!instance_exists(obj_controller)) {
    instance_create_layer(0, 0, "Instances", obj_controller);
}

gui_state = "MAIN"; // "MAIN" | "DICE" | "MOVING" | "PROPERTY"

skills_popup_open  = false;
skills_popup_alpha = 0.0;
skills_popup_y_slide = 100;

stats_popup_open  = false;
stats_popup_alpha = 0.0;
stats_popup_y_slide = 100;

map_popup_open  = false;
map_popup_alpha = 0.0;
map_popup_y_slide = 100;

can_interact_gui = true;
animation_speed = 0.13; // Smoothness multiplier (closer to 0 is smoother/slower)

// ─── INITIALIZATION OF MODULES (Controller-Struct Pattern) ───
// We isolate the state and logic into completely segregated GM scripts.
// The "id" allows the structs to refer back strictly to core states like `gui_state`.

mod_fx       = new GuiModuleFx(id);
mod_topbar   = new GuiModuleTopbar(id);
mod_bottom   = new GuiModuleBottom(id);
mod_property = new GuiModuleProperty(id);
mod_confirm  = new GuiModuleConfirm(id);
mod_dice     = new GuiModuleDice(id);
mod_skills    = new GuiModuleSkills(id);
mod_map      = new GuiModuleMap(id);
