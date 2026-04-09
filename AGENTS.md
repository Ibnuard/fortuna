# AGENT.md — Monopoly Roguelike (GMS2)

> Panduan kerja untuk AI agent dalam membantu development game ini.
> Baca file ini sebelum menulis satu baris kode pun.

---

## 1. Identitas Proyek

| Field           | Value                               |
| --------------- | ----------------------------------- |
| Nama Game       | Monopoly Roguelike                  |
| Engine          | GameMaker Studio 2                  |
| Genre           | Roguelike + Board Game (Turn-based) |
| Bahasa Kode     | GML (GameMaker Language)            |
| Target Platform | PC (prioritas), Mobile (later)      |
| Resolusi        | 1920×1080 (GUI di GUI layer)        |

---

## 2. Arsitektur Game — Gambaran Besar

```
Run
 └── Map 1 → Map 2 → Map 3 → Map 4 → Map 5 (Boss)
      └── Setiap Map:
           ├── N Putaran (Turn)
           │    └── 1 Turn: [Fate Card Pre-Roll?] → Roll 3 Dadu → Pilih 2 → Move → Tile Effect → Hold Window → Cek Menang/Kalah
           ├── Layar Transisi "Pilih 3 Kartu"
           └── Modal cash dibawa, properti tidak dibawa
```

Satu **Run** = 5 map berurutan. Gagal di map manapun = restart run dari awal (dengan pilihan retry 1× per map dengan penalti).

---

## 3. Core Game Loop — Per Turn

Urutan wajib dalam setiap turn, **jangan ada yang dilewati**:

1. **[Pre-Roll] Fate Card Window** — sebelum dadu dilempar, player bisa pakai fate card bertipe `pre-roll` (misal: Reroll modifier, Geser ±2). Ini opsional dan terbatas resource.
2. **Roll 3 Dadu** — sistem lempar 3 dadu sekaligus (bukan 2). Tampilkan popup animasi ketiga dadu rolling random.
3. **Pilih 2 Dadu** — player memilih 2 dari 3 dadu hasil roll. Jumlah langkah = nilai dadu 1 + nilai dadu 2 yang dipilih. Dadu ke-3 yang tidak dipilih diabaikan.
4. **Move Token** — gerakkan token sejumlah hasil 2 dadu terpilih, satu tile per step dengan animasi.
5. **Tile Effect Resolve** — jalankan efek tile yang didarati (lihat bagian 5).
6. **Hold Card Window** — window singkat setelah tile effect diketahui tapi belum final resolve. Player bisa pakai Hold reaktif (Blok kerugian, Double Down income, dll).
7. **Cek Menang/Kalah** — apakah cash ≥ target? Apakah cash ≤ 0 dan tidak ada properti?

> **Aturan Agent:** Jika diminta implementasi salah satu step, pastikan step lainnya tetap bisa "disambung" — jangan hardcode state yang memutus flow.

---

## 3a. Sistem Dadu — Detail Lengkap

### Flow Popup Dadu

```
Player klik ROLL
  │
  ├─► [Cek: ada fate card pre-roll di hand?]
  │     ├─ Ada  → tampilkan opsi kartu di popup (bisa dipakai SEBELUM roll)
  │     └─ Tidak ada → popup muncul tanpa section fate card
  │
  ├─► Popup muncul: 3 dadu animasi rolling (random cepat, lalu settle ke nilai final)
  │
  ├─► Player pilih 2 dari 3 dadu (klik/tap dadu yang diinginkan)
  │     └─ Visual: dadu yang dipilih highlight, dadu ke-3 dim/greyed out
  │
  ├─► Tampilkan total = dadu1 + dadu2
  │
  └─► Player konfirmasi → popup tutup → move token
```

### State yang Dibutuhkan

```gml
// Di object controller / turn manager
dice_results[0]   // nilai dadu pertama (1–6)
dice_results[1]   // nilai dadu kedua (1–6)
dice_results[2]   // nilai dadu ketiga (1–6)
dice_selected[0]  // index dadu yang dipilih (0, 1, atau 2)
dice_selected[1]  // index dadu yang dipilih kedua
dice_total        // dice_results[dice_selected[0]] + dice_results[dice_selected[1]]
```

### Aturan Popup

- Popup **selalu muncul** setiap turn, tidak ada skip.
- Jika player **tidak punya fate card pre-roll** → popup tampil tanpa section kartu sama sekali (bukan di-grey out, tapi benar-benar tidak ada UI-nya).
- Jika player **punya fate card pre-roll** → tampilkan kartu di popup. Player bisa pakai kartu **sebelum** dadu di-roll (kartu dipakai dulu, baru roll).
- Player **wajib** memilih tepat 2 dadu sebelum bisa konfirmasi. Tombol konfirmasi disabled sampai 2 dadu dipilih.
- Tidak ada timeout — popup menunggu input player.

### Fate Card yang Berlaku di Timing Pre-Roll

Hanya kartu dengan tag timing `pre-roll` yang muncul di popup ini:

| Kartu                   | Efek di Pre-Roll                                                                     |
| ----------------------- | ------------------------------------------------------------------------------------ |
| Reroll                  | Setelah roll 3 dadu dan lihat hasilnya, bisa re-roll semua 3 dadu sekali lagi        |
| Intuisi Jalan (Passive) | Otomatis aktif — setelah pilih 2 dadu, bisa geser total ±1 gratis sekali per putaran |

> **Catatan:** Passive "Dadu Jinak" tidak butuh aksi di popup — efeknya adalah player **selalu** lihat hasil sebelum konfirmasi, yang memang sudah default di sistem baru ini.

### Contoh GML Skeleton

```gml
/// scr_dice_roll()
// Dipanggil saat player klik ROLL di popup

function scr_dice_roll() {
    // Roll 3 dadu
    dice_results[0] = irandom_range(1, 6);
    dice_results[1] = irandom_range(1, 6);
    dice_results[2] = irandom_range(1, 6);

    // Reset pilihan
    dice_selected[0] = -1;
    dice_selected[1] = -1;
    dice_total = 0;

    // Trigger animasi rolling di popup object
    with (obj_popup_dice) { state = DICE_STATE.ROLLING; }
}

/// scr_dice_confirm(idx_a, idx_b)
// Dipanggil saat player pilih 2 dadu dan konfirmasi

function scr_dice_confirm(idx_a, idx_b) {
    dice_selected[0] = idx_a;
    dice_selected[1] = idx_b;
    dice_total = dice_results[idx_a] + dice_results[idx_b];

    // Tutup popup, lanjut ke move
    instance_destroy(obj_popup_dice);
    scr_token_move(dice_total);
}
```

---

## 4. Struktur Data Penting

### Player State (harus ada di semua map)

```gml
// Disimpan di global atau persistent object
global.cash           // integer, tidak boleh negatif kecuali saat cek bangkrut
global.properties[]   // array of property structs {id, level, mortgaged}
global.passive_cards[] // max 5 slot
global.hold_cards[]    // max 3 slot
global.turn_current   // integer
global.turn_max       // dari config map
global.target_cash    // modal_awal × multiplier map
global.map_current    // 1–5
global.modal_awal     // cash di awal map ini (untuk hitung target)
```

### Property Struct

```gml
{
  id:         string,   // unique identifier tile
  name:       string,
  price:      integer,
  rent_base:  integer,  // 10% dari price untuk self-rent lewat
  level:      integer,  // 0=kosong, 1=toko, 2=hotel
  mortgaged:  bool,
  owner:      "player" | "none"
}
```

### Fate Card Struct

```gml
{
  id:     string,
  name:   string,
  type:   "instant" | "passive" | "hold",
  effect: string,   // function name atau enum effect
  active: bool      // untuk passive yang bisa hangus (Asuransi Total)
}
```

---

## 5. Tile Types & Logic

### Property Tile

- Belum dimiliki → tawaran beli. Player bisa skip.
- Milik sendiri + level < 2 → tawarkan upgrade (Toko→Hotel). Harga upgrade = 50% harga tile.
- Lewat tile milik sendiri (bukan landing) → terima **self-rent = 10% harga tile** otomatis.
- `passive "Developer"` aktif → biaya upgrade −30%.

### Fate Card Tile

- Ambil 1 kartu acak dari deck map saat ini.
- Instant → resolve langsung, tidak bisa ditolak (kecuali ada Hold "Penangkal").
- Passive → cek slot passive. Jika penuh (5/5), player harus buang 1 dulu.
- Hold → cek slot hold. Jika penuh (3/3), player harus buang 1 dulu.

### Jail Tile

- Player masuk penjara. Pilihan:
  1. Bayar denda (nilai dari config map, mahal)
  2. Roll doubles (2 angka sama) dalam 3 kesempatan, atau bayar denda
  3. Pakai Hold card "Bail Out" → bebas langsung
- Selama di penjara, turn tetap jalan tapi player tidak bergerak.

### Casino Tile

Player mendarat di Casino → muncul **popup slot machine**. Flow:

```
Landing di Casino Tile
  │
  ├─► Popup muncul: tampilkan slot machine + 4 tombol pilihan
  │     ├─ [Bet 25%]   → bet = floor(cash × 0.25)
  │     ├─ [Bet 50%]   → bet = floor(cash × 0.50)
  │     ├─ [Tidak Bet] → tutup popup, tidak ada efek, turn lanjut
  │     └─ (Bet 100% dihapus dari sistem)
  │
  ├─► Player pilih bet size (atau tidak bet)
  │
  ├─► Animasi slot machine: 3 reel berputar lalu berhenti satu per satu
  │
  ├─► Evaluasi hasil simbol:
  │     ├─ 3 simbol sama (Jackpot) → menang ×1.5 dari bet  [bet kecil reward]
  │     ├─ 2 simbol sama (Match)   → menang ×2.0 dari bet  [bet medium reward]
  │     └─ 0 simbol sama (Kalah)   → kalah, kurangi bet dari cash
  │
  └─► Tampilkan hasil → tutup popup → turn lanjut
```

#### Tabel Bet & Multiplier

| Pilihan   | Jumlah Bet | Jackpot (3 sama) | Match (2 sama) | Kalah (0 sama) |
| --------- | ---------- | ---------------- | -------------- | -------------- |
| Bet 25%   | 25% cash   | +×1.5 bet        | +×2.0 bet      | −bet           |
| Bet 50%   | 50% cash   | +×1.5 bet        | +×2.0 bet      | −bet           |
| Tidak Bet | 0          | —                | —              | —              |

> **Contoh:** Cash = 1000, Bet 50% → bet = 500.
>
> - Jackpot (3 sama): dapat +750 → total cash 1750
> - Match (2 sama): dapat +1000 → total cash 2000
> - Kalah: kehilangan 500 → total cash 500

#### Simbol Slot

- Jumlah jenis simbol: **bebas secara visual** (misalnya 🍒🔔💎 dll), tapi RNG-nya cukup 3 nilai (0, 1, 2).
- Probabilitas tiap reel: masing-masing simbol kemungkinan sama (1/3 per simbol).
- Probabilitas jackpot (3 sama): `(1/3)² = ~11%`
- Probabilitas match (2 sama): `~44%` (any 2 of 3 match, minus jackpot)
- Probabilitas kalah: `~44%`

#### Passive "Penjudi Ulung" — Update

Passive ini sebelumnya membuka opsi "bet medium". Karena sistem sekarang sudah pakai bet % dan multiplier dari simbol, efek passive **Penjudi Ulung diupdate** menjadi:

- **Penjudi Ulung (baru):** Di Casino, jika hasil 2 simbol sama (Match), multiplier naik dari ×2.0 menjadi ×2.5.

#### State yang Dibutuhkan

```gml
casino_bet_amount   // integer, hasil floor(cash × bet_pct)
casino_bet_pct      // 0.25 atau 0.50 (0 jika tidak bet)
casino_reel[0]      // hasil simbol reel 1 (0, 1, atau 2)
casino_reel[1]      // hasil simbol reel 2
casino_reel[2]      // hasil simbol reel 3
casino_result       // "jackpot" | "match" | "lose" | "no_bet"
```

#### Skeleton GML

```gml
/// scr_casino_spin(bet_pct)
// Dipanggil saat player konfirmasi bet
// bet_pct = 0.25, 0.50, atau 0 (tidak bet)

function scr_casino_spin(bet_pct) {
    if (bet_pct == 0) {
        // Tidak bet — langsung tutup popup
        instance_destroy(obj_popup_casino);
        scr_turn_next();
        exit;
    }

    casino_bet_amount = floor(global.cash * bet_pct);
    casino_bet_pct    = bet_pct;

    // Roll 3 reel
    casino_reel[0] = irandom(2); // 0, 1, atau 2
    casino_reel[1] = irandom(2);
    casino_reel[2] = irandom(2);

    // Tentukan hasil
    var _match = 0;
    if (casino_reel[0] == casino_reel[1]) _match++;
    if (casino_reel[1] == casino_reel[2]) _match++;
    if (casino_reel[0] == casino_reel[2]) _match++;

    if (_match == 3) {
        casino_result = "jackpot"; // 3 sama
    } else if (_match >= 1) {
        casino_result = "match";   // 2 sama
    } else {
        casino_result = "lose";
    }

    // Trigger animasi reel di popup
    with (obj_popup_casino) { state = CASINO_STATE.SPINNING; }
}

/// scr_casino_resolve()
// Dipanggil setelah animasi reel selesai

function scr_casino_resolve() {
    var _penjudi = scr_passive_is_active("penjudi_ulung");

    switch (casino_result) {
        case "jackpot":
            global.cash += floor(casino_bet_amount * 1.5);
            break;
        case "match":
            var _mult = _penjudi ? 2.5 : 2.0;
            global.cash += floor(casino_bet_amount * _mult);
            break;
        case "lose":
            global.cash -= casino_bet_amount;
            global.cash  = max(0, global.cash); // jangan negatif di sini
            break;
    }

    // Tampilkan hasil, lalu tutup popup
    with (obj_popup_casino) { state = CASINO_STATE.RESULT; }
}
```

### Start Tile (lewat atau landing)

- Terima bonus cash (nilai dari config map).
- Semua properti bayar passive rent sekarang.
- Pilih 1 dari 2 fate card acak (player pilih, bukan auto-resolve).

### Market Tile

- Tampilkan 3 fate card dengan harga masing-masing.
- Player bisa beli 0, 1, 2, atau semua (jika cukup cash).
- Refresh kartu bayar 100 cash.
- `passive "Broker"` aktif → semua harga −20%.
- Market tile **tidak muncul di Map 1**.

---

## 6. Fate Cards — Referensi Lengkap

### Instant Cards

| Nama               | Efek                                                     |
| ------------------ | -------------------------------------------------------- |
| Windfall           | +500 cash. Jika passive Akuntan aktif, ×1.5              |
| Subsidi Pemerintah | +200 × jumlah properti dimiliki                          |
| Audit Pajak        | −15% dari cash saat ini                                  |
| Bencana Alam       | 1 properti random hilang semua bangunan (level → 0)      |
| Lelang Properti    | Beli 1 properti di map ini harga 50% normal, sekali saja |
| Boom Ekonomi       | Semua properti milik player bayar passive rent sekarang  |

### Passive Cards (max 5 slot)

| Nama           | Efek                                                                     | Tipe         |
| -------------- | ------------------------------------------------------------------------ | ------------ |
| Akuntan        | +15% semua income sewa dan passive rent                                  | rent build   |
| Developer      | Biaya upgrade Toko/Hotel −30%                                            | rent build   |
| Intuisi Jalan  | Sekali per putaran, geser dadu ±1 gratis                                 | dice build   |
| Dadu Jinak     | Lihat hasil dadu sebelum putuskan pakai modifier Hold                    | dice build   |
| Asuransi Total | Blok 1× kerugian besar per map, lalu hangus                              | survival     |
| Penjudi Ulung  | Di Casino, jika hasil Match (2 simbol sama), multiplier naik ×2.0 → ×2.5 | casino build |

### Hold Cards (max 3 slot, sekali pakai)

| Nama           | Efek                                           | Timing               |
| -------------- | ---------------------------------------------- | -------------------- |
| Bail Out       | Keluar Jail gratis                             | kapan saja di Jail   |
| Reroll         | Lempar ulang dadu setelah lihat hasil          | Step 2 (pre-move)    |
| Penangkal      | Blok 1 Instant card negatif                    | Hold Window (Step 5) |
| Double Down    | Gandakan income dari tile ini                  | Hold Window (Step 5) |
| Teleport       | Pindah ke tile manapun, tanpa efek tile tujuan | Step 2 (pre-move)    |
| Akuisisi Paksa | Beli properti manapun harga 70% normal         | kapan saja           |

---

## 7. Kondisi Menang & Kalah

### Menang Per Map

- `cash >= target_cash` kapan saja dalam turn → map clear.
- Tampilkan layar transisi "Pilih 3 Kartu" sebelum lanjut ke map berikutnya.
- **Sell Window:** di 3 putaran terakhir sebelum target tercapai, properti bisa dijual harga penuh (biasanya 50%). Agent wajib implement countdown ini.

### Soft Fail

- Habis `turn_max` putaran tapi `cash < target_cash`.
- Map diulang: `cash -= cash * 0.20`, semua hold card hangus, passive tetap.
- Bisa retry **1× saja**. Gagal lagi → Game Over.

### Bangkrut (Game Over)

- `cash <= 0` DAN tidak ada properti yang bisa digadai → Game Over, run berakhir.
- Selagi ada properti → player bisa gadai untuk survive (harga gadai = 50% harga tile).

---

## 8. Sistem Progression Antar Map

### Layar Transisi "Pilih 3 Kartu"

- Tampilkan semua passive + hold card yang dimiliki.
- Player pilih maksimal **3 kartu total** (bebas kombinasi).
- Kartu tidak dipilih **hangus permanen**.
- Jika total kartu ≤ 3 → semua otomatis terbawa.
- Setelah pilih, player terima **1 kartu reward** dari 3 pilihan. Kartu ini langsung masuk (total bisa 4 di awal map baru).

### Yang Dibawa ke Map Berikutnya

- Cash: **100% dibawa utuh**
- Properti: **tidak dibawa** (tiap map board baru)
- Kartu: **max 3 yang dipilih + 1 reward**

---

## 9. Config Per Map

| Map | Nama              | Tiles | Target | Putaran | Deck Positif | Catatan                                  |
| --- | ----------------- | ----- | ------ | ------- | ------------ | ---------------------------------------- |
| 1   | Kota Kecil        | 12    | ×1.5   | 15      | 70%          | Tutorial implisit, Market belum ada      |
| 2   | Kota Industri     | 20    | ×2     | 18      | 50%          | Jail & Casino mulai muncul               |
| 3   | Kota Metropolitan | 32    | ×2.5   | 20      | 40%          | Properti premium, penalti lebih berat    |
| 4   | Pusat Keuangan    | 40    | ×3     | 18      | 35%          | Volatilitas tinggi, Market tile sering   |
| 5   | Wall Street       | 52    | ×4     | 16      | 25%          | Boss Map, event "Market Crash" −30% cash |

### Komposisi Tile

- 60% Property tiles
- 25% Fate Card tiles
- 15% Special tiles (1 Start, 1–2 Jail, 1–2 Casino, 1 Market ab map 2, sisanya netral)

---

## 10. Build Paths — Referensi Sinergi

Agent harus memahami ini agar tidak implement kartu yang saling bertentangan:

| Build         | Kartu Inti                             | Playstyle                                         |
| ------------- | -------------------------------------- | ------------------------------------------------- |
| Rent Snowball | Akuntan + Developer + Double Down      | Beli semua properti, lewat Start sesering mungkin |
| Casino Runner | Penjudi Ulung + Intuisi Jalan + Reroll | Arahkan dadu ke Casino, high risk-reward          |
| Control Freak | Dadu Jinak + Intuisi Jalan + Teleport  | Hampir tidak pernah kena tile negatif             |
| Survivalist   | Asuransi Total + Penangkal + Bail Out  | Defensive, income lambat tapi tidak bangkrut      |

**Sinergi kuat yang harus diperhatikan:**

- `Akuntan + Developer` → ROI properti berlipat ganda (income naik, cost turun)
- `Dadu Jinak + Intuisi Jalan` → kontrol pergerakan hampir sempurna

---

## 11. GUI & Visual Guidelines

- Resolusi target: **1920×1080**
- Semua GUI di **GUI layer** GMS2 (`draw_gui` event)
- HUD wajib tampil: Cash saat ini, Target cash, Turn sisa, Passive card aktif, Hold card di tangan
- Turn counter harus selalu visible — ini info kritis untuk player
- Sprite panel: gunakan **nine-slice** untuk elemen yang di-stretch horizontal
  - Sprite panel dibuat kecil (misal 200×80px), nine-slice guide ≈ sama dengan corner radius
  - Draw dengan `draw_sprite_stretched()`
- Shadow/efek tegas: gunakan `draw_rectangle` dengan alpha, bukan sprite blur
- Font: pixel-style untuk judul/badge, clean sans untuk body text
- Color palette sudah ditetapkan (lihat `color_palette.md` jika ada)

---

## 12. Aturan Kerja Agent

### Yang Wajib Dilakukan

- Selalu tanyakan konteks sebelum menulis kode: "ini untuk object apa, event apa?"
- Tulis GML yang **modular** — tiap tile type punya script/function sendiri, bukan satu if-else raksasa
- Gunakan `struct` dan `array` untuk data (bukan variable `_01`, `_02`, dsb.)
- Setiap function harus punya komentar singkat tujuannya
- Jika ada pilihan implementasi, sebutkan trade-off-nya sebelum nulis kode

### Yang Dilarang

- Jangan hardcode angka balance (harga tile, multiplier target, dll) — taruh di config/constant
- Jangan buat sistem yang memutus turn flow (lihat bagian 3)
- Jangan implement fitur yang tidak ada di GDD ini tanpa konfirmasi
- Jangan pakai `global.` untuk state yang bisa jadi local

### Prioritas Implementasi (urutan disarankan)

1. Core turn loop (roll → move → tile effect → cek menang/kalah)
2. Property system (beli, upgrade, self-rent)
3. Fate card system (draw, resolve instant, slot passive/hold)
4. Jail mechanic
5. Casino mechanic
6. Market mechanic
7. Layar transisi antar map + card selection
8. Map config system (agar mudah tambah/ubah map)
9. Boss event Map 5 (Market Crash)
10. Polish & balancing

---

## 13. Glosarium

| Term           | Artinya                                                   |
| -------------- | --------------------------------------------------------- |
| Run            | Satu playthrough penuh (Map 1–5)                          |
| Map            | Satu stage/level dengan board sendiri                     |
| Turn / Putaran | Satu siklus: roll dadu sampai cek menang/kalah            |
| Passive        | Kartu efek permanen, aktif selama dibawa                  |
| Hold           | Kartu disimpan di tangan, dipakai kapan mau, sekali pakai |
| Instant        | Kartu yang langsung resolve saat ditarik                  |
| Self-rent      | Income kecil saat token lewat properti milik sendiri      |
| Sell Window    | 3 turn terakhir, properti bisa dijual harga penuh         |
| Soft Fail      | Kehabisan turn tanpa capai target — retry dengan penalti  |
| Bangkrut       | Cash ≤ 0 dan tidak ada properti — Game Over               |
