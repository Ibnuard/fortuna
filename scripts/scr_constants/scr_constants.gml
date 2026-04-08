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
#macro GUI_TOPBAR_H    160
#macro GUI_BTN_MAP_W   190
#macro GUI_BTN_MAP_H   64
#macro GUI_BTN_SM_W    110
#macro GUI_BTN_SM_H    56

// Bottom Panel Dimensions
#macro GUI_BTN_MAIN_W  360
#macro GUI_BTN_MAIN_H  100
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
#macro BOARD_LIFT_MAX  48 // Ditingkatkan agar efek cekung lebih terasa pada tile tinggi
#macro BOARD_SPEED     (1/12)

// Pawn Values
#macro PAWN_HOP_H      28
#macro PAWN_HOP_SPD    (1/12)
#macro PAWN_IDLE_H     4
#macro PAWN_IDLE_SPD   0.02


// ==========================================
// ─── STAT CONFIGURATION ───
// ==========================================
// Pawn Skills (Dummy Pawn) - Ordered to match spr_skills indices
// 0: Money Management, 1: Luck, 2: Charisma, 3: Risk Tolerance, 4: Negotiation

global.stat_data = [
    { name: "Money Management", color: #F5B731, icon: 0, desc: "Improves your ability to handle cash, reducing fines and taxes." },
    { name: "Luck",             color: #E8365D, icon: 1, desc: "Higher chance of favorable outcomes from Fate cards and Casino." },
    { name: "Charisma",         color: #F39C12, icon: 3, desc: "Lowers the cost of buying properties and upgrades." },
    { name: "Risk Tolerance",   color: #E8365D, icon: 4, desc: "Higher rewards when taking dangerous paths or high-stakes bets." },
    { name: "Negotiation",      color: #40C8E0, icon: 5, desc: "Reduces rent you pay to others, and increases rent you collect." }
];

// Statistics configuration for spr_stats
global.pawn_stats_data = [
    { name: "Total Property Owned", icon: 0, type: "number" },
    { name: "Total House",          icon: 1, type: "number" },
    { name: "Total Hotel",          icon: 2, type: "number" },
    { name: "Income / Turn",       icon: 3, type: "currency" },
    { name: "Tax Rate",             icon: 4, type: "percent" },
    { name: "Tax / Turn",           icon: 5, type: "currency" },
    { name: "Net / Turn",           icon: 6, type: "currency" }
];
