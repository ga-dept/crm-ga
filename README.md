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
- **Dashboard** statistik & chart per kategori + **SLA metrics** (rata-rata resolusi, on-time count, terlambat count, SLA compliance %) + chart SLA per kategori + tabel ringkas permintaan terbaru.
- **Tiket Saya** — halaman pribadi setiap personil GA yang menampilkan tiket pending miliknya, dipisah menjadi 4 tabel berdasarkan status (`Belum Dikonfirmasi`, `Mencari Penyedia`, `Sedang Disiapkan`, `Tersedia`). Superadmin/admin punya toggle **Tampilan Tim** untuk melihat tiket pending semua personil dikelompokkan per PIC.
- **Daftar Permintaan** dengan:
  - Pagination (10 baris per halaman) + sort per kolom.
  - **Filter per kolom**: Kategori, Status, Sumber, PIC, **SLA** (On-time / Terlambat / Belum Selesai).
  - Search bebas (kode/nama/detail).
  - **Kolom SLA** dengan badge `On-time`/`Terlambat` + waktu resolusi / selisih dari target.
  - CRUD lengkap melalui modal — update status, keterangan (wajib), total anggaran (delimiter Rupiah), vendor, **PIC GA (dropdown dari daftar user)**, estimasi penyelesaian.
  - **Upload bukti penyelesaian** (opsional) saat status = "Selesai" — 2 kolom terpisah: bukti foto & bukti tanda terima (JPG/PNG/PDF maks 5 MB). Confirm dialog mengingatkan bila Selesai tanpa bukti.
  - Tombol **rantai** untuk menyalin tautan penilaian (muncul saat status = "Selesai").
  - Tombol **PDF tanda terima** (muncul saat status = "Tersedia") — download PDF resmi berisi logo MRT, detail tiket, QR Code link penilaian, dan 2 kolom tanda tangan (Diserahkan oleh GA Department / Diterima oleh Nama Pemesan).
  - **Mass Upload CSV** — modal stepper 3 langkah (Upload → Periksa & Preview → Submit) lengkap dengan tombol download template dan tutorial in-place.
  - Ekspor **CSV** termasuk kolom SLA (target jam, resolusi jam, status SLA, URL bukti foto, URL bukti tanda terima).
- **Daftar Penilaian** — seluruh permintaan selesai dengan kolom *Sudah/Belum Dinilai*, tombol info untuk popup detail, ekspor CSV.
- **Master Data** — 3 card terpisah: **Lokasi Kebutuhan** (lokasi pengantaran), **Lokasi Kerja Personil** (kantor/depo personil GA), **Tujuan Kebutuhan**. CRUD penuh untuk masing-masing.
- **Manajemen User** — CRUD user dengan kolom **Username, Nama Lengkap, Jabatan, Lokasi Kerja, Role** (`superadmin` / `admin` / `pic`), status aktif/nonaktif, dan ubah password. Field Lokasi Kerja kini adalah dropdown dari master *Lokasi Kerja Personil*.
- **SLA Target** 🔒 **(khusus superadmin)** — modul untuk menentukan target resolusi (dalam jam) untuk masing-masing dari 6 kategori. Setiap perubahan tercatat di Log Aktivitas. Nilai ini yang menentukan status On-time/Terlambat di seluruh sistem. Menu ini disembunyikan untuk admin dan PIC.
- **Override Tanggal Selesai** 🔒 **(khusus superadmin)** — di modal edit permintaan yang sudah Selesai, superadmin bisa mengubah timestamp `completed_at` (mis. bila status di-update terlambat karena PIC libur). Wajib mengisi alasan; perubahan tercatat di Log Aktivitas.
- **Log Aktivitas** — audit trail seluruh aktivitas pengguna: login/logout, CRUD permintaan & user & master data, status change, download PDF, copy link penilaian, **SLA target update**, **override completed_at**. Bisa difilter per user, per jenis aktivitas, dan per rentang tanggal. Export CSV.
- **Riwayat Versi** changelog yang sama dengan halaman publik.
- **Notifikasi lonceng** di header — badge angka untuk unread, dropdown daftar notifikasi, polling 30 detik, tombol "Tandai Sudah Dibaca". Notifikasi otomatis dibuat ketika PIC diubah/ditugaskan ke permintaan baru.
- **Sidebar dengan hamburger** — collapse di desktop, slide-in overlay di mobile.
- **Persistent session** — login tetap berlaku saat berpindah antara landing dan admin, tidak akan auto-logout. Tombol logout muncul di kedua halaman.

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

| Username | Password   | Role         | Jabatan                | Lokasi Kerja          |
| -------- | ---------- | ------------ | ---------------------- | --------------------- |
| `admin`  | `admin123` | superadmin   | Head of General Affairs| Wisma Nusantara       |
| `ga.budi`| `budi123`  | admin        | GA Coordinator         | Wisma Nusantara       |
| `ga.siti`| `siti123`  | pic          | GA Officer             | Depo Lebak Bulus      |
| `ga.rian`| `rian123`  | pic          | GA Officer             | Transport Hub         |
| `ga.dewi`| `dewi123`  | pic          | GA Officer             | JB Tower              |

> **Ganti segera setelah login pertama** dari halaman *Manajemen User*.

---

## 🗃️ Skema Database (ringkas)

| Tabel                  | Fungsi                                                            |
| ---------------------- | ----------------------------------------------------------------- |
| `requests`             | Tabel utama permintaan (kode unik, kategori, status, `pic_user_id`)|
| `ratings`              | 1 penilaian per permintaan (1–5 bintang + kritik/saran)           |
| `notifications`        | Inbox notifikasi per user (dibuat otomatis oleh trigger SQL)      |
| `activity_logs`        | Audit trail aktivitas user (login/CRUD/status change/download PDF)|
| `app_users`            | Akun admin/staff (password bcrypt, + `jabatan` & `lokasi_kerja`)  |
| `lokasi_options`       | Master lokasi kebutuhan (dropdown formulir publik)                |
| `lokasi_kerja_options` | Master lokasi kerja personil GA (dropdown Manajemen User)         |
| `tujuan_options`       | Master tujuan kebutuhan (dropdown)                                |
| `counters`             | Counter harian untuk nomor urut kode permintaan                   |
| `version_history`      | Changelog                                                         |

### Fungsi RPC yang dipakai aplikasi

- `fn_generate_request_code(prefix)` — atomic generator kode `PREFIX-DDMMYYYY####`.
- `fn_login(username, password)` — login dengan verifikasi bcrypt; mengembalikan `id, username, full_name, role, jabatan, lokasi_kerja`.
- `fn_create_user(username, password, full_name, role, jabatan, lokasi_kerja)` — buat user dengan password bcrypt-hash.
- `fn_set_password(user_id, password)` — ubah password (bcrypt).

### Trigger

- `trg_notify_pic` — saat `pic_user_id` di-set/diubah pada `requests`, otomatis membuat row baru di `notifications` untuk user yang ditugaskan.

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

## 📄 Tanda Terima PDF

Setiap permintaan yang sudah berstatus **"Tersedia"** otomatis menampilkan ikon PDF hijau (📄) di kolom Aksi pada Daftar Permintaan. Klik untuk mengunduh dokumen PDF resmi (A4) berisi:

- **Header**: logo MRT (file `logo.png` di folder yang sama dengan `index.html`), judul "TANDA TERIMA PERMINTAAN", kode permintaan dalam pill biru.
- **Tabel detail**: 16 baris lengkap (kode, kategori, sumber, pemesan, kegiatan, lokasi, tujuan, tanggal, detail, estimasi harga, total anggaran, vendor, PIC GA, estimasi selesai, status).
- **Keterangan** (kiri) dan **QR Code penilaian** (kanan bawah) — QR mengarah ke tautan `#/rate/<id>` untuk diisi pemesan (skala bintang 1–5 + kolom kritik/saran + Submit).
- **2 kolom tanda tangan** di bawah:
  - **Diserahkan oleh**: General Affairs Department · PT MRT Jakarta · (di atas baris tanda tangan: nama PIC GA jika sudah di-assign).
  - **Diterima oleh**: Nama Pemesan (otomatis terisi dari data permintaan).
  - Garis tanda tangan dengan placeholder *(Nama lengkap & tanda tangan)*.
- **Footer**: tanggal cetak + versi portal.

> Jika `logo.png` tidak ditemukan, header otomatis menampilkan placeholder bertulis "GA" dengan warna biru MRT.

---

## 📋 Log Aktivitas

Halaman **Log Aktivitas** di sidebar mencatat seluruh tindakan yang terjadi di portal:

| Action key                  | Dipicu saat                                  |
| --------------------------- | -------------------------------------------- |
| `auth.login` / `auth.logout`| Login dan logout admin                       |
| `request.create.public`     | Pemesan submit form publik                   |
| `request.update`            | Admin edit detail (selain status)            |
| `request.status_change`     | Admin ubah status                            |
| `request.delete`            | Admin hapus permintaan                       |
| `request.pdf_download`      | Admin download tanda terima PDF              |
| `request.link_copy`         | Admin salin tautan penilaian                 |
| `user.create` / `user.update` / `user.delete` | CRUD user di Manajemen User |
| `masterdata.create` / `masterdata.delete` | CRUD master Lokasi/Lokasi Kerja/Tujuan |

Halaman ini mendukung **filter** per user, per jenis aktivitas, rentang tanggal (dari–sampai), dan search bebas di kolom detail. Tersedia juga **export CSV**.

---

## 📤 Mass Upload Permintaan (CSV)

Dari halaman **Daftar Permintaan**, klik tombol **Mass Upload** di kanan atas untuk membuka modal 3 langkah:

1. **Upload** — drag-and-drop atau pilih file `.csv`. Tombol *Download Template* tersedia di dalam modal.
2. **Periksa & Preview** — sistem memvalidasi setiap baris. Baris invalid ditandai merah dengan keterangan errornya (tetap ditampilkan tapi diabaikan saat submit).
3. **Submit** — baris valid disimpan satu per satu; setiap permintaan dapat kode otomatis sesuai kategorinya.

### Format kolom CSV

Header harus persis seperti berikut (case-sensitive, pemisah koma, encoding UTF-8):

| Kolom                   | Wajib | Format / Nilai yang valid                                  |
| ----------------------- | ----- | ---------------------------------------------------------- |
| `Kategori`              | ✅    | Salah satu: `Food and Beverage`, `Direct Purchase`, `Fasilitas Kantor dan Identitas Karyawan`, `Seragam`, `Office Supply`, `Event Support` |
| `Kode SmartOffice`      | —     | Bebas (untuk kategori FB/DP/OS/EV)                         |
| `Sumber Pemesanan`      | ✅    | `WhatsApp` / `SmartOffice` / `Walk-in` / `Email`           |
| `Nama Pemesan`          | ✅    | Teks                                                       |
| `Nama Kegiatan`         | —     | Teks                                                       |
| `Lokasi Kebutuhan`      | —     | Teks (sebaiknya sesuai master Lokasi)                      |
| `Tujuan Kebutuhan`      | —     | Teks (sebaiknya sesuai master Tujuan)                      |
| `Tanggal Kebutuhan`     | ✅    | `YYYY-MM-DD` (mis. `2026-05-20`)                           |
| `Detail Kebutuhan`      | ✅    | Teks                                                       |
| `Estimasi Harga`        | —     | Angka tanpa pemisah ribuan (mis. `1500000`)                |

**Batas:** maksimal **500 baris** per file, ukuran maksimal **2 MB**.

> Kode permintaan dibuat **otomatis** oleh sistem berdasarkan kategori — jangan diisi di CSV.

---

## 🔔 Notifikasi

- Setiap kali admin men-set/mengubah PIC pada permintaan (lewat modal edit), trigger SQL `trg_notify_pic` otomatis membuat notifikasi baru untuk user PIC tersebut.
- Lonceng di header admin akan menampilkan **badge angka merah** untuk jumlah notifikasi belum dibaca, dengan animasi pulse.
- Klik lonceng untuk membuka dropdown. Klik item notifikasi untuk membuka detail permintaan.
- Klik **Tandai Sudah Dibaca** untuk menandai semua notifikasi user saat ini sebagai sudah dibaca — badge akan hilang.
- Polling otomatis setiap **30 detik** sehingga notifikasi baru muncul tanpa perlu refresh.

---

## 🧾 Halaman "Tiket Saya"

Setiap personil GA punya halaman pribadi yang dipisah menjadi 4 tabel berdasarkan status:

- **Belum Dikonfirmasi**
- **Mencari Penyedia**
- **Sedang Disiapkan**
- **Tersedia**

Hanya menampilkan tiket di mana `pic_user_id` = user yang sedang login. Tombol aksi di setiap baris membuka detail atau modal edit langsung dari halaman ini.

**Superadmin & admin** mendapat toggle **Tampilan Tim** untuk melihat tiket pending **semua personil** dikelompokkan per PIC (termasuk bucket "Belum Ditugaskan" untuk tiket tanpa PIC).

---

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
- **PDF**: [jsPDF 2.5](https://github.com/parallax/jsPDF) + [jspdf-autotable 3.8](https://github.com/simonbengtsson/jsPDF-AutoTable).
- **QR Code**: [qrcodejs](https://github.com/davidshimjs/qrcodejs).
- **Backend**: [Supabase](https://supabase.com) — PostgreSQL + PostgREST + Storage.
- **Fonts**: Plus Jakarta Sans, Material Symbols Rounded (Google Fonts).

---

## 📄 Lisensi

Internal use — PT MRT Jakarta · Departemen General Affairs.

---

*Dibangun dengan ❤️ untuk efisiensi layanan GA.*
