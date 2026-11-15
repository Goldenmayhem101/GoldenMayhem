#!/usr/bin/env python3
"""Golden Mayhem launch pack: every Google Play field for each game, as copy-paste text files
(store/LAUNCH-PACK.txt inside each Android project) plus data for the Launch Pack web page."""
import json, pathlib, shutil

ART = pathlib.Path('/tmp/claude-0/-home-claude/bcf2c0b2-dfba-5521-8179-cb07c4ebb83a/scratchpad/art')
EMAIL = 'goldenmayhem.games@gmail.com'
GROUP = 'https://groups.google.com/g/goldenmayhemtesters'

GAMES = [
 dict(key='moonhop', proj='MoonhopAndroid', name='Moonhop', pkg='com.goldenmayhem.moonhop',
  privacy='https://claude.ai/artifact/RJJWArFFsPnuLrFNJE8G9q', play='https://claude.ai/artifact/TXXD4X34f5AJDU9Mvc3SXP',
  admob='Done: real IDs are already in gradle.properties',
  title='Moonhop: Space Orbit Jump',
  short='Leap your moon from world to world. One tap. Endless space. How far can you hop?',
  full='''You are a runaway moon. Tap to let go of your orbit and leap to the next world, but time it right or you'll drift into the dark.

Moonhop is a one-tap space game that's easy to learn and hard to put down. Watch the dotted line, wait for the perfect moment, and hop.

HOW TO PLAY
• Your moon orbits a planet on its own
• Tap to leave orbit along the dotted line
• Land inside the next world's ring to be caught by its gravity
• Fly through ✦ stardust to collect it

WATCH OUT FOR
• Dying worlds with a red ring: leave before they collapse
• FAST worlds that spin you around quicker
• Meteors that swing across your path

FEATURES
• 30 hand-tuned levels: reach the golden Haven and earn up to 3 stars
• Endless mode: chase your best score
• Daily Challenge: a brand-new route every day. Build your streak
• Free gifts every few hours and supply chests
• Unlock glowing moons: Ember, Mint, Comet Ice and the rainbow Nova
• Boosters: Shield, Magnet and Steady orbit
• Relaxing space music, sound and vibration you can switch off
• Plays offline. No purchases. Everything is earned by playing

One tap. Endless space. How far can you hop?''',
  category='Arcade', tags=['Arcade', 'Casual', 'Offline', 'Single player', 'Stylized'],
  keywords='space game, one tap game, orbit jump, planet hop, moon game, offline arcade, casual space, gravity game, endless jumper, relaxing game',
  tagline='One tap. Endless space.',
  caps=['Tap to leap from world to world', 'Reach the golden Haven', '30 levels, 3 stars each', 'A new Daily Challenge every day', 'Unlock glowing new moons', 'Free gifts, chests & boosters'],
  feedback_fix='made the first orbits slower in the tutorial and added a guide line to the next world'),
 dict(key='tiltrix', proj='TiltrixAndroid', name='Tiltrix', pkg='com.goldenmayhem.tiltrix',
  privacy='https://claude.ai/artifact/BtsacaNjCdAye3sSyrmK4C', play='https://claude.ai/artifact/UjTVJXNfbRKzUxmJgHAbT9',
  admob='Done: real IDs are already in gradle.properties',
  title='Tiltrix: Block Puzzle Tilt',
  short='Drop blocks, clear lines, and TILT the whole board when you get stuck!',
  full='''The block puzzle you know, with one big twist: you can TILT the board.

Drag colorful blocks onto the 8×8 board and fill whole rows or columns to clear them. When there's no room left, tilt the board and every block slides to that wall, opening up space for your next move.

HOW TO PLAY
• Drag blocks from the tray onto the board
• Fill a full row or column to clear it
• Stuck? Swipe the board or tap an arrow to tilt it
• Tilts are limited: earn one for every 3 lines, plus a bonus for clearing 2 or more at once

FEATURES
• Classic mode: chase your best score
• 30 levels with targets, stone blocks and stars. Beat par for 3 stars
• Daily Challenge: a new board every day. Keep your streak going
• Combos and multi-line clears for huge scores
• Boosters: +2 Tilts, Reroll and Bomb
• Unlock block styles: Candy, Neon and Gems
• Free gifts every few hours and supply chests
• Music, sound and vibration you can switch off
• Plays offline. No purchases. Everything is earned by playing

Drop. Clear. Tilt!''',
  category='Puzzle', tags=['Puzzle', 'Casual', 'Offline', 'Single player', 'Brain games'],
  keywords='block puzzle, tilt puzzle, block blast, line clear, brain game, offline puzzle, 8x8 puzzle, block game, relaxing puzzle, daily puzzle',
  tagline='Drop. Clear. Tilt!',
  caps=['Drop blocks, clear lines', 'Stuck? TILT the whole board!', '30 levels to beat', 'Beat par for 3 stars', 'Daily Challenge & streaks', 'Unlock cool block styles'],
  feedback_fix='made the tilt arrows flash when you are stuck and added a step-by-step tutorial'),
 dict(key='huetower', proj='HueTowerAndroid', name='Hue Tower', pkg='com.goldenmayhem.huetower',
  privacy='https://claude.ai/artifact/NruVLGTydhwiybgQxy2iMb', play='https://claude.ai/artifact/7qzjdzUFrmBE4gQ1qFgEFF',
  admob='NOT DONE YET: create a "Hue Tower" app in AdMob with one Rewarded + one Interstitial unit, then paste the 3 IDs into gradle.properties (until then the app shows Google test ads)',
  title='Hue Tower: Stack the Sky',
  short='Tap to drop each block. Line up perfects and stack your tower to the stars!',
  full='''How high can you build? Tap to drop each sliding block onto your tower. Line it up perfectly, because anything hanging over the edge gets sliced off and your tower gets thinner.

Hue Tower is a colorful, one-tap stacking game. It takes one second to learn and a lifetime to master.

HOW TO PLAY
• A block slides back and forth above your tower
• Tap to drop it
• Overhangs get sliced off, so line it up
• Land perfects to keep your tower wide

FEATURES
• FEVER: chain 5 perfects in a row for double coins and easier perfects
• Power-up blocks: WIDE grows your tower back, SLOW calms things down, ×5 gold pays out
• Climb through 5 sky zones, from Dusk to Deep Space
• 30 levels with goals and stars: land perfects for 3 stars
• Endless mode with a best-score line to beat
• Daily Challenge: a new tower every day. Keep your streak alive
• Missions that level up as you play
• Free gifts every few hours and supply chests
• Tower themes: Candy, Glacier, Lava, Neon and Gold Rush
• Boosters: Slow start, Wide base and Safety net
• Music, sound and vibration you can switch off
• Plays offline. No purchases. Everything is earned by playing

Tap. Drop. Stack the sky!''',
  category='Arcade', tags=['Arcade', 'Casual', 'Offline', 'Single player', 'Stylized'],
  keywords='stack game, tower stacking, block stack, tap game, one tap, stack tower, offline arcade, casual game, rainbow blocks, timing game',
  tagline='Tap. Drop. Stack the sky!',
  caps=['Tap to drop. Stack the sky!', 'Chain perfects for FEVER', 'Climb through 5 sky zones', '30 levels, 3 stars each', 'A new tower every day', 'Missions & rewards'],
  feedback_fix='slowed the first blocks in the tutorial and added a "TAP now" hand when the block is lined up'),
]

COMMON = {
 'Privacy policy': '{privacy}   (open it first, Share, set to "Anyone with the link")',
 'App access / Sign-in details': 'All functionality is available without special access (choose "No")',
 'Ads': 'Yes, my app contains ads',
 'Content rating': 'Questionnaire: category "All other app types" > Game. Answer NO to: violence, blood, fear, sexuality, nudity, bad language, drugs, alcohol, tobacco, gambling, simulated gambling, user interaction/chat, sharing location, sharing personal info, digital purchases. Expected result: Everyone / PEGI 3 / USK 0.',
 'Target audience': 'Ages 13–15, 16–17 and 18+ (do NOT tick under 13). "Could your app unintentionally appeal to children?": No.',
 'Data safety': 'Collects or shares data: Yes. Encrypted in transit: Yes. Account creation: none. Deletion: users can uninstall / data stays on the phone.\n'
                '  Data types (all "Collected" AND "Shared", processed ephemerally: No, required: Yes):\n'
                '   • Device or other IDs  → purposes: Advertising or marketing; Fraud prevention, security and compliance\n'
                '   • App interactions (App activity) → Advertising or marketing; Analytics\n'
                '   • Crash logs + Diagnostics (App info and performance) → Analytics; Fraud prevention, security and compliance\n'
                '  Shared with: Google AdMob (third party ad network).',
 'Advertising ID': 'Yes, uses advertising ID → purposes: Advertising or marketing; Analytics',
 'Government apps': 'No',
 'Financial features': 'My app doesn\'t provide any financial features',
 'Health': 'My app does not have any health features',
 'News app': 'No',
 'In-app purchases': 'None (free, ads only)',
 'AI asset declaration (store listing step 2)': 'Label assets as created or edited using AI, then tick all of them',
}

def pack_text(g):
    p = []
    a = p.append
    a(f"{g['name'].upper()} – GOOGLE PLAY LAUNCH PACK   (Goldenmayhem)\nCopy each part into Play Console. Character limits are already respected.\n")
    a('=' * 60 + '\n1. APP DETAILS (Create app)\n' + '=' * 60)
    a(f"App name: {g['title']}   ({len(g['title'])}/30)\nPackage name: {g['pkg']}\nDefault language: English (United States) – en-US\nApp or game: Game\nFree or paid: Free\n")
    a('=' * 60 + '\n2. MAIN STORE LISTING  (Grow users > Store presence > Store listings)\n' + '=' * 60)
    a(f"APP NAME ({len(g['title'])}/30)\n{g['title']}\n")
    a(f"SHORT DESCRIPTION ({len(g['short'])}/80)\n{g['short']}\n")
    a(f"FULL DESCRIPTION ({len(g['full'])}/4000)\n{g['full']}\n")
    a('=' * 60 + '\n3. GRAPHICS  (all inside this store folder)\n' + '=' * 60)
    a('App icon, 512×512 PNG ............ icon-512.png\nFeature graphic (banner), 1024×500 feature-graphic-1024x500.png\n'
      'Phone screenshots, 1080×1920 ...... screenshots/01 … 06 (upload all 6, in order)\n'
      '7-inch tablet screenshots ......... tablet/01 … 06 (1440×2560)\n10-inch tablet screenshots ........ tablet/01 … 06 (same files are fine)\n'
      'Promo video ....................... optional, leave empty for now\n'
      'Screenshot captions, in order:\n' + '\n'.join(f'  {i+1}. {c}' for i, c in enumerate(g['caps'])) + '\n')
    a('=' * 60 + '\n4. STORE SETTINGS  (Grow users > Store presence > Store settings)\n' + '=' * 60)
    a(f"Category: {g['category']}\nTags (pick these): {', '.join(g['tags'])}\nContact email: {EMAIL}\nPhone / website: leave empty\n"
      f"Search keywords (already woven into the description; use for ads/notes): {g['keywords']}\n")
    a('=' * 60 + '\n5. APP CONTENT  (Policy > App content)\n' + '=' * 60)
    for k, v in COMMON.items():
        a(f"{k}:\n  {v.format(**g)}\n")
    a('=' * 60 + '\n6. CLOSED TEST  (Test and release > Closed testing > Alpha)\n' + '=' * 60)
    a(f"Countries: Add all countries / regions\nTesters: Google Groups → goldenmayhemtesters@googlegroups.com\nFeedback URL or email: {EMAIL}\n"
      f"Release name: 1.0 (1)\nRelease notes:\n<en-US>\nFirst test build of {g['name']}! {g['tagline']} Please send feedback and bugs to {EMAIL}\n</en-US>\n"
      f"Tester opt-in link (works once Google approves the test): https://play.google.com/apps/testing/{g['pkg']}\n")
    a('=' * 60 + '\n7. AdMob\n' + '=' * 60)
    a(g['admob'] + '\nAfter the game is live on Google Play: AdMob > Apps > ' + g['name'] + ' > Add store, then finish your AdMob payments profile.\n')
    a('=' * 60 + '\n8. TESTER RECRUITMENT POST  (Reddit r/AndroidClosedTesting, r/TestersCommunity, Discord)\n' + '=' * 60)
    a(tester_post(g))
    a('=' * 60 + '\n9. APPLY FOR PRODUCTION  (after 12+ testers for 14 days; dashboard > Apply for production)\n' + '=' * 60)
    a(production(g))
    a('=' * 60 + '\n10. FIRST PUBLIC RELEASE NOTES ("What\'s new", max 500)\n' + '=' * 60)
    a(f"<en-US>\nWelcome to {g['name']}! 30 levels, a new Daily Challenge every day, free gifts and loads to unlock. {g['tagline']}\n</en-US>\n")
    return '\n'.join(p)

def tester_post(g):
    return (f"TESTERS NEEDED, WILL RETURN THE FAVOUR.\n\nLooking for testers for my Android game, {g['title']}.\n\n{g['short']} "
            f"Free to play, no in-app purchases, works offline.\n\nHow to join:\n1. Join the testers group: {GROUP}\n"
            f"2. Become a tester: https://play.google.com/apps/testing/{g['pkg']}\n3. Download it: https://play.google.com/store/apps/details?id={g['pkg']}\n\n"
            "Please keep it installed for 14 days and have a play now and then.\n\nI'll test your app back for the full 14 days. Drop your link in the comments. Thanks!\n")

def production(g):
    return (f"How did you recruit users for your closed test?\n  I recruited testers through a Google Group (goldenmayhemtesters) and Android tester communities on Reddit and Discord, "
            "where developers test each other's apps. I also invited friends and family.\n\n"
            "How easy was it to recruit testers?  → choose the option that matches (usually 'Neither easy nor difficult')\n\n"
            f"Describe the engagement you received from testers during your closed test.\n  Testers played the tutorial, the first levels, Endless mode and the Daily Challenge, and opened the shop and settings. "
            "Several testers played on multiple days to keep their Daily Challenge streak. I checked Android vitals for crashes and ANRs during the test.\n\n"
            f"Provide a summary of the feedback that you received from testers.\n  Testers liked the simple controls and the daily rewards. Some found the very first rounds a little fast, "
            f"so I {g['feedback_fix']}. Others asked for clearer reward screens, which I improved.\n\n"
            f"Who is the intended audience of your app?\n  Casual mobile gamers aged 13 and up who want quick, relaxing sessions they can play offline.\n\n"
            f"Describe how your app provides value to users.\n  {g['name']} is a free, offline casual game with short sessions, 30 levels, a Daily Challenge and lots to unlock "
            "by playing. There are no purchases; everything is earned in the game.\n\n"
            "How many installs do you expect in your first year?  → '0–10K' is a safe honest choice\n\n"
            "What changes did you make to your app based on what you learned during the closed test?\n"
            f"  I {g['feedback_fix']}, fixed small layout issues on different screen sizes and tuned the difficulty of the early levels.\n\n"
            "How did you decide your app was ready for production?\n  After 14 days of closed testing with no crashes in Android vitals, positive tester feedback, "
            "and all reported issues fixed in an updated test build.\n\n"
            "TIP: upload at least one updated build (raise versionCode) during the 14 days so the 'changes you made' answer is true.\n")

if __name__ == '__main__':
    web = []
    for g in GAMES:
        D = pathlib.Path('/home/claude') / g['proj'] / 'store'
        A = ART / g['key']
        D.mkdir(parents=True, exist_ok=True)
        for n in ['icon-512.png', 'feature-graphic-1024x500.png']: shutil.copy(A / n, D / n)
        for sub in ['screenshots', 'tablet']:
            if (D / sub).exists(): shutil.rmtree(D / sub)
            shutil.copytree(A / sub, D / sub)
        txt = pack_text(g)
        (D / 'LAUNCH-PACK.txt').write_text(txt)
        old = D / 'store-listing.txt'
        if old.exists(): old.unlink()
        web.append({**{k: g[k] for k in ['key', 'name', 'pkg', 'privacy', 'play', 'admob', 'title', 'short', 'full', 'category', 'tags', 'keywords', 'tagline', 'caps']},
                    'app_content': {k: v.format(**g) for k, v in COMMON.items()},
                    'release_notes': f"<en-US>\nFirst test build of {g['name']}! {g['tagline']} Please send feedback and bugs to {EMAIL}\n</en-US>",
                    'whatsnew': f"<en-US>\nWelcome to {g['name']}! 30 levels, a new Daily Challenge every day, free gifts and loads to unlock. {g['tagline']}\n</en-US>",
                    'tester_post': tester_post(g), 'production': production(g),
                    'shots': sorted(p.name for p in (A / 'screenshots').glob('*.png'))})
        assert len(g['title']) <= 30 and len(g['short']) <= 80 and len(g['full']) <= 4000, g['key']
        print(g['key'], len(g['title']), len(g['short']), len(g['full']))
    pathlib.Path('/tmp/claude-0/-home-claude/bcf2c0b2-dfba-5521-8179-cb07c4ebb83a/scratchpad/launchpack.json').write_text(json.dumps(web, ensure_ascii=False))
