// Finanzas del Reino — Service Worker
// Solo cachea el "cascarón" de la app (HTML/manifest/íconos) para que abra instalada sin conexión.
// Los datos financieros viven en Supabase y requieren conexión a internet para leerse o guardarse.

const CACHE_NAME = 'finanzas-del-reino-v1';
const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './icon-512-maskable.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Nunca cachear llamadas a Supabase (auth, datos, storage) — siempre deben ir a la red.
  if (url.hostname.endsWith('supabase.co')) return;

  // Para todo lo demás (el cascarón de la app): red primero, con respaldo en caché si no hay conexión.
  event.respondWith(
    fetch(event.request)
      .then((res) => {
        const resClone = res.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, resClone));
        return res;
      })
      .catch(() => caches.match(event.request))
  );
});
