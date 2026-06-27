NETTRACK NETWORK TRADING PLATFORM V13 - GITHUB PAGES PACKAGE

Upload these files to GitHub root:
- index.html                    Main platform UI, charts, signal tester, lock system
- sw.js                         Service worker for app caching
- manifest.webmanifest          Installable PWA manifest
- icon-192.png                  PWA icon
- icon-512.png                  PWA icon
- nettrack_signal_platform_schema.sql  Future database schema for users/subscriptions/signals
- README_DEPLOY.txt             Deployment guide
- README_SIGNAL_PLATFORM_FINAL.txt     Previous signal platform notes
- README_TESTER_V12_4.txt       Tester mode notes

V13 platform parts included:
1. Splash/branding: Armoroo E n T Software and Apps, creators Emmanuel Musiyiwa Ngobeni and Thando Mbatha.
2. Market switcher: crypto/forex style pair selector and timeframe selector.
3. Broker/sync selector: MetaTrader 4/5, IQ style tester, XM/Exness/Binance style UI labels.
4. Live-style chart engine: candle chart, simulated ticks for testing, moving averages, support/resistance.
5. Free signal tester: one open pattern generator only.
6. TP/SL panel: target, stop, risk/reward display.
7. Locked premium sections: scanner, backtest, journal, admin, subscriptions, account upgrades.
8. Subscription prompts: upgrade wording and owner commission tracking placeholders.
9. Removed deposit/bank collection UI: no bank details or deposit accounts shown.
10. GitHub Pages ready: index.html is in root.

Important:
- This package is frontend/static and demo/tester ready.
- Real broker trading requires official broker APIs, user permission, API keys, and a backend server.
- Do not promise guaranteed wins. Signals are estimations and tester outputs only.

GitHub Pages link format:
https://engobeni842-boop.github.io/nettrackpro/
