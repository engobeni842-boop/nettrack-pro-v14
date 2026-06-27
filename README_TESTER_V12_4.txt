NetTrack Tester V12.4 — Signal Platform Patch

Applied changes:
- Converted the build into a tester-focused signal platform.
- Removed user-facing deposit/bank-account sections from the user portal.
- Kept chart, broker/platform overlay view, entry/SL/TP levels and one free Signal Pattern Generator open.
- Locked advanced modules under subscription with faded cards and UNDER SUBSCRIPTION overlays.
- Added Basic / Pro / Premium subscription unlock logic for owner commission tracking.
- Kept signal-only compliance guard: no client deposits, no wallet trading, no auto-execution.
- Broker/platform selector remains available for tester alignment view: Binance, XM, MT4, MT5, IQ Option, Bybit, Deriv, ICMarkets, Exness.

Important testing note:
This static HTML build uses Binance live market data for crypto charts. MT4/MT5/XM/IQ Option/Exness direct live execution or account sync requires official broker APIs/bridges/webhooks in a later backend-connected release.
