/// @description Draw Modular GUI Components
// The z-ordering (drawing order) is strictly preserved from the original monolithic file.
// CRITICAL: Shader vignette is BEHIND buttons, but Shader scanlines is ON TOP of everything.

// 1. TOP BAR
mod_topbar.draw();

// 2. BOTTOM CONTAINER BORDERS / SHAPES
mod_bottom.draw_panel();

// 3. SHADER: VIGNETTE ONLY (Behind Buttons)
mod_fx.draw_vignette();

// 4. INTERACTIVE BUTTONS (Top and Bottom)
mod_topbar.draw_buttons();
mod_bottom.draw_buttons();

// 5. PROPERTY OVERLAY
mod_property.draw();

// 6. DICE POPUP
mod_dice.draw();

// 7. CONFIRM ANIMATION
mod_confirm.draw();

// 8. STATS POPUP
mod_stats.draw();

// 9. SHADER: SCANLINES ONLY (On top of everyone except particles)
mod_fx.draw_scanline();

// 10. JUICE & PARTICLES (Absolute topmost)
mod_fx.draw_particles();
