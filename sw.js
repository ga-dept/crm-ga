/* =====================================================================
   GA Hotline Portal — Service Worker (PWA) v1.8
   Strategy:
   • App shell (index.html, manifest, logo) → cache-first + background update
   • CDN libraries / fonts                  → stale-while-revalidate
   • Navigations (SPA)                       → network-first, fallback to cached index.html
   • Supabase API & all non-GET requests     → network only (never cached)
   Bump CACHE_VERSION on every deploy to invalidate old caches.
   ===================================================================== */
const CACHE_VERSION = 'ga-hotline-v3.0.0';
const APP_SHELL = [
  './',
  './index.html',
  './cektiket.html',
  './manifest.json',
  './logo.png',
  './icon-192.png',
  './icon-512.png',
  './icon-maskable-512.png',
  './apple-touch-icon.png'
];
// CDN assets the app loads — cached opportunistically (best-effort).
const CDN_PRECACHE = [
  'https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2',
  'https://cdn.jsdelivr.net/npm/jspdf@2.5.1/dist/jspdf.umd.min.js',
  'https://cdn.jsdelivr.net/npm/jspdf-autotable@3.8.2/dist/jspdf.plugin.autotable.min.js',
  'https://cdn.jsdelivr.net/gh/davidshimjs/qrcodejs/qrcode.min.js',
  'https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js',
  'https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js',
  'https://cdn.jsdelivr.net/npm/jszip@3.10.1/dist/jszip.min.js'
];

// ---------- INSTALL: precache app shell (+ best-effort CDN) ----------
self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_VERSION);
    // App shell is required; CDN is best-effort so one failure won't abort install.
    await cache.addAll(APP_SHELL).catch(err => console.warn('[sw] app shell precache partial', err));
    await Promise.allSettled(CDN_PRECACHE.map(url =>
      fetch(url, { mode: 'cors' }).then(res => { if (res.ok) return cache.put(url, res); }).catch(() => {})
    ));
    self.skipWaiting();
  })());
});

// ---------- ACTIVATE: drop old caches ----------
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(k => k !== CACHE_VERSION).map(k => caches.delete(k)));
    await self.clients.claim();
  })());
});

function isSupabase(url) {
  return url.hostname.includes('supabase.co') || url.hostname.includes('supabase.in');
}

// ---------- FETCH ----------
self.addEventListener('fetch', (event) => {
  const req = event.request;
  const url = new URL(req.url);

  // Only handle GET; never touch Supabase API (auth + dynamic data).
  if (req.method !== 'GET' || isSupabase(url)) return;

  // SPA navigations: network-first, fall back to the right cached page offline.
  if (req.mode === 'navigate') {
    event.respondWith((async () => {
      const isCek = /cektiket/i.test(url.pathname);
      const fallbackKey = isCek ? './cektiket.html' : './index.html';
      try {
        const fresh = await fetch(req);
        const cache = await caches.open(CACHE_VERSION);
        cache.put(fallbackKey, fresh.clone()).catch(() => {});
        return fresh;
      } catch (e) {
        const cache = await caches.open(CACHE_VERSION);
        return (await cache.match(fallbackKey)) || (await cache.match('./index.html')) || (await cache.match('./')) || Response.error();
      }
    })());
    return;
  }

  const sameOrigin = url.origin === self.location.origin;

  // Same-origin static (index.html, logo, manifest): cache-first + refresh.
  if (sameOrigin) {
    event.respondWith((async () => {
      const cache = await caches.open(CACHE_VERSION);
      const cached = await cache.match(req);
      const network = fetch(req).then(res => {
        if (res && res.ok) cache.put(req, res.clone()).catch(() => {});
        return res;
      }).catch(() => null);
      return cached || (await network) || Response.error();
    })());
    return;
  }

  // Cross-origin (CDN libs, fonts): stale-while-revalidate.
  event.respondWith((async () => {
    const cache = await caches.open(CACHE_VERSION);
    const cached = await cache.match(req);
    const network = fetch(req).then(res => {
      if (res && (res.ok || res.type === 'opaque')) cache.put(req, res.clone()).catch(() => {});
      return res;
    }).catch(() => null);
    return cached || (await network) || Response.error();
  })());
});

// Allow the page to trigger an immediate activation after an update.
self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') self.skipWaiting();
});
