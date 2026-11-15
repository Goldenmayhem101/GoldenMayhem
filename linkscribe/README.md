# Linkscribe

Paste a public YouTube link, get the full transcript, copy it. Powered by Google Gemini. Installable on a phone (Add to Home Screen).

## Files
- `server.js` - the whole backend. It also contains a built-in copy of the page, so this file alone works.
- `public/index.html` - the page. If present it is used instead of the built-in copy, so edit this one.
- `package.json`, `render.yaml`, `.env.example`

No dependencies. Node 18 or newer.

## Run locally
    GEMINI_API_KEY=your-key node server.js
Open http://localhost:3000

## Deploy (Render)
Put these files at the TOP LEVEL of a GitHub repo (not inside a folder). New > Web Service > pick the repo. Build `npm install`, start `npm start`, leave Root Directory empty, add env var `GEMINI_API_KEY`.

## How it is fast
1. Fast model first (`gemini-3.5-flash-lite`, then others). The model that works is remembered.
2. Low video detail and minimal "thinking" for transcription.
3. Videos longer than 7 minutes are split into pieces of about 6 minutes, up to 4 transcribed at once, and shown in order. Timestamps are corrected to match the full video.
4. Free Render services sleep when idle. Ping `/healthz` every 5 minutes (for example with UptimeRobot) to keep it awake, or use a paid plan.

For maximum accuracy over speed set `GEMINI_MODEL=gemini-3.8-flash`.

## Settings
| Name | What it does | Default |
|---|---|---|
| GEMINI_API_KEY | Shared key. Without it visitors must bring their own. | none |
| RATE_LIMIT_PER_HOUR | Transcripts per visitor per hour on the shared key (0 = no limit) | 10 |
| ACCESS_CODE | Code visitors must enter to use the shared key | none |
| GEMINI_MODEL | Model to try first | gemini-3.5-flash-lite |
| PARALLEL | Pieces transcribed at once for long videos | 4 |
| CHUNK_SECONDS | Target piece length | 360 |
| CHUNK_ABOVE_SECONDS | Split only videos longer than this | 420 |
| MAX_CONCURRENT | Transcripts running at once | 4 |
| PORT | Port | 3000 |

## Notes
- Public videos only. Free Gemini keys process about 8 hours of YouTube video per day in total.
- Speaker labels in long videos are chosen per piece, so "Speaker 1" can change between pieces.
- Transcripts are AI-written and can contain mistakes.
- To publish on Google Play, wrap the installed web app (PWA) with PWABuilder / Bubblewrap. A manifest and icons are included.
