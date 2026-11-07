// Service worker: fa funzionare l'app anche offline.
// Il codice dell'app viene preso dalla rete quando possibile (così gli aggiornamenti arrivano subito)
// e dalla copia salvata quando sei offline. Le foto e i font restano in cache.
const VERSION = "community-v1";
const MEDIA = "community-media";
const SHELL = [
  "./",
  "./index.html",
  "./config.js",
  "./manifest.webmanifest",
  "./vendor/supabase-2.117.3.js",
  "./icons/apple-touch-icon.png",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/favicon-32.png",
];

self.addEventListener("install", event => {
  event.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys()
      // le cache sono condivise con le altre app dello stesso dominio (es. la versione personale):
      // elimina solo le vecchie versioni di questa
      .then(keys => Promise.all(keys.filter(k => k.startsWith("community-") && k !== VERSION && k !== MEDIA).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

async function networkFirst(req){
  const cache = await caches.open(VERSION);
  try {
    const res = await fetch(req);
    if (res.ok) cache.put(req, res.clone());
    return res;
  } catch {
    return (await cache.match(req, {ignoreSearch: true})) || (await cache.match("./index.html")) || Response.error();
  }
}
async function cacheFirst(req, name){
  const cache = await caches.open(name);
  const hit = await cache.match(req);
  if (hit) return hit;
  const res = await fetch(req);
  if (res.ok || res.type === "opaque") cache.put(req, res.clone());
  return res;
}

self.addEventListener("fetch", event => {
  const req = event.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.origin === self.location.origin){
    const isCode = req.mode === "navigate" || /\/(index\.html|config\.js|sw\.js)?$/.test(url.pathname) || url.pathname.endsWith(".webmanifest");
    event.respondWith(isCode ? networkFirst(req) : cacheFirst(req, VERSION));
    return;
  }
  if (url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com"){
    event.respondWith(cacheFirst(req, MEDIA));
    return;
  }
  if (url.pathname.includes("/storage/v1/object/public/photos/")){
    event.respondWith(cacheFirst(req, MEDIA));
    return;
  }
  // tutto il resto (archivio Supabase) passa direttamente dalla rete
});
