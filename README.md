# GASS CRM — GA Hotline Portal

Portal internal **General Affairs PT MRT Jakarta (Perseroda)** untuk permintaan operasional, pelacakan status, pembayaran, pembayaran rutin, dan petty cash — dalam satu aplikasi web (PWA).

> **Versi aplikasi:** 2.5.0
> **Stack:** HTML/CSS/JS murni (vanilla, satu file) · Supabase (PostgreSQL + Auth/anon) · Chart.js · PWA (Service Worker) · deploy di Vercel.

---

## Daftar Isi
1. [Arsitektur singkat](#arsitektur-singkat)
2. [Struktur berkas](#struktur-berkas)
3. [Cara menjalankan & deploy](#cara-menjalankan--deploy)
4. [Konfigurasi Supabase](#konfigurasi-supabase)
5. [Skema basis data](#skema-basis-data)
6. [Peran (role) & hak akses](#peran-role--hak-akses)
7. [Daftar modul](#daftar-modul)
8. [PWA & cache (penting saat deploy)](#pwa--cache-penting-saat-deploy)
9. [Mode demo](#mode-demo)
10. [Catatan pengembangan](#catatan-pengembangan)

---

## Arsitektur singkat

Aplikasi adalah **Single Page Application satu berkas** (`index.html`) tanpa framework/bundler:

- **Routing** berbasis hash: `#/admin/<halaman>` (mis. `#/admin/payments`). Dispatcher di `renderAdmin()` memanggil fungsi `viewAdmin*` per halaman.
- **Data layer** terpusat pada objek `db` (dan `pcdb` untuk Petty Cash). Setiap method punya **dua jalur**: Supabase bila dikonfigurasi, atau **data demo in-memory** bila tidak (lihat [Mode demo](#mode-demo)).
- **Akses** digate per-role lewat `ROUTE_ROLES` + atribut `data-allowed-roles` pada menu, ditambah override **Hak Akses Halaman** per akun (`allowed_pages`).
- **PWA**: `sw.js` (service worker) + `manifest.json` membuat portal dapat di-*install* dan bekerja offline untuk app shell.
- **Halaman publik** `cektiket.html`: pelacakan status permintaan tanpa login (kode permintaan / SmartOffice).

---

## Struktur berkas

| Berkas | Fungsi |
|---|---|
| `index.html` | Aplikasi utama (seluruh modul, UI, dan logika ada di sini) |
| `cektiket.html` | Halaman publik cek status tiket/permintaan |
| `sw.js` | Service Worker PWA (cache app shell, offline fallback) |
| `manifest.json` | Manifest PWA (nama, ikon, shortcut) |
| `vercel.json` | Konfigurasi Vercel (`cleanUrls`, `trailingSlash`) |
| `supabase-semua-modul.sql` | Skema SQL untuk seluruh modul (jalankan di Supabase) |
| `logo.png`, `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `apple-touch-icon.png` | Aset ikon/branding |
| `footer-preview.html` | *(opsional, util pengembangan)* pratinjau desain footer |

---

## Cara menjalankan & deploy

### Lokal
Karena ini berkas statis, cukup sajikan lewat server statis apa pun:

```bash
# contoh
npx serve .
# atau
python3 -m http.server 8080
```

Buka `http://localhost:8080/index.html`. (Membuka via `file://` tidak disarankan karena Service Worker & beberapa API butuh origin http/https.)

### Deploy (Vercel)
1. Hubungkan repository ke Vercel (atau `vercel deploy`).
2. Tidak ada build step — semua berkas statis.
3. `vercel.json` sudah mengaktifkan `cleanUrls`.
4. **Naikkan `CACHE_VERSION` di `sw.js` setiap deploy** (lihat [PWA & cache](#pwa--cache-penting-saat-deploy)).

---

## Konfigurasi Supabase

Kredensial dibaca di `index.html` (dan `cektiket.html`) dengan urutan: variabel global `window.__SUPA_URL__` / `window.__SUPA_KEY__` bila ada, atau nilai default di kode:

```js
const SUPABASE_URL      = window.__SUPA_URL__ || 'https://<project-ref>.supabase.co';
const SUPABASE_ANON_KEY = window.__SUPA_KEY__ || '<anon-key>';
const SUPA_CONFIGURED   = !SUPABASE_URL.includes('YOUR-PROJECT-REF');
```

- Gunakan **anon key** (bukan service key) — aman dipakai di sisi klien bila **RLS** diaktifkan.
- Bila `SUPA_CONFIGURED` bernilai `false` (URL masih placeholder), aplikasi otomatis berjalan dalam **mode demo**.
- Untuk mengganti tanpa menyentuh kode, set `window.__SUPA_URL__`/`window.__SUPA_KEY__` sebelum skrip aplikasi dimuat.

> **Keamanan:** jangan menaruh service key di berkas klien. Atur Row Level Security (RLS) di Supabase sesuai kebijakan peran (lihat catatan pada SQL).

---

## Skema basis data

Jalankan **`supabase-semua-modul.sql`** di **Supabase → SQL Editor** (idempotent, aman dijalankan berulang). Skrip mencakup:

- **Payment Non-GA** — kolom tambahan pada tabel `payments`: `non_ga_status`, `non_ga_note`, `non_ga_last_changed_at`, `non_ga_last_changed_by`.
- **Pembayaran Rutin** — tabel `recurring_payments`.
- **Petty Cash** — tabel `pc_reimburse`, `pc_master`, `pc_dropdown`, `pc_relasi`, `pc_cash`, `pc_log`.
- **Master Karyawan** — tabel `karyawan_options` (referensi ke `divisi_options` & `departemen_options`).

Tabel inti lain (`requests`, `payments`, `ratings`, `notifications`, `activity_logs`, master `lokasi_options`, `tujuan_options`, `mata_anggaran_options`, `divisi_options`, `departemen_options`, `kategori_options`, `kendaraan_options`, `users`, dll.) diasumsikan sudah ada dari versi sebelumnya.

> Sesuaikan/aktifkan **RLS** untuk tiap tabel sesuai peran. Contoh aturan ada sebagai komentar di dalam berkas SQL.

---

## Peran (role) & hak akses

Empat peran utama:

| Role | Ringkasan |
|---|---|
| `superadmin` | Akses penuh ke semua halaman & pengaturan |
| `admin` | Operasional GA + master data |
| `pic` | PIC/petugas GA (input & proses permintaan) |
| `admin_payment` | Pemrosesan pembayaran (Payment, Payment Non-GA, Pembayaran Rutin) |

Akses halaman ditentukan oleh `ROUTE_ROLES` (default per role) **dan** dapat di-override per akun melalui menu **Hak Akses Halaman** (`allowed_pages`). Catatan khusus:

- **Petty Cash** dapat **dibuka semua user**; namun **izin CRUD** ditentukan via Hak Akses Halaman (berikan halaman `petty` ke akun yang boleh menambah/ubah/hapus).
- Mengubah **status pembayaran** (GA penuh maupun Non-GA sederhana) hanya untuk `admin_payment` & `superadmin`.

---

## Daftar modul

**Operasional**
- **Dashboard** — ringkasan & statistik.
- **Daftar Permintaan (Requests)** — pengajuan kebutuhan operasional GA, beserta alur status.
- **Penilaian (Ratings)** — penilaian layanan oleh pemesan.

**Keuangan**
- **Payment** — pembayaran untuk permintaan **Menggunakan Anggaran GA** (alur Report Payment: Identifikasi → Proforma/PR → PO/GR → Invoice/Fund; status: Not Complete Yet → Submitted → Verified → Revision → Paid).
- **Payment Non-GA** — halaman terpisah untuk permintaan **Bukan Anggaran GA**; status sederhana **On Progress / Paid / Revision** + keterangan + jejak "Terakhir diubah" (popup). *Tidak* dihitung pada realisasi Anggaran GA.
- **Pembayaran Rutin** — tagihan berkala (pulsa, telepon, internet, listrik, sewa, dll) di luar formulir permintaan. Diajukan PIC, diproses Admin Payment. Punya **tanggal jatuh tempo** dan **pengingat otomatis** (pop-up yang bisa ditutup **+ lonceng**) pada **H-14, H-7, lalu setiap hari H-6 hingga jatuh tempo**, dengan notifikasi ke PIC & Admin Payment. Status mengikuti alur GA penuh (bila GA) atau sederhana (bila Non-GA). Nominal GA menambah realisasi anggaran namun dilaporkan terpisah ("Pembayaran Rutin").
- **Petty Cash** — satu menu dengan sub-modul sebagai **tab**:
  - *Dashboard* (statistik kas kecil)
  - *Reimbursement* (Kerumahtanggaan/KRT & Kendaraan/KND) dengan workflow **Input → Diverifikasi → Permintaan Transfer → Ditransfer → SPP Terbit → Selesai** (+ Revisi)
  - *Form Input* (KRT/KND, dengan autofill relasi akun)
  - *Master Data* (KRT/KND)
  - *SPP* — Surat Permintaan Pembayaran, dokumen **A4 portrait** + **Print/Export PDF** berformat sesuai aslinya
  - *Report* — realisasi per kategori & lokasi + ekspor
  - *Kelola Dropdown* + *Tabel Relasi Akun* (GL/Fund/Cost Center)
  - *Posisi Kas* — jurnal kas kecil, saldo berjalan, **pencocokan saldo brankas**
  - *Log History*
  - Lokasi: **Wisma Nusantara, Transport Hub, Depo Lebak Bulus**. Nominal **Fund GA** menambah realisasi anggaran (dilaporkan terpisah sebagai "Petty Cash").
- **Manajemen Anggaran** — Fund = Mata Anggaran (satu sumber), realisasi dihitung dari Payment + Pembayaran Rutin GA + Petty Cash GA, dengan pelaporan kategori terpisah; top-up & CDP bulanan.

**Master Data**
- Lokasi, Tujuan, Anggaran · Kategori Pemesanan · Divisi · Departemen · **Master Karyawan** (nama + Jabatan + Divisi + Departemen) · Armada Kendaraan.

**Admin**
- Manajemen User · Hak Akses Halaman · SLA Target · Log Aktivitas · Riwayat Versi.

**Fitur lintas-modul**
- **Typesearch** — semua dropdown panjang (≥ 8 opsi) otomatis menjadi *combobox* yang bisa diketik untuk mencari. Tambahkan class `no-search` pada `<select>` untuk mengecualikan.
- **Footer publik** — kartu gelap dengan tautan Contact Us (email GA), GASSWay!, dan Marti.
- **Lonceng notifikasi** + **cek status publik** (`cektiket.html`).

---

## PWA & cache (penting saat deploy)

`sw.js` memakai strategi:
- **App shell** (`index.html`, `manifest.json`, logo/ikon, `cektiket.html`) → *cache-first* + pembaruan latar belakang.
- **Library CDN / font** → *stale-while-revalidate*.
- **Navigasi SPA** → *network-first*, fallback ke halaman ter-cache saat offline.
- **API Supabase & request non-GET** → *network only* (tidak pernah di-cache).

> **WAJIB:** setiap kali `index.html` diubah & di-deploy, **naikkan `CACHE_VERSION`** di `sw.js`
> (mis. `ga-hotline-v2.5.0` → `ga-hotline-v2.5.1`). Tanpa ini, perangkat yang sudah membuka
> portal akan tetap menyajikan `index.html` lama dari cache, sehingga perubahan tidak terlihat.

Saat `activate`, service worker otomatis menghapus cache versi lama dan mengambil alih (`clients.claim()`).

---

## Mode demo

Jika Supabase belum dikonfigurasi (`SUPA_CONFIGURED === false`), aplikasi berjalan penuh dengan **data demo in-memory** (seed di dalam `index.html`): contoh permintaan, pembayaran, tagihan rutin (termasuk yang sudah jatuh tempo agar pengingat langsung tampil), transaksi & master petty cash, serta master karyawan. Data demo **tidak persisten** (hilang saat refresh). Mode ini berguna untuk uji coba UI/alur tanpa backend.

Akun demo tersedia di array `users` (peran: superadmin, admin, beberapa pic). Untuk kredensial, lihat langsung pada kode; **jangan** memakai kredensial demo di produksi.

---

## Catatan pengembangan

- Semua tambahan modul diberi penanda komentar versi (`v2.2`–`v2.5`) di dalam `index.html` agar mudah ditelusuri.
- Modul Petty Cash bersifat **self-contained** (namespace `pc*` / `_pc*` + `pcdb`) agar mudah dirawat/diperbaiki terpisah.
- Penambahan halaman baru memerlukan: entri di `ROUTE_ROLES`, `PAGE_LABELS`, menu sidebar (`data-route`), peta judul di `renderAdmin`, dan satu cabang dispatcher `else if (page === '...')`.
- Riwayat perubahan lengkap tersedia di menu **Riwayat Versi** di dalam aplikasi.

---

© General Affairs · PT MRT Jakarta (Perseroda). Internal use.
