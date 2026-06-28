// NetTrack Pro V14.1 service worker - development safe/no stale cache
const CACHE_NAME='nettrack-pro-v14-1-'+Date.now();
self.addEventListener('install',event=>{self.skipWaiting();});
self.addEventListener('activate',event=>{event.waitUntil(caches.keys().then(keys=>Promise.all(keys.map(k=>caches.delete(k)))).then(()=>self.clients.claim()));});
self.addEventListener('fetch',event=>{event.respondWith(fetch(event.request).catch(()=>caches.match(event.request)));});
