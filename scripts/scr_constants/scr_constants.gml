/// @description Global Game Constants

// ─── STAT CONFIGURATION ───
// These match the image_index of spr_stats and provide styling data
// 0: Money Management, 1: Luck, 2: Agility, 3: Charisma, 4: Risk Tolerance, 5: Communication

global.stat_data = [
    { name: "Money Management", color: #F5B731, icon: 0 },
    { name: "Luck",             color: #E8365D, icon: 1 },
    { name: "Agility",          color: #2ECC71, icon: 2 },
    { name: "Charisma",         color: #F39C12, icon: 3 },
    { name: "Risk Tolerance",   color: #E8365D, icon: 4 },
    { name: "Communication",    color: #9B59B6, icon: 5 }
];

// Helper to get hex from string if needed, but #HEX works in GML 2023+
// Negotiation color was mentioned but Communication is index 5.
// I'll keep Negotiation as an alias color if needed: #40C8E0
global.color_negotiation = #40C8E0;
