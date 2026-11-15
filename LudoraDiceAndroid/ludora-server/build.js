// Builds public/index.html from the Ludora game file plus the online/friends module.
const fs = require('fs'), path = require('path');
const src = process.argv[2] || path.join(__dirname, '..', 'ludora', 'index.html');
let g = fs.readFileSync(src, 'utf8');
const social = fs.readFileSync(path.join(__dirname, 'social.part.html'), 'utf8');
function rep(a, b) { if (!g.includes(a)) throw new Error('patch target missing: ' + a.slice(0, 40)); g = g.replace(a, b); }
rep('async function netCreate(){\n  var code=randCode();', 'async function netCreate(fc){\n  var code=fc||randCode();');
rep('window.Ludora={start:', 'window.LudoraHooks={netCreate:netCreate,netJoin:netJoin,set:set,NET:NET,notice:notice};\nwindow.Ludora={start:');
// social module (and its window.claude provider) must load before the game script
const i = g.indexOf('<script>\n(function(){');
if (i < 0) throw new Error('game script not found');
g = g.slice(0, i) + social + '\n' + g.slice(i);
// the shipped page needs a document shell
g = '<!doctype html>\n<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"></head><body>\n' + g + '\n</body></html>\n';
fs.mkdirSync(path.join(__dirname, 'public'), { recursive: true });
fs.writeFileSync(path.join(__dirname, 'public', 'index.html'), g);
console.log('built public/index.html', g.length, 'bytes');
