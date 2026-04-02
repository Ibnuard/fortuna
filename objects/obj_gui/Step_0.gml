// Determine target offsets based on state
target_bottom_offset = (gui_state == "MAIN") ? 0 : 300; // Slide main UI down if not in main state
var _target_prop_offset = (gui_state == "PROPERTY") ? 0 : 800; // Slide prop UI up if active

// Smoothly animate the main panel
if (abs(bottom_y_offset - target_bottom_offset) > 0.5) {
    bottom_y_offset = lerp(bottom_y_offset, target_bottom_offset, animation_speed);
} else {
    bottom_y_offset = target_bottom_offset;
}

// Smoothly animate the property panel
if (abs(property_y_offset - _target_prop_offset) > 0.5) {
    property_y_offset = lerp(property_y_offset, _target_prop_offset, animation_speed);
} else {
    property_y_offset = _target_prop_offset;
}
