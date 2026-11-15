# Ludora online server

Sign in with Google, Facebook or as a guest. Add friends with a friend code, invite them to a game, or tap
"Find players" for quick match. The server serves the game page and handles accounts, friends, matchmaking and rooms.

## Run it
    npm install
    npm start            # http://localhost:3000, guest sign-in works right away

## Turn on Google and Facebook sign-in (set before `npm start`)
- Google: create an OAuth "Web" client at console.cloud.google.com > APIs & Services > Credentials.
  Add your site address under "Authorized JavaScript origins". Then: `GOOGLE_CLIENT_ID=xxxx.apps.googleusercontent.com`
- Facebook: create an app at developers.facebook.com, add "Facebook Login", and add your site address to the valid domains.
  Then: `FACEBOOK_APP_ID=...` and `FACEBOOK_APP_SECRET=...`
Both providers require your site to be on https, so deploy before testing them.

## Put it online
Any Node host works (Render, Railway, Fly.io, a VPS). Start command `npm start`; it reads the `PORT` variable.
Accounts and friends live in one JSON file, so use a host with a persistent disk, or set `DATA_FILE` to a persistent path.
When you outgrow it, swap the file store in server.js for a database.

## Change the game page
Edit `../ludora/index.html` (the game) or `social.part.html` (sign-in, friends, matchmaking), then run `npm run build`.

## Known limits
- Each game is run by its host's phone. If the host leaves, the game ends. Fine for friends; for ranked play you would
  move the game rules onto the server so nobody can cheat.
- No reporting, blocking or chat moderation yet. Add these before opening it to the public (app stores expect them).
