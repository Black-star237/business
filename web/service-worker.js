self.addEventListener('install', (event) => {
  console.log('Service Worker installing.');
  // Force the waiting service worker to become the active service worker.
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('Service Worker activating.');
  // Claim clients immediately to ensure the new service worker is used.
  event.waitUntil(clients.claim());
});

self.addEventListener('fetch', (event) => {
  // You can add custom fetch handling here if needed.
});