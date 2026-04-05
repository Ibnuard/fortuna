/// @description Draw Modular GUI Components
// The z-ordering (drawing order) is strictly preserved from the original monolithic file.
// CRITICAL: Shader vignette is BEHIND all GUI elements, but Shader scanlines is ON TOP of everything.

// 1. SHADER: VIGNETTE ONLY (Behind GUI Panels & Buttons)
mod_fx.draw_vignette();

// 2. TOP BAR (Background, text, target bar)
mod_topbar.draw();

// 3. BOTTOM CONTAINER BORDERS / SHAPES
mod_bottom.draw_panel();

// 4. INTERACTIVE BUTTONS (Top and Bottom)
mod_topbar.draw_buttons();
mod_bottom.draw_buttons();

// 5. PROPERTY OVERLAY
mod_property.draw();

// 6. DICE POPUP
mod_dice.draw();

// 7. CONFIRM ANIMATION
mod_confirm.draw();

// 8. POPUPS (Stats & Map)
mod_skills.draw();
mod_stats.draw();
mod_map.draw();

// 9. SHADER: SCANLINES ONLY (On top of everyone except particles)
mod_fx.draw_scanline();

// 10. JUICE & PARTICLES (Absolute topmost)
mod_fx.draw_particles();
