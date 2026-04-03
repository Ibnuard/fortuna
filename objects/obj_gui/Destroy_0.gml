/// @description Cleanup
if (surface_exists(surf_panel)) {
    surface_free(surf_panel);
}
if (surface_exists(surf_topbar)) {
    surface_free(surf_topbar);
}
