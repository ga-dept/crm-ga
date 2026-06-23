-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.lokasi_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT lokasi_options_pkey PRIMARY KEY (id)
);
CREATE TABLE public.tujuan_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tujuan_options_pkey PRIMARY KEY (id)
);
CREATE TABLE public.app_users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  username text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'admin'::text CHECK (role = ANY (ARRAY['superadmin'::text, 'admin'::text, 'pic'::text, 'admin_payment'::text])),
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  jabatan text,
  lokasi_kerja text,
  allowed_pages jsonb,
  CONSTRAINT app_users_pkey PRIMARY KEY (id)
);
CREATE TABLE public.counters (
  day_key text NOT NULL,
  last_seq integer NOT NULL DEFAULT 0,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT counters_pkey PRIMARY KEY (day_key)
);
CREATE TABLE public.requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  kode_permintaan text NOT NULL UNIQUE,
  kode_smartoffice text,
  kategori text NOT NULL,
  kategori_kode text NOT NULL,
  sumber_pemesanan text NOT NULL,
  nama_pemesan text NOT NULL,
  nama_kegiatan text,
  lokasi_kebutuhan text,
  tujuan_kebutuhan text,
  tanggal_kebutuhan date NOT NULL,
  detail_kebutuhan text NOT NULL,
  estimasi_harga bigint DEFAULT 0,
  lampiran_url text,
  status text NOT NULL DEFAULT 'Belum Dikonfirmasi'::text CHECK (status = ANY (ARRAY['Belum Dikonfirmasi'::text, 'Mencari Penyedia'::text, 'Sedang Disiapkan'::text, 'Tersedia'::text, 'Selesai'::text, 'Ditolak'::text])),
  keterangan text,
  total_anggaran bigint DEFAULT 0,
  nama_vendor text,
  nama_pic_ga text,
  estimasi_penyelesaian date,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  pic_user_id uuid,
  bukti_foto_url text,
  bukti_tt_url text,
  completed_at timestamp with time zone,
  completed_at_edited_by uuid,
  completed_at_edited_at timestamp with time zone,
  completed_at_edit_reason text,
  divisi text,
  departemen text,
  mata_anggaran text,
  pakai_anggaran_ga boolean NOT NULL DEFAULT true,
  kendaraan_detail jsonb,
  CONSTRAINT requests_pkey PRIMARY KEY (id),
  CONSTRAINT requests_completed_at_edited_by_fkey FOREIGN KEY (completed_at_edited_by) REFERENCES public.app_users(id),
  CONSTRAINT requests_pic_user_id_fkey FOREIGN KEY (pic_user_id) REFERENCES public.app_users(id)
);
CREATE TABLE public.ratings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL UNIQUE,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  kritik_saran text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ratings_pkey PRIMARY KEY (id),
  CONSTRAINT ratings_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id)
);
CREATE TABLE public.version_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  version text NOT NULL,
  release_date date NOT NULL,
  changes text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT version_history_pkey PRIMARY KEY (id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  request_id uuid,
  type text NOT NULL,
  title text NOT NULL,
  body text,
  read_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_users(id),
  CONSTRAINT notifications_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id)
);
CREATE TABLE public.lokasi_kerja_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT lokasi_kerja_options_pkey PRIMARY KEY (id)
);
CREATE TABLE public.activity_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  username text,
  full_name text,
  action text NOT NULL,
  target_type text,
  target_id text,
  detail text,
  meta jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT activity_logs_pkey PRIMARY KEY (id),
  CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_users(id)
);
CREATE TABLE public.sla_targets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  kategori text NOT NULL UNIQUE,
  kategori_kode text NOT NULL,
  target_hours integer NOT NULL DEFAULT 24,
  description text,
  updated_at timestamp with time zone DEFAULT now(),
  updated_by uuid,
  CONSTRAINT sla_targets_pkey PRIMARY KEY (id),
  CONSTRAINT sla_targets_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.app_users(id)
);
CREATE TABLE public.mata_anggaran_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  kode text,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT mata_anggaran_options_pkey PRIMARY KEY (id)
);
CREATE TABLE public.divisi_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT divisi_options_pkey PRIMARY KEY (id)
);
CREATE TABLE public.departemen_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  divisi_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  kepala_departemen_user_id uuid,
  CONSTRAINT departemen_options_pkey PRIMARY KEY (id),
  CONSTRAINT departemen_options_divisi_id_fkey FOREIGN KEY (divisi_id) REFERENCES public.divisi_options(id),
  CONSTRAINT departemen_options_kepala_departemen_user_id_fkey FOREIGN KEY (kepala_departemen_user_id) REFERENCES public.app_users(id)
);
CREATE TABLE public.kategori_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  kode text NOT NULL UNIQUE,
  default_sla_hours integer NOT NULL DEFAULT 24,
  active boolean NOT NULL DEFAULT true,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT kategori_options_pkey PRIMARY KEY (id),
  CONSTRAINT kategori_options_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_users(id)
);
CREATE TABLE public.approvals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL,
  approval_type text NOT NULL,
  requested_by uuid NOT NULL,
  requested_at timestamp with time zone NOT NULL DEFAULT now(),
  approver_user_id uuid,
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'cancelled'::text])),
  decided_at timestamp with time zone,
  decided_by uuid,
  reason text,
  meta jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT approvals_pkey PRIMARY KEY (id),
  CONSTRAINT approvals_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id),
  CONSTRAINT approvals_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.app_users(id),
  CONSTRAINT approvals_approver_user_id_fkey FOREIGN KEY (approver_user_id) REFERENCES public.app_users(id),
  CONSTRAINT approvals_decided_by_fkey FOREIGN KEY (decided_by) REFERENCES public.app_users(id)
);
CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL UNIQUE,
  fund_owner text,
  vendor_name text,
  pic_user_name text,
  tanggal_permintaan date,
  tanggal_kebutuhan date,
  location text,
  sub_location text,
  directorate text,
  division text,
  department text,
  category text,
  sub_category text,
  administrator text,
  user_sap text,
  proforma_number text,
  proforma_date date,
  pr_number text,
  pr_date date,
  po_number text,
  po_date date,
  gr_number text,
  gr_date date,
  invoice_number text,
  invoice_date date,
  submit_date date,
  cost_type text,
  cost_purpose text,
  jenis_pembayaran text,
  quantity numeric,
  price bigint,
  grand_total bigint,
  status text NOT NULL DEFAULT 'Belum Diproses'::text CHECK (status = ANY (ARRAY['Belum Diproses'::text, 'Diproses'::text, 'Menunggu Pembayaran'::text, 'Lunas'::text, 'Dibatalkan'::text])),
  note text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  activity_name text,
  fund text,
  description_fund text,
  ga_payment_status text NOT NULL DEFAULT 'Not Complete Yet'::text CHECK (ga_payment_status = ANY (ARRAY['Not Complete Yet'::text, 'Submitted'::text, 'Verified'::text, 'Revision'::text, 'Paid'::text])),
  fund_id uuid,
  mata_anggaran text,
  subsidi text,
  non_ga_status text,
  non_ga_note text,
  non_ga_last_changed_at timestamp with time zone,
  non_ga_last_changed_by text,
  CONSTRAINT payments_pkey PRIMARY KEY (id),
  CONSTRAINT payments_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.requests(id),
  CONSTRAINT payments_fund_fk FOREIGN KEY (fund_id) REFERENCES public.anggaran_funds(id)
);
CREATE TABLE public.kendaraan_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nama_driver text NOT NULL,
  no_hp text,
  nomor_polisi text,
  posisi text,
  ownership text,
  ev_status text,
  ga_ge text,
  keterangan text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT kendaraan_options_pkey PRIMARY KEY (id)
);
CREATE TABLE public.anggaran_funds (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  keterangan text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT anggaran_funds_pkey PRIMARY KEY (id)
);
CREATE TABLE public.anggaran_topups (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  fund_id uuid,
  nominal bigint NOT NULL DEFAULT 0,
  tanggal date NOT NULL DEFAULT CURRENT_DATE,
  sumber text,
  keterangan text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT anggaran_topups_pkey PRIMARY KEY (id)
);
CREATE TABLE public.cdp_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  fund_id uuid,
  tahun integer NOT NULL,
  bulan integer NOT NULL CHECK (bulan >= 1 AND bulan <= 12),
  rencana bigint NOT NULL DEFAULT 0,
  keterangan text,
  CONSTRAINT cdp_plans_pkey PRIMARY KEY (id)
);
CREATE TABLE public.recurring_payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nama text NOT NULL,
  jenis text,
  vendor text,
  nominal numeric DEFAULT 0,
  pakai_anggaran_ga boolean DEFAULT true,
  mata_anggaran text,
  pic_user_id uuid,
  pic_user_name text,
  tanggal_jatuh_tempo date,
  ga_status text DEFAULT 'Not Complete Yet'::text,
  non_ga_status text DEFAULT 'On Progress'::text,
  keterangan text,
  last_changed_at timestamp with time zone,
  last_changed_by text,
  last_warned_threshold integer,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  proforma_number text,
  proforma_date date,
  pr_number text,
  pr_date date,
  po_number text,
  po_date date,
  gr_number text,
  gr_date date,
  invoice_number text,
  invoice_date date,
  description_fund text,
  CONSTRAINT recurring_payments_pkey PRIMARY KEY (id)
);
CREATE TABLE public.pc_reimburse (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tipe text NOT NULL,
  kode text,
  loket text,
  penerima text,
  tanggal date,
  kategori text,
  departemen text,
  kegiatan text,
  rekening text,
  no_polisi text,
  driver text,
  km_awal numeric,
  km_akhir numeric,
  nominal numeric DEFAULT 0,
  sumber text DEFAULT 'Fund GA'::text,
  mata_anggaran text,
  status text DEFAULT 'Input'::text,
  pic text,
  verif boolean DEFAULT false,
  tgl_verif date,
  trf_tgl date,
  cash_tgl date,
  no_spp text,
  detail jsonb,
  keterangan text,
  created_at timestamp with time zone DEFAULT now(),
  wf_stage text DEFAULT 'pic_loket'::text,
  wf_user text,
  wf_file_formulir text,
  wf_file_invoice text,
  wf_file_pendukung text,
  wf_pic_at timestamp with time zone,
  wf_pic_by text,
  wf_verif_status text,
  wf_verif_catatan text,
  wf_transfer_req_date date,
  wf_verif_at timestamp with time zone,
  wf_verif_by text,
  wf_konfirmasi boolean DEFAULT false,
  wf_kelengkapan boolean DEFAULT false,
  wf_sumber_biaya text,
  wf_nominal_disetujui bigint,
  wf_file_bukti_pk text,
  wf_pk_at timestamp with time zone,
  wf_pk_by text,
  wf_revisi_finance boolean DEFAULT false,
  wf_revisi_date date,
  wf_nominal_penyesuaian bigint,
  wf_no_spp_penyesuaian text,
  wf_spp_at timestamp with time zone,
  wf_spp_by text,
  wf_nominal_pengembalian bigint,
  wf_pengembalian_date date,
  wf_rek_asal text,
  wf_nama_pengembalian text,
  wf_sumber_kas_tujuan text,
  wf_final_status text,
  wf_return_at timestamp with time zone,
  wf_return_by text,
  wf_kadept_at timestamp with time zone,
  wf_kadept_by text,
  wf_kadept_decision text,
  wf_kadept_reason text,
  jenis_penggunaan text DEFAULT 'Reimbursement'::text,
  media_kas text,
  metode_pengeluaran text,
  pos text,
  tgl_nota date,
  outstanding boolean DEFAULT false,
  no_kuitansi text,
  kuitansi_url text,
  lap_perjalanan_url text,
  CONSTRAINT pc_reimburse_pkey PRIMARY KEY (id)
);
CREATE TABLE public.pc_master (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tipe text NOT NULL,
  no_sap text,
  no_trx text,
  wilayah text,
  tanggal date,
  deskripsi text,
  pengguna text,
  departemen text,
  divisi text,
  no_polisi text,
  sub_kategori text,
  kategori text,
  gl_account text,
  no_fund text,
  desc_fund text,
  no_formulir text,
  cost_center text,
  total_biaya numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  km_awal numeric,
  km_akhir numeric,
  CONSTRAINT pc_master_pkey PRIMARY KEY (id)
);
CREATE TABLE public.pc_dropdown (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  grup text NOT NULL,
  nilai text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pc_dropdown_pkey PRIMARY KEY (id)
);
CREATE TABLE public.pc_relasi (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  jenis_biaya text NOT NULL,
  gl_account text,
  no_fund text,
  cost_center text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pc_relasi_pkey PRIMARY KEY (id)
);
CREATE TABLE public.pc_cash (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tanggal date,
  tipe text,
  uraian text,
  nominal numeric DEFAULT 0,
  keterangan text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pc_cash_pkey PRIMARY KEY (id)
);
CREATE TABLE public.pc_log (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  waktu timestamp with time zone DEFAULT now(),
  user text,
  aksi text,
  detail text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pc_log_pkey PRIMARY KEY (id)
);
CREATE TABLE public.karyawan_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nama text NOT NULL,
  jabatan text,
  divisi_id uuid,
  departemen_id uuid,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT karyawan_options_pkey PRIMARY KEY (id),
  CONSTRAINT karyawan_options_divisi_id_fkey FOREIGN KEY (divisi_id) REFERENCES public.divisi_options(id),
  CONSTRAINT karyawan_options_departemen_id_fkey FOREIGN KEY (departemen_id) REFERENCES public.departemen_options(id)
);
CREATE TABLE public.karyawan_import (
  nama text,
  jabatan text,
  divisi text,
  departemen text,
  active boolean DEFAULT true
);
CREATE TABLE public.pc_sla_targets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  stage text NOT NULL UNIQUE,
  label text,
  sla_hours integer NOT NULL DEFAULT 24,
  updated_at timestamp with time zone DEFAULT now(),
  updated_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pc_sla_targets_pkey PRIMARY KEY (id)
);
CREATE TABLE public.vendor_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nama_perusahaan text NOT NULL,
  nama_pic text,
  alamat text,
  no_hp text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vendor_options_pkey PRIMARY KEY (id)
);