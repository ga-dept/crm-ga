# GA Hotline Portal

Portal internal **General Affairs MRT Jakarta** untuk merangkum permintaan operasional dari kanal **WhatsApp** dan **SmartOffice** dalam satu sistem. Dibangun sebagai *single-page application* (HTML + JS) yang berkomunikasi langsung dengan **Supabase (PostgreSQL)** — tidak memerlukan backend Node/Python.

---

## ✨ Fitur Utama

### Halaman Publik (Landing)
- **Statistik real-time** — total permintaan, jumlah selesai, sedang berjalan, dan permintaan hari ini.
- **Bar chart** distribusi permintaan per kategori.
- **Tracker permintaan** — cek status dengan kode permintaan.
- **Cara penggunaan** dalam 4 langkah.
- **Formulir input** collapsible dengan auto-generate kode permintaan, validasi lampiran, dan format Rupiah otomatis.
- **Halaman penilaian publik** (1–5 bintang + kritik/saran) yang diakses via tautan unik.
- **Riwayat versi** changelog.

### Panel Admin
- **Dashboard** statistik & chart per kategori + tabel ringkas permintaan terbaru.
- **Daftar Permintaan** dengan:
  - Pagination (10 baris per halaman) + sort per kolom + search + filter status.
  - CRUD lengkap melalui modal — update status, keterangan (wajib), total anggaran (delimiter Rupiah), vendor, PIC GA, estimasi penyelesaian.
  - Tombol **rantai** untuk menyalin tautan penilaian (muncul saat status = "Selesai").
  - Ekspor **CSV**.
- **Daftar Penilaian** — seluruh permintaan selesai dengan kolom *Sudah/Belum Dinilai*, tombol info untuk popup detail, ekspor CSV.
- **Master Data** — CRUD untuk Lokasi & Tujuan Kebutuhan (langsung memengaruhi dropdown di formulir publik).
- **Manajemen User** — CRUD user + role (`superadmin` / `admin` / `pic`) + ubah password.
- **Riwayat Versi** changelog yang sama dengan halaman publik.
- **Sidebar dengan hamburger** — collapse di desktop, slide-in overlay di mobile.

### Desain
- Palet **biru tua + hijau** ala MRT Jakarta.
- Font: **Plus Jakarta Sans** (Google Fonts).
- Ikon: **Material Symbols Rounded** dari Google Fonts.
- Sepenuhnya responsif (desktop, tablet, HP).

---

## 📁 Struktur Berkas

```
ga-portal/
├── index.html       ← seluruh aplikasi (HTML + CSS + JS, single file)
├── database.sql     ← skema PostgreSQL untuk Supabase
└── README.md
```

---

## 🚀 Setup

### 1. Siapkan Supabase

1. Buat proyek baru di [supabase.com](https://supabase.com).
2. Buka **SQL Editor** → **New query** → tempelkan seluruh isi `database.sql` → **Run**.
   - Skrip ini idempotent — aman dijalankan ulang.
   - Membuat tabel, fungsi, RLS policy, bucket storage `ga-attachments`, akun admin default, dan data sampel.
3. Buka **Project Settings → API** dan catat:
   - `Project URL` (contoh: `https://xxxx.supabase.co`)
   - `anon` `public` key

### 2. Konfigurasi `index.html`

Buka `index.html`, cari kedua baris ini di awal script (sekitar baris ~960):

```js
const SUPABASE_URL = window.__SUPA_URL__ || 'https://YOUR-PROJECT-REF.supabase.co';
const SUPABASE_ANON_KEY = window.__SUPA_KEY__ || 'YOUR_ANON_KEY';
```

Ganti dengan nilai dari Supabase Anda.

> 💡 **Mode demo** — jika nilai belum diganti, aplikasi otomatis berjalan dengan **data in-memory** (hilang saat refresh). Berguna untuk preview UI tanpa setup Supabase.

### 3. Tambahkan logo

Upload file `logo.png` (ukuran disarankan **square, minimum 128×128 px**) di folder yang sama dengan `index.html`. File ini dipakai sebagai:
- **Favicon** browser
- **Logo** di pojok kiri atas (navbar landing & sidebar admin)
- **Apple touch icon**

Jika `logo.png` belum ada, halaman tetap berjalan normal — placeholder bertuliskan **"GA"** dengan gradien biru-hijau akan tampil sebagai fallback otomatis.

### 4. Jalankan

Karena ini *single HTML file*, Anda bisa:

- **Buka langsung** `index.html` di browser, atau
- **Serve via static server** (disarankan, agar fitur upload Supabase Storage berfungsi):

  ```bash
  # Python
  python3 -m http.server 8000

  # Node
  npx serve .
  ```

  Lalu buka `http://localhost:8000`.

- **Deploy** ke Netlify / Vercel / GitHub Pages / Cloudflare Pages — cukup unggah `index.html` saja.

---

## 🔑 Kredensial Default

| Username | Password   | Role         |
| -------- | ---------- | ------------ |
| `admin`  | `admin123` | superadmin   |
| `ga.budi`| `budi123`  | admin        |
| `ga.siti`| `siti123`  | pic          |

> **Ganti segera setelah login pertama** dari halaman *Manajemen User*.

---

## 🗃️ Skema Database (ringkas)

| Tabel             | Fungsi                                                       |
| ----------------- | ------------------------------------------------------------ |
| `requests`        | Tabel utama permintaan (kode unik, kategori, status, dsb.)   |
| `ratings`         | 1 penilaian per permintaan (1–5 bintang + kritik/saran)      |
| `app_users`       | Akun admin (password bcrypt via `pgcrypto`)                  |
| `lokasi_options`  | Master lokasi (dropdown)                                     |
| `tujuan_options`  | Master tujuan (dropdown)                                     |
| `counters`        | Counter harian untuk nomor urut kode permintaan              |
| `version_history` | Changelog                                                    |

### Fungsi RPC yang dipakai aplikasi

- `fn_generate_request_code(prefix)` — atomic generator kode `PREFIX-DDMMYYYY####`.
- `fn_login(username, password)` — login dengan verifikasi bcrypt.
- `fn_create_user(username, password, full_name, role)` — buat user dengan password bcrypt-hash.
- `fn_set_password(user_id, password)` — ubah password (bcrypt).

### Kode permintaan
Format: `<PREFIX>-DDMMYYYY####`, dengan PREFIX:

| Kategori                                  | Prefix |
| ----------------------------------------- | ------ |
| Food and Beverage                         | FB     |
| Direct Purchase                           | DP     |
| Fasilitas Kantor dan Identitas Karyawan   | FAC    |
| Seragam                                   | UFM    |
| Office Supply                             | OS     |
| Event Support                             | EV     |

Contoh: `FB-120520260001`.

### Status permintaan
`Belum Dikonfirmasi` → `Mencari Penyedia` → `Sedang Disiapkan` → `Tersedia` → `Selesai` | `Ditolak`

---

## 📎 Lampiran (Storage)

- Bucket `ga-attachments` dibuat otomatis (public).
- Tipe yang didukung: **PDF, PNG, JPG** — maksimal **2 MB**.
- Validasi dilakukan di sisi client; bila Supabase Storage tidak dikonfigurasi (mode demo), upload akan dilewati otomatis.

---

## 🔒 Catatan Keamanan (Penting untuk Produksi)

Konfigurasi default sengaja **permisif** agar mudah diuji:

- RLS aktif, namun policy `for all using (true)` — anon dapat read/write ke semua tabel.
- Tabel `app_users` diakses langsung dari client via PostgREST.

**Sebelum produksi**, pertimbangkan:

1. Pisahkan login admin ke **Supabase Auth** atau buat **Edge Function** untuk login (server-side).
2. Perketat RLS:
   - `requests` & `ratings`: anon hanya `SELECT` + `INSERT` (bukan UPDATE/DELETE).
   - Mutasi admin (update/delete/master data/user mgmt) dialihkan ke endpoint dengan `service_role` key (Edge Function), bukan dari client.
3. Audit log untuk perubahan status.
4. Rate-limit untuk endpoint publik (tracker & form submit).
5. Hardening domain CORS di Supabase Storage.

---

## 🛠️ Kustomisasi

- **Logo / favicon**: ganti file `logo.png` di folder yang sama dengan `index.html`.
- **Warna**: ubah variabel CSS di bagian `:root` (`--mrt-blue`, `--mrt-green`, dst.).
- **Kategori baru**: tambahkan key ke `KATEGORI_KODE` di JS **dan** ke `check` constraint pada tabel `requests` di SQL.
- **Tambah master data lain**: ikuti pola `lokasi_options` / `tujuan_options` di SQL dan fungsi `db.*` di JS.

---

## 🧯 Troubleshooting

### "Failed to fetch" / "Tidak dapat terhubung ke Supabase"
Muncul saat login atau saat memuat dashboard admin. Penyebab paling umum:

1. **URL atau ANON_KEY salah** — cek kembali nilai di `index.html`.
2. **Skrip `database.sql` belum dijalankan** — fungsi `fn_login` belum ada, sehingga login default gagal. Jalankan ulang `database.sql` di Supabase SQL Editor.
3. **Project Supabase paused** — login ke dashboard Supabase dan resume.
4. **Browser memblokir request** — periksa di DevTools tab Network/Console untuk detail.

### Login berhasil tetapi data tidak muncul
Pastikan RLS policy sudah aktif (skrip `database.sql` mengaturnya). Cek di Supabase **Authentication → Policies** bahwa tabel `requests`, `ratings`, `app_users`, `lokasi_options`, `tujuan_options` memiliki policy `for all using (true)`.

### Logo tidak muncul
- Pastikan file bernama persis `logo.png` (lowercase) di folder yang sama dengan `index.html`.
- Jika di-host di GitHub Pages, path relatif `logo.png` akan resolve otomatis terhadap URL `index.html`.

---

## 🧪 Mode Demo

Jika `SUPABASE_URL` masih bernilai placeholder, aplikasi otomatis:
- Memuat 6 permintaan sampel dari memori.
- Mensimulasikan semua CRUD tanpa persistensi.
- Menampilkan toast peringatan kuning di awal.

Mode ini berguna untuk *walkthrough* UI ke stakeholder sebelum infrastruktur Supabase tersedia.

---

## 📚 Stack

- **Frontend**: Vanilla HTML/CSS/JS (single file, tanpa build step).
- **Charts**: [Chart.js 4](https://www.chartjs.org/).
- **Backend**: [Supabase](https://supabase.com) — PostgreSQL + PostgREST + Storage.
- **Fonts**: Plus Jakarta Sans, Material Symbols Rounded (Google Fonts).

---

## 📄 Lisensi

Internal use — PT MRT Jakarta · Departemen General Affairs.

---

*Dibangun dengan ❤️ untuk efisiensi layanan GA.*
