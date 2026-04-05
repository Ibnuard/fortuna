# 🎲 Game Concept Document
> Monopoly Roguelike — Simple, Replayable, Challenging

**Document Version 3.0** — Updated with Map Boss Mechanic & Difficulty Scaling

---

## 🎯 Core Philosophy
Complexity datang dari **tiga sumber yang saling melengkapi**:
1. **Skill** — permanent dalam satu run, dibentuk tiap beat map
2. **Fate Cards** — temporary per map, sumber chaos & synergy
3. **Map Boss** — efek negatif yang counter skill player, bikin late game tetap tegang

> Inspired by Balatro: simple di surface, deep di execution.
> Kalah = full reset. Replayability dari discovery & kombinasi, bukan grind.

---

## 🔄 Core Loop (Per Map)
```
Pilih Pawn (awal run)
→ Roll 3 Dadu → Pilih 2
→ Move di Board
→ Tile Effect
→ Akumulasi Uang
→ Beat Target sebelum Turn Habis
→ Pilih 1 dari 3 Skill Baru
→ Lanjut ke Map Berikutnya
```

---

## 🏆 Run Structure
```
Pilih Pawn
→ Map 1 (Indonesia) + Fate Cards
→ Beat Target → Pilih 1 dari 3 Skill
→ Map 2 (Jepang) + Fate Cards BARU
→ Beat Target → Pilih 1 dari 3 Skill
→ Map 3 (Amerika) + Fate Cards BARU
→ Beat Target → 🏆 WIN — Run Complete!

Kalah di mana saja → RESET TOTAL → Main lagi dari awal
```

**Fate Cards hilang setiap pindah map. Skill tetap dalam satu run.**

---

## 💰 Resource
Hanya **1 resource → UANG**
Tidak ada stats, tidak ada XP, tidak ada resource lain.

---

## 🎭 Pawn System

Pilih di awal run — menentukan **playstyle base** dan **skill pool** yang tersedia.

### 3 Pawn Tersedia

| Pawn | Passive Bawaan | Playstyle |
|------|----------------|-----------|
| 🎩 **Businessman** | Lewati property → income x1.5 | Income & property focused |
| 🎲 **Gambler** | Casino selalu dapat 2x lipat | High risk, high reward |
| ❓ **[TBD]** | TBD | Board manipulation / kontrol posisi |

> Tiap pawn punya **skill pool sendiri** — skill yang ditawarkan saat beat map sesuai dengan karakter pawn.

---

## 🧠 Skill System (Baru)

### Cara Dapat Skill
- **Beat target di setiap map** → dapat pilih **1 dari 3 skill** yang ditawarkan
- Skill ditawarkan **random dari pool pawn yang dipilih**
- Setelah Map 3 selesai, maksimal punya **3 skill** (1 bawaan + 2 dari beat map)

### Slot Skill
```
Max slot: 5 skill
- 1 slot → Passive bawaan pawn (tidak bisa diganti)
- 4 slot → Diisi dari beat map (pilih atau buang)
```

Saat slot penuh dan dapat skill baru → **pilih: ganti salah satu atau buang skill baru.**

### Contoh Skill Pool — Businessman
| Skill | Efek |
|-------|------|
| **Real Estate** | Income dari lewati property +25% |
| **Portfolio** | Tiap 3 property dimiliki → income x2 |
| **Compound Interest** | Income landing property carry ke turn berikutnya |
| **Monopoli** | Jika punya semua property 1 warna → income x3 |

### Contoh Skill Pool — Gambler
| Skill | Efek |
|-------|------|
| **All In** | Taruhan casino bisa 3x lipat (bukan 2x) |
| **Lucky Streak** | Menang casino 2x berturut → turn bonus |
| **Risk Appetite** | Semakin sedikit uang, semakin besar casino multiplier |
| **House Edge** | Casino penalty berkurang 50% |

---

## 🃏 Fate Cards

Didapat dari tile Fate atau dibeli di Market.
**Hilang setiap pindah map** — sumber chaos & synergy sementara.

### Contoh Fate Cards
| Card | Efek |
|------|------|
| **Momentum** | Lewati property = income x2 satu loop |
| **Hot Streak** | 3 turn ke depan semua income double |
| **Loaded Dice** | Roll 4 dadu, buang 2 |
| **Warp** | Teleport ke tile manapun |
| **Windfall** | Instant +uang besar |
| **Shortcut** | Potong board, langsung ke START |
| **Tax Break** | Skip bayar Casino penalty 3 turn |
| **Double Down** | Landing income x2 turn ini |

Fate Cards **random setiap map** → kombinasi berbeda tiap playthrough.

---

## 🗺️ Board & Tiles

### Tile Types
| Tile | Warna | Efek |
|------|-------|------|
| **Property** | Merah `#E63A4F` | Beli → dapat income |
| **Market** | Hijau `#00D69F` | Beli item / Fate Card |
| **Casino** | Cyan `#02B5D8` | Gamble uang |
| **Fate** | Ungu `#9C5DE5` | Ambil Fate Card |
| **Jail** | Abu `#545454` | Skip 1 turn |
| **Start** | Kuning `#F9C138` | +Bonus uang saat dilewati |

### Board per Map
| Level | Tiles | Sisi |
|-------|-------|------|
| Map 1 — Indonesia 🇮🇩 | 16 | 5x5 |
| Map 2 — Jepang 🇯🇵 | 20 | 6x6 |
| Map 3 — Amerika 🇺🇸 | 24 | 7x7 |

Tile order **random setiap run** → replayable.

---

## 💵 Income System

### Modal Awal
Player di-**modali di awal run** → bisa langsung beli property dari turn pertama.

### Lewati Property (Guaranteed)
Setiap melewati property yang sudah dibeli → **+income kecil otomatis**
Player selalu dapat income tiap loop — tidak tergantung RNG landing.

### Landing di Property (Bonus)
Tepat landing di property sendiri → **+income besar (bonus)**
Rewarding tapi tidak wajib — pilihan strategis saat dice selection.

```
Modal awal  → beli property pertama
Lewati      → +income kecil  (guaranteed, tiap loop)
Landing     → +income besar  (bonus, skill-based)
Start tile  → +bonus uang saat dilewati (sustain mid-late game)
```

---

## 🎯 Win & Lose Condition

| Kondisi | Hasil |
|---------|-------|
| Capai target uang sebelum turn habis (per map) | Lanjut ke map berikutnya |
| Beat semua 3 map | **WIN — Run Complete** |
| Turn habis sebelum target tercapai | **LOSE — Full Reset** |

---

## 🔁 Replayability Sources

```
1. Pawn berbeda → skill pool berbeda → playstyle berbeda
2. Skill pilihan berbeda tiap beat map → build berbeda
3. Fate Card random per map → synergy berbeda
4. Tile order random setiap run
5. 3 Map dengan jumlah tile & difficulty berbeda
6. Target uang yang meningkat per map
```

---

## 📢 Feedback System (Tanpa Menu Stats)

### Floating Text
```
Lewati property → "+$180" muncul di atas tile
                  "Businessman Bonus!" di bawahnya
```

### HUD Icon
```
[ 🎩 x1.5 ]  ← pojok layar
Tap → tooltip singkat passive ability
```

### Skill Bar
```
[ Passive ] [ Skill 1 ] [ Skill 2 ] [ - ] [ - ]
Tap salah satu → tooltip efek skill
```

### Fate Card Banner
```
🃏 HOT STREAK aktif — 3 turn tersisa
```

---

## 🗺️ Maps & Boss Mechanic

Tiap map punya **1 Boss Effect** yang aktif sepanjang map — counter skill player yang makin kuat di late game.

| Map | Difficulty | Boss Effect | Vibe |
|-----|------------|-------------|------|
| 🇮🇩 Indonesia | Introductory | ❌ Tidak ada | Learning map, familiar |
| 🇯🇵 Jepang | Medium | **Market Crash** | Tighter, spatial problem |
| 🇺🇸 Amerika | Hard | **Inflation** | High pressure, race against time |

### Boss Effect Detail

**🇯🇵 Market Crash (Jepang)**
```
Setiap 4 turn → 1 property random di-lock selama 2 turn
Property yang di-lock tidak produce income saat dilewati maupun dilanding
```
→ Counter Businessman yang sudah punya banyak property
→ Paksa player adaptasi rute di board

**🇺🇸 Inflation (Amerika)**
```
Target uang naik +10% setiap 5 turn
Makin lama main → target makin jauh
```
→ Counter semua pawn — tidak peduli build apapun
→ Pressure player untuk main cepat & efisien

---

## ⚖️ Balance Design



Sumber minus yang ada:
| Sumber | Tipe | Bisa Dihindari? |
|--------|------|-----------------|
| Fate Card negatif | Random | Sebagian |
| Casino penalty | Player choice | Ya |
| Jail | Minor | Sebagian |
| Map Boss (Market Crash) | Aktif terus | Tidak |
| Map Boss (Inflation) | Aktif terus | Tidak |

Boss mechanic adalah **satu-satunya pressure yang tidak bisa dihindari** — ini yang jaga balance di late game.

---

## ✅ Apa yang Dihapus

| Fitur | Alasan Dihapus |
|-------|---------------|
| Stats panel (6 stats) | Digantikan Skill system |
| Skills panel terpisah | Terintegrasi langsung di HUD |
| Tax system global | Hanya ada di Casino sebagai penalty |
| Negotiation | Masuk ke Fate Card |
| Meta-progression (Legacy Vault) | Tidak perlu — replayability dari kombinasi |
| Income per turn flat | Diganti lewat + landing system |

---

*Document Version 3.0 — Updated from brainstorming session*
*Key changes from v2.0: Added Map Boss Mechanic (Market Crash & Inflation), Balance Design section*