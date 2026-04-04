/// @description Global Game Constants

// ==========================================
// ─── GUI CONSTANTS ───
// ==========================================

// Global Colors
#macro C_DARKGRAY  make_color_rgb(40, 40, 40)
#macro C_EMERALD   make_color_rgb(6, 214, 160)
#macro C_MAIN_GOLD make_color_rgb(248, 194, 58)
#macro C_PURE_GOLD make_color_rgb(255, 215, 0)

// Topbar Dimensions
#macro GUI_PAD_X       40
#macro GUI_TOPBAR_H    180
#macro GUI_BTN_MAP_W   190
#macro GUI_BTN_MAP_H   64
#macro GUI_BTN_SM_W    110
#macro GUI_BTN_SM_H    56

// Bottom Panel Dimensions
#macro GUI_BTN_MAIN_W  320
#macro GUI_BTN_MAIN_H  90
#macro GUI_BTN_SIDE_W  240
#macro GUI_BTN_SIDE_H  90
#macro GUI_BTN_GAP     24
#macro GUI_PANEL_H     240

// UI Component Settings
#macro GUI_DICE_SCALE  0.55
#macro GUI_CARD_SCALE  0.74


// ==========================================
// ─── GAMEPLAY CONSTANTS ───
// ==========================================

#macro C_PAWN_SHADOW   make_color_rgb(180, 180, 180)
#macro C_BG_DEFAULT    #0D2E19

// Board Values
#macro BOARD_PAD_X     40
#macro BOARD_PAD_Y     200
#macro BOARD_AREA_H    680
#macro BOARD_TILE_GAP  12
#macro BOARD_LIFT_MAX  18
#macro BOARD_SPEED     (1/12)

// Pawn Values
#macro PAWN_HOP_H      28
#macro PAWN_HOP_SPD    (1/12)
#macro PAWN_IDLE_H     4
#macro PAWN_IDLE_SPD   0.02


// ==========================================
// ─── STAT CONFIGURATION ───
// ==========================================
// These match the image_index of spr_stats and provide styling data
// 0: Money Management, 1: Luck, 2: Agility, 3: Charisma, 4: Risk Tolerance, 5: Negotiation

global.stat_data = [
    { name: "Money Management", color: #F5B731, icon: 0 },
    { name: "Luck",             color: #E8365D, icon: 1 },
    { name: "Agility",          color: #2ECC71, icon: 2 },
    { name: "Charisma",         color: #F39C12, icon: 3 },
    { name: "Risk Tolerance",   color: #E8365D, icon: 4 },
    { name: "Negotiation",      color: #40C8E0, icon: 5 }
];
