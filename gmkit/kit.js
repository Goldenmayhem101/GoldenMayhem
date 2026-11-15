/* ===== Golden Mayhem kit =====
   Shared by every Goldenmayhem game: studio intro, home menu, levels with stars, Daily Challenge calendar + streak,
   free gift timer, chests, shop (skins + boosters), settings (music/sound/vibration/reminder), rate-us, results,
   pause, tutorial hand, rewarded + interstitial ads (native AdMob via the Android app), Android back button. */
(function(){
'use strict';
/* ---------- native bridges (Android app) ---------- */
(function(){
  if(window.AndroidAds){
    var cbs={},n=0;
    window.__adResult=function(id,ok){var c=cbs[id];delete cbs[id];if(c)c(!!ok)};
    window.GMAds={
      showRewarded:function(cb){var id=++n;cbs[id]=cb;AndroidAds.showRewarded(id)},
      showInterstitial:function(cb){var id=++n;cbs[id]=cb;AndroidAds.showInterstitial(id)},
      privacyOptionsRequired:function(){try{return AndroidAds.privacyOptionsRequired()}catch(e){return false}},
      showPrivacyOptions:function(){AndroidAds.showPrivacyOptions()}
    };
  }
  if(window.AndroidApp){
    window.GMApp={
      requestReview:function(){AndroidApp.requestReview()},
      setReminder:function(on){AndroidApp.setReminder(!!on)},
      reminderOn:function(){try{return AndroidApp.reminderOn()}catch(e){return false}},
      vibrate:function(ms){try{AndroidApp.vibrate(ms|0)}catch(e){}},
      openUrl:function(u){try{AndroidApp.openUrl(u)}catch(e){}}
    };
  }
})();

const I={
  gear:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3.2"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/></svg>',
  gift:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="8" width="18" height="5" rx="1"/><path d="M5 13v8h14v-8M12 8v13M12 8S10.5 3 8 3.5 6.5 8 12 8zM12 8s1.5-5 4-4.5S17.5 8 12 8z"/></svg>',
  cal:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="16" rx="3"/><path d="M3 10h18M8 3v4M16 3v4"/><path d="M12 13.2l1 2 2.2.3-1.6 1.5.4 2.2-2-1-2 1 .4-2.2-1.6-1.5 2.2-.3z" fill="currentColor" stroke="none"/></svg>',
  grid:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="2"/><rect x="14" y="3" width="7" height="7" rx="2"/><rect x="3" y="14" width="7" height="7" rx="2"/><path d="M17.5 13.5l1.2 2.4 2.6.4-1.9 1.8.5 2.6-2.4-1.2-2.4 1.2.5-2.6-1.9-1.8 2.6-.4z" fill="currentColor"/></svg>',
  bag:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 8h14l-1 13H6z"/><path d="M9 8V6a3 3 0 0 1 6 0v2"/></svg>',
  star:'<svg viewBox="0 0 24 24"><path d="M12 1.8l3.1 6.4 7 1-5.1 4.9 1.2 7-6.2-3.3-6.2 3.3 1.2-7L1.9 9.2l7-1z" fill="var(--gm-accent)" stroke="rgba(0,0,0,.25)" stroke-width="1"/></svg>',
  flame:'<svg viewBox="0 0 24 24"><path d="M12 2c1 4 6 6 6 12a6 6 0 0 1-12 0c0-3 2-5 3-6 0 2 1 3 2 3 0-4-1-6 1-9z" fill="#ff8a2a"/><path d="M12 12c1 2 3 3 3 5a3 3 0 0 1-6 0c0-1.5 1-2.5 1.5-3 .2 1 .8 1.5 1.5 1.5 0-1.5-.5-2.5 0-3.5z" fill="#ffd23f"/></svg>',
  chest:'<svg viewBox="0 0 64 64"><rect x="6" y="26" width="52" height="30" rx="5" fill="#b8642a"/><path d="M6 31a26 18 0 0 1 52 0v-3a26 20 0 0 0-52 0z" fill="#d9823a"/><path d="M8 28c0-12 11-20 24-20s24 8 24 20z" fill="#e6943f"/><rect x="6" y="26" width="52" height="6" fill="#ffd23f"/><rect x="28" y="22" width="8" height="34" fill="#ffd23f"/><rect x="26" y="30" width="12" height="12" rx="3" fill="#7a3d14"/><circle cx="32" cy="36" r="2.5" fill="#ffd23f"/><path d="M6 50h52" stroke="#7a3d14" stroke-width="3"/></svg>',
  giftBig:'<svg viewBox="0 0 64 64"><rect x="8" y="28" width="48" height="30" rx="4" fill="#ff4f7b"/><rect x="5" y="20" width="54" height="11" rx="3" fill="#ff7096"/><rect x="28" y="20" width="8" height="38" fill="#ffd23f"/><path d="M32 20c-4-9-14-12-15-6s9 6 15 6zM32 20c4-9 14-12 15-6s-9 6-15 6z" fill="#ffd23f"/></svg>',
  music:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l11-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="17" cy="16" r="3"/></svg>',
  sound:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5L6 9H2v6h4l5 4z"/><path d="M15.5 8.5a5 5 0 0 1 0 7M19 5a10 10 0 0 1 0 14"/></svg>',
  vibe:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="7" y="3" width="10" height="18" rx="2"/><path d="M3 8v8M21 8v8"/></svg>',
  bell:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0"/></svg>',
  hand:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 11V4.5a1.5 1.5 0 0 1 3 0V10m0-1.5a1.5 1.5 0 0 1 3 0V11m0-1a1.5 1.5 0 0 1 3 0v5a7 7 0 0 1-7 7h-1a6 6 0 0 1-5-3l-2.5-4.5a1.5 1.5 0 0 1 2.5-1.6L9 15"/></svg>',
  shield:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>',
  doc:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M8 13h8M8 17h6"/></svg>',
  heart:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z"/></svg>',
  home:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11l9-8 9 8M5 9.5V21h14V9.5"/></svg>',
  play:'<svg viewBox="0 0 24 24"><path d="M7 4.5v15l13-7.5z" fill="currentColor"/></svg>',
  retry:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5"/></svg>',
  film:'<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linejoin="round"><rect x="2" y="5" width="15" height="14" rx="3"/><path d="M17 10l5-3v10l-5-3z"/></svg>'
};

/* ---------- storage ---------- */
let C=null,S=null,KEY='';
const DEF=()=>({coins:0,owned:{},equip:{},boost:{},sel:{},set:{music:true,sound:true,vibe:true,reminder:false},
  daily:{done:{},streak:0,last:''},gift:{next:0},chest:0,runs:0,stars:[],best:{},tut:false,intro:0,rate:{done:false,last:0,wins:0},
  freeAds:{day:'',n:0},adRuns:0,game:{}});
function load(){S=DEF();try{const s=JSON.parse(localStorage.getItem(KEY)||'null');if(s){for(const k in s){if(S[k]&&typeof S[k]==='object'&&!Array.isArray(S[k]))Object.assign(S[k],s[k]);else S[k]=s[k]}}}catch(e){}}
function save(){try{localStorage.setItem(KEY,JSON.stringify(S))}catch(e){}}
const $=(s,r=document)=>r.querySelector(s);
function h(tag,cls,html){const e=document.createElement(tag);if(cls)e.className=cls;if(html!=null)e.innerHTML=html;return e}
function rnd(a,b){return a+Math.floor(Math.random()*(b-a+1))}
function dayKey(d=new Date()){return d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0')+'-'+String(d.getDate()).padStart(2,'0')}
function hashStr(s){let x=2166136261;for(let i=0;i<s.length;i++){x^=s.charCodeAt(i);x=Math.imul(x,16777619)}return x>>>0}
function fmtTime(ms){const s=Math.max(0,Math.ceil(ms/1000));const hh=Math.floor(s/3600),mm=Math.floor(s%3600/60),ss=s%60;return hh?hh+'h '+String(mm).padStart(2,'0')+'m':mm+':'+String(ss).padStart(2,'0')}
function esc(s){return String(s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]))}

/* ---------- audio: shared context, sound effects, procedural music ---------- */
let ac=null,master=null,musicGain=null,sfxGain=null;
function audio(){
  if(!ac){try{ac=new (window.AudioContext||window.webkitAudioContext)();master=ac.createGain();master.connect(ac.destination);
    musicGain=ac.createGain();musicGain.gain.value=S.set.music?1:0;musicGain.connect(master);sfxGain=ac.createGain();sfxGain.connect(master)}catch(e){}}
  if(ac&&ac.state==='suspended'&&!document.hidden)ac.resume().catch(()=>{});
  return ac;
}
function tone(f1,f2,d,type='sine',v=.07,delay=0){
  if(!S.set.sound||!audio())return;
  try{const t=ac.currentTime+delay,o=ac.createOscillator(),g=ac.createGain();o.type=type;o.frequency.setValueAtTime(f1,t);if(f2&&f2!==f1)o.frequency.exponentialRampToValueAtTime(f2,t+d);
    g.gain.setValueAtTime(0.0001,t);g.gain.exponentialRampToValueAtTime(v,t+.008);g.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(g).connect(sfxGain);o.start(t);o.stop(t+d+.02)}catch(e){}
}
function vibrate(ms){if(!S.set.vibe)return;if(window.GMApp&&GMApp.vibrate){GMApp.vibrate(ms);return}try{navigator.vibrate&&navigator.vibrate(ms)}catch(e){}}
const ui={tap:()=>tone(520,620,.06,'triangle',.05),coin:()=>{tone(1100,1500,.09,'sine',.05);tone(1500,1900,.1,'sine',.04,.07)},
  win:()=>[523,659,784,1046].forEach((f,i)=>tone(f,f,.22,'triangle',.06,i*.1)),buy:()=>{tone(700,900,.08,'square',.03);tone(900,1300,.12,'triangle',.05,.06)},
  no:()=>tone(220,160,.18,'sawtooth',.04),open:()=>[392,523,659,784,1046,1318].forEach((f,i)=>tone(f,f*1.01,.18,'triangle',.05,i*.06))};
/* music: soft generative arpeggio over a 4-chord loop */
let mus={on:false,timer:0,step:0,next:0};
function musicStart(){if(!audio()||mus.on)return;mus.on=true;mus.next=ac.currentTime+.1;mus.step=0;musTick()}
function musTick(){
  if(!mus.on)return;const M=C.music||{};const prog=M.prog||[[0,4,7],[-3,0,4],[-7,-3,0],[-5,-1,2]];const root=M.root||220,bpm=M.bpm||92,spb=60/bpm/2;
  while(mus.next<ac.currentTime+.4){
    const bar=Math.floor(mus.step/8)%prog.length,ch=prog[bar],i=mus.step%8,t=mus.next;
    const pat=M.pattern||[0,1,2,1,0,2,1,2];const semi=ch[pat[i]%ch.length]+(i===5?12:0);const f=root*Math.pow(2,semi/12);
    note(f,t,spb*1.8,M.wave||'triangle',.022);
    if(i===0)note(root/2*Math.pow(2,ch[0]/12),t,spb*7,'sine',.035);
    mus.step++;mus.next+=spb;
  }
  mus.timer=setTimeout(musTick,120);
}
function note(f,t,d,type,v){try{const o=ac.createOscillator(),g=ac.createGain(),lp=ac.createBiquadFilter();lp.type='lowpass';lp.frequency.value=1800;o.type=type;o.frequency.value=f;
  g.gain.setValueAtTime(0.0001,t);g.gain.linearRampToValueAtTime(v,t+.04);g.gain.exponentialRampToValueAtTime(.0001,t+d);o.connect(lp).connect(g).connect(musicGain);o.start(t);o.stop(t+d+.05)}catch(e){}}
function musicStop(){mus.on=false;clearTimeout(mus.timer)}
function applyMusic(){if(!ac)return;musicGain.gain.setTargetAtTime(S.set.music?1:0,ac.currentTime,.1);if(S.set.music)musicStart()}
document.addEventListener('visibilitychange',()=>{if(!ac)return;if(document.hidden){musicStop();ac.suspend().catch(()=>{})}else{ac.resume().catch(()=>{});if(S.set.music)musicStart()}});
addEventListener('pointerdown',()=>{audio();if(S&&S.set.music)musicStart()},{capture:true});

/* ---------- ads ---------- */
function rewarded(onReward,onFail){
  if(window.GMAds){GMAds.showRewarded(ok=>{if(ok)onReward();else onFail&&onFail()});return}
  // web preview: a 3 second stand-in for the real AdMob video
  const L=layer('gm-adph','',`<div class="gm-panel"><h3>Ad</h3><p class="gm-p">Your AdMob rewarded video plays here in the app.</p><div class="gm-big" id="gm-adn">3</div></div>`);
  let n=3;const iv=setInterval(()=>{n--;$('#gm-adn').textContent=n;if(n<=0){clearInterval(iv);L.remove();onReward()}},1000);
}
function interstitial(done){if(window.GMAds){GMAds.showInterstitial(()=>done&&done())}else done&&done()}
let sessionStart=Date.now(),lastAdAt=Date.now();
function maybeInterstitial(done){
  // gentle pacing: never in the first 3 runs ever, at most every 3rd run and 2 minutes apart
  S.adRuns=(S.adRuns||0)+1;save();
  if(S.runs>3&&S.adRuns>=3&&Date.now()-lastAdAt>120000){S.adRuns=0;lastAdAt=Date.now();save();interstitial(done)}else done&&done();
}

/* ---------- layers / navigation ---------- */
const stack=[];
function layer(id,cls,html,onClose){
  let L=document.getElementById(id);if(L)L.remove();
  L=h('div','gm-layer gm-scrim '+(cls||''));L.id=id;L.innerHTML=html;document.body.appendChild(L);
  return L;
}
function sheet(id,title,body,opts={}){
  const L=layer(id,'',`<div class="gm-panel"><div class="gm-head"><h2>${title}</h2>${opts.noClose?'':'<button class="gm-x" aria-label="Close">✕</button>'}</div>${body}</div>`);
  const close=()=>{L.remove();const i=stack.indexOf(entry);if(i>=0)stack.splice(i,1);opts.onClose&&opts.onClose()};
  const entry={L,close,back:opts.back||close};stack.push(entry);
  const x=$('.gm-x',L);if(x)x.onclick=()=>{ui.tap();close()};
  L.addEventListener('pointerdown',e=>{if(e.target===L&&!opts.noClose){close()}});
  return{L,close};
}
function closeAll(){while(stack.length)stack[stack.length-1].close()}

/* ---------- coins ---------- */
function coins(){return S.coins}
function addCoins(n){S.coins=Math.max(0,S.coins+n);save();refreshHome()}
function spend(n){if(S.coins<n)return false;S.coins-=n;save();refreshHome();return true}
const CUR=()=>C.currency||{icon:'●',name:'Coins'};
function coinTxt(n){return `<span class="gm-coin">${CUR().icon} ${n}</span>`}

/* ---------- toast ---------- */
function toast(t){let w=$('#gm-toast');if(!w){w=h('div');w.id='gm-toast';document.body.appendChild(w)}const d=h('div',null,t);w.appendChild(d);setTimeout(()=>d.remove(),2300)}

/* ---------- intro ---------- */
function intro(done){
  const first=!S.intro;S.intro=(S.intro||0)+1;save();
  const L=h('div','gm-layer');L.id='gm-intro';L.innerHTML='<canvas></canvas><div class="gm-skip">TAP TO SKIP</div>';document.body.appendChild(L);
  const cv=$('canvas',L),g=cv.getContext('2d');let W,H,dpr;
  function rs(){dpr=Math.min(2,devicePixelRatio||1);W=L.clientWidth;H=L.clientHeight;cv.width=W*dpr;cv.height=H*dpr;g.setTransform(dpr,0,0,dpr,0,0)}rs();addEventListener('resize',rs);
  const studio=first?2.1:0,logo=first?2.3:1.25,total=studio+logo;let t0=performance.now(),end=false;
  function finish(){if(end)return;end=true;removeEventListener('resize',rs);L.style.transition='opacity .35s';L.style.opacity='0';setTimeout(()=>{L.remove();done()},350)}
  L.addEventListener('pointerdown',finish);
  (function fr(now){if(end)return;const t=Math.max(0,(now-t0)/1000);
    g.fillStyle='#07060f';g.fillRect(0,0,W,H);
    if(studio>0&&t<studio){drawStudio(g,W,H,t/studio)}
    else{const p=Math.min(1,(t-studio)/logo);g.save();C.intro.draw(g,W,H,p,t-studio);g.restore();
      const fade=p<.12?1-p/.12:0;if(first&&fade>0){g.fillStyle=`rgba(7,6,15,${fade})`;g.fillRect(0,0,W,H)}}
    if(t>=total){finish();return}requestAnimationFrame(fr)})(t0);
}
function drawStudio(g,W,H,p){
  const a=p<.22?p/.22:p>.8?Math.max(0,1-(p-.8)/.2):1;const cx=W/2,cy=H/2;
  g.globalAlpha=a;
  const rg=g.createRadialGradient(cx,cy,10,cx,cy,Math.max(W,H)*.6);rg.addColorStop(0,'rgba(255,200,60,.16)');rg.addColorStop(1,'rgba(255,200,60,0)');g.fillStyle=rg;g.fillRect(0,0,W,H);
  g.textAlign='center';g.textBaseline='middle';
  const fs=Math.min(W*.115,52);
  // crown, then "A GAME BY", then the studio name
  g.save();g.translate(cx,cy-fs*1.75);g.scale(fs/52,fs/52);g.fillStyle='#ffc62e';g.beginPath();g.moveTo(-26,10);g.lineTo(-30,-12);g.lineTo(-12,0);g.lineTo(0,-18);g.lineTo(12,0);g.lineTo(30,-12);g.lineTo(26,10);g.closePath();g.fill();g.restore();
  g.fillStyle='rgba(255,255,255,.7)';g.font='800 '+Math.round(Math.min(W*.04,16))+'px '+bodyFont();g.fillText('A GAME BY',cx,cy-fs*.85);
  // studio name with a moving shine, drawn on its own small canvas so the shine stays inside the letters
  const tw=Math.ceil(W),th=Math.ceil(fs*1.6),dp=Math.min(2,devicePixelRatio||1);
  if(!drawStudio.c){drawStudio.c=document.createElement('canvas')}const oc=drawStudio.c;oc.width=tw*dp;oc.height=th*dp;const o=oc.getContext('2d');o.scale(dp,dp);
  o.textAlign='center';o.textBaseline='middle';o.font='400 '+Math.round(fs)+'px '+dispFont();
  const gr=o.createLinearGradient(0,th/2-fs/2,0,th/2+fs/2);gr.addColorStop(0,'#fff3b0');gr.addColorStop(.5,'#ffc62e');gr.addColorStop(1,'#e88a12');
  o.fillStyle=gr;o.fillText('GOLDENMAYHEM',tw/2,th/2);
  const sx=-W*.3+p*W*1.6;o.globalCompositeOperation='source-atop';const sg=o.createLinearGradient(sx-60,0,sx+60,0);sg.addColorStop(0,'rgba(255,255,255,0)');sg.addColorStop(.5,'rgba(255,255,255,.85)');sg.addColorStop(1,'rgba(255,255,255,0)');o.fillStyle=sg;o.fillRect(0,0,tw,th);
  g.drawImage(oc,0,cy+4-th/2,tw,th);
  g.globalAlpha=1;
}
function dispFont(){return getComputedStyle(document.documentElement).getPropertyValue('--gm-font-display')}
function bodyFont(){return getComputedStyle(document.documentElement).getPropertyValue('--gm-font-body')}

/* ---------- home ---------- */
let home=null,mode='boot',homeTimer=0;
function buildHome(){
  home=h('div','gm-layer');home.id='gm-home';
  home.innerHTML=`<div class="gm-home">
   <div class="gm-top"><div class="gm-pill"><span class="ic">${CUR().icon}</span><span id="gm-coins">0</span></div><div class="gm-spacer"></div>
     <button class="gm-icon" id="gm-giftb" aria-label="Free gift">${I.gift}<span class="gm-t" id="gm-giftt"></span></button>
     <button class="gm-icon" id="gm-setb" aria-label="Settings">${I.gear}</button></div>
   <div class="gm-title" id="gm-title">${C.titleHtml||''}</div>
   <div class="gm-menu">
     <button class="gm-chest" id="gm-chestb">${I.chest}<span id="gm-chestt"></span><span class="bar"><i id="gm-chesti"></i></span></button>
     <div class="gm-chips" id="gm-chips"></div>
     <button class="gm-btn gm-play" id="gm-playb">${I.play.replace('<svg','<svg width="30" height="30"')} ${C.playLabel||'Play'}</button>
     <div class="gm-grid3${C.extra?' four':''}">
       <button class="gm-card" id="gm-lvb">${I.grid}Levels<small id="gm-lvs"></small></button>
       <button class="gm-card" id="gm-dyb">${I.cal}Daily<small id="gm-dys"></small><span class="gm-dot" id="gm-dyd" hidden></span></button>
       <button class="gm-card" id="gm-shb">${I.bag}Shop<small>${CUR().name}</small></button>
       ${C.extra?`<button class="gm-card" id="gm-exb">${C.extra.icon}${C.extra.label}<small id="gm-exs"></small><span class="gm-dot" id="gm-exd" hidden></span></button>`:''}
     </div>
   </div></div>`;
  document.body.appendChild(home);
  $('#gm-playb').onclick=()=>{ui.tap();startGame(()=>C.onPlay())};
  $('#gm-lvb').onclick=()=>{ui.tap();openLevels()};
  $('#gm-dyb').onclick=()=>{ui.tap();openDaily()};
  $('#gm-shb').onclick=()=>{ui.tap();openShop()};
  $('#gm-setb').onclick=()=>{ui.tap();openSettings()};
  $('#gm-giftb').onclick=()=>{ui.tap();openGift()};
  if(C.extra)$('#gm-exb').onclick=()=>{ui.tap();C.extra.open()};
  $('#gm-chestb').onclick=()=>{ui.tap();if(S.chest>=3)openChest();else toast(`Finish ${3-S.chest} more run${3-S.chest>1?'s':''} to open the chest`)};
  homeTimer=setInterval(()=>{if(mode==='home')refreshGift()},1000);
}
function refreshHome(){
  if(!home)return;$('#gm-coins').textContent=S.coins;
  const tot=S.stars.reduce((a,b)=>a+(b||0),0);$('#gm-lvs').textContent='★ '+tot+'/'+C.levels.count*3;
  const st=streakNow();$('#gm-dys').textContent=S.daily.done[dayKey()]?'Done ✓':(st?st+' day streak':'New today');$('#gm-dyd').hidden=!!S.daily.done[dayKey()];
  const cb=$('#gm-chestb');cb.classList.toggle('ready',S.chest>=3);$('#gm-chestt').textContent=S.chest>=3?'Chest ready! Tap to open':'Chest: '+S.chest+'/3 runs';$('#gm-chesti').style.width=(S.chest/3*100)+'%';
  if(C.extra&&C.extra.refresh){const r=C.extra.refresh();$('#gm-exs').textContent=r.sub||'';$('#gm-exd').hidden=!r.dot}
  refreshGift();renderChips();
}
function refreshGift(){const b=$('#gm-giftb');if(!b)return;const left=S.gift.next-Date.now();b.classList.toggle('ready',left<=0);$('#gm-giftt').textContent=left<=0?'FREE':fmtTime(left)}
function renderChips(){
  const box=$('#gm-chips');if(!box)return;box.innerHTML='';
  (C.shop.boosters||[]).forEach(b=>{const n=S.boost[b.id]||0;if(!n){delete S.sel[b.id];return}
    const c=h('button','gm-chip'+(S.sel[b.id]?' on':''),`${b.icon||''} ${esc(b.name)} <b>×${n}</b>`);
    c.onclick=()=>{ui.tap();S.sel[b.id]=!S.sel[b.id];save();renderChips()};box.appendChild(c)});
  if(box.children.length){const t=h('div','gm-p','Tap a booster to use it on your next run');t.style.cssText='width:100%;font-size:12px';box.prepend(t)}
}
function showHome(){closeAll();mode='home';home.hidden=false;refreshHome();C.onHome&&C.onHome();
  if(S.rate.pending){S.rate.pending=false;save();setTimeout(rateAsk,500)}}
function startGame(fn){closeAll();mode='game';home.hidden=true;fn()}
/** boosters chosen on the home screen; using them removes one of each from the player's stock */
function takeBoosters(){const out=[];for(const id in S.sel){if(S.sel[id]&&(S.boost[id]||0)>0){S.boost[id]--;out.push(id)}}S.sel={};save();return out}

/* ---------- levels ---------- */
function openLevels(){
  const n=C.levels.count;let body=`<div class="gm-starsum">★ ${S.stars.reduce((a,b)=>a+(b||0),0)} / ${n*3}</div><div class="gm-levels">`;
  for(let i=0;i<n;i++){const st=S.stars[i]||0,open=i===0||(S.stars[i-1]||0)>0,next=open&&!st;
    body+=`<button class="gm-tile${open?'':' locked'}${next?' next':''}" data-i="${i}" ${open?'':'aria-disabled="true"'}>${open?i+1:'🔒'}<span class="st">${'<b>★</b>'.repeat(st)}${'★'.repeat(3-st)}</span></button>`}
  body+='</div><p class="gm-p" style="font-size:13px">'+(C.levels.hint||'Earn up to 3 stars on every level. Replay any level to beat your stars.')+'</p>';
  const s=sheet('gm-levelsL','Levels',body);
  s.L.querySelectorAll('.gm-tile').forEach(b=>b.onclick=()=>{const i=+b.dataset.i;if(b.classList.contains('locked')){ui.no();b.classList.remove('gm-shake');void b.offsetWidth;b.classList.add('gm-shake');toast('Finish level '+i+' first');return}ui.tap();startGame(()=>C.levels.play(i))});
  const nx=s.L.querySelector('.gm-tile.next');if(nx)nx.scrollIntoView({block:'center'});
}
function setStars(i,st){const old=S.stars[i]||0;if(st>old){S.stars[i]=st;save()}return Math.max(0,st-old)}

/* ---------- daily challenge ---------- */
function yesterdayKey(){const d=new Date();d.setDate(d.getDate()-1);return dayKey(d)}
function streakNow(){const l=S.daily.last;return(l===dayKey()||l===yesterdayKey())?S.daily.streak:0}
function dailySeed(){return hashStr(C.id+'|'+dayKey())}
function openDaily(){
  const now=new Date(),y=now.getFullYear(),m=now.getMonth(),first=new Date(y,m,1).getDay(),days=new Date(y,m+1,0).getDate(),today=now.getDate();
  let cal='<div class="gm-cal">'+['S','M','T','W','T','F','S'].map(d=>`<div class="wd">${d}</div>`).join('');
  for(let i=0;i<first;i++)cal+='<div class="d e"></div>';
  for(let d=1;d<=days;d++){const k=dayKey(new Date(y,m,d));cal+=`<div class="d${S.daily.done[k]?' done':''}${d===today?' today':''}${d>today?' fut':''}">${S.daily.done[k]?'★':d}</div>`}
  cal+='</div>';
  const done=!!S.daily.done[dayKey()],st=streakNow(),rew=dailyReward(done?st:st+1);
  const mid=new Date(y,m,today+1)-now;
  const body=`<h3>${now.toLocaleString('en',{month:'long'})} ${y}</h3>${cal}
   <div class="gm-streak">${I.flame}<span>${st} day streak</span></div>
   <div class="gm-goal">${C.daily.goal}<br>Reward: ${coinTxt(rew)} ${done?'':'<span style="color:var(--gm-muted)">(grows with your streak)</span>'}</div>
   ${done?`<button class="gm-btn sec" disabled>Done ✓ New challenge in <span id="gm-dyt">${fmtTime(mid)}</span></button>`:`<button class="gm-btn" id="gm-dyplay">${I.play.replace('<svg','<svg width="22" height="22"')} Play today's challenge</button>`}`;
  const s=sheet('gm-dailyL','Daily Challenge',body);
  const pb=$('#gm-dyplay',s.L);if(pb)pb.onclick=()=>{ui.tap();startGame(()=>C.daily.play(dailySeed(),dayKey()))};
}
function dailyReward(streak){return 40+10*Math.min(Math.max(streak,1)-1,6)}
/** call when the player beats today's challenge; returns the coin reward (0 if already done today) */
function dailyComplete(key){
  key=key||dayKey();if(S.daily.done[key])return 0;
  S.daily.done[key]=true;S.daily.streak=(S.daily.last===yesterdayKey()?S.daily.streak:0)+1;S.daily.last=key;
  // keep the stored calendar small (about 3 months)
  const keys=Object.keys(S.daily.done).sort();while(keys.length>100)delete S.daily.done[keys.shift()];
  save();return dailyReward(S.daily.streak);
}

/* ---------- shop ---------- */
let shopTab=0;
function openShop(){
  const tabs=[C.shop.skinsTitle||'Skins','Boosters'];
  const s=sheet('gm-shopL','Shop',`<div class="gm-pill" style="align-self:center"><span class="ic">${CUR().icon}</span><span id="gm-shopc">${S.coins}</span></div>
    <div class="gm-tabs">${tabs.map((t,i)=>`<button data-t="${i}">${t}</button>`).join('')}</div><div class="gm-items" id="gm-items"></div>
    <button class="gm-btn good sm" id="gm-free">${I.film.replace('<svg','<svg width="20" height="20"')} Free ${CUR().icon} 20 <span class="gm-ad">AD</span></button><p class="gm-p" id="gm-freet" style="font-size:12px"></p>`);
  const draw=()=>{
    $('#gm-shopc',s.L).textContent=S.coins;s.L.querySelectorAll('.gm-tabs button').forEach(b=>b.classList.toggle('on',+b.dataset.t===shopTab));
    const box=$('#gm-items',s.L);box.innerHTML='';
    if(shopTab===0){C.shop.skins.forEach(k=>{const own=k.cost===0||S.owned[k.id],on=(S.equip.skin||C.shop.skins[0].id)===k.id;
      const b=h('button','gm-item'+(on?' on':'')+(!own&&S.coins<k.cost?' poor':''),`<div class="sw" style="${k.swatch||''}">${k.icon||''}</div>${esc(k.name)}<span class="gm-price${own?' own':''}">${on?'Equipped':own?'Tap to use':CUR().icon+' '+k.cost}</span>`);
      b.onclick=()=>{if(own){S.equip.skin=k.id;save();ui.tap();C.shop.onEquip&&C.shop.onEquip(k.id);draw();return}
        if(spend(k.cost)){S.owned[k.id]=true;S.equip.skin=k.id;save();ui.buy();toast(esc(k.name)+' unlocked!');C.shop.onEquip&&C.shop.onEquip(k.id);draw()}else{ui.no();b.classList.remove('gm-shake');void b.offsetWidth;b.classList.add('gm-shake');toast('Not enough '+CUR().name)}};box.appendChild(b)})}
    else{C.shop.boosters.forEach(k=>{const n=S.boost[k.id]||0;
      const b=h('button','gm-item'+(S.coins<k.cost?' poor':''),`<div class="sw" style="background:rgba(255,255,255,.08);font-size:30px">${k.icon}</div>${esc(k.name)} <span style="color:var(--gm-muted)">×${n}</span><span class="ds">${esc(k.desc)}</span><span class="gm-price">${CUR().icon} ${k.cost}</span>`);
      b.onclick=()=>{if(spend(k.cost)){S.boost[k.id]=n+1;save();ui.buy();toast(esc(k.name)+' +1');draw()}else{ui.no();b.classList.remove('gm-shake');void b.offsetWidth;b.classList.add('gm-shake');toast('Not enough '+CUR().name)}};box.appendChild(b)})}
    const fd=S.freeAds.day===dayKey()?S.freeAds.n:0;$('#gm-free',s.L).disabled=fd>=3;$('#gm-freet',s.L).textContent=fd>=3?'Come back tomorrow for more free '+CUR().name:(3-fd)+' free video'+(3-fd>1?'s':'')+' left today';
  };
  s.L.querySelectorAll('.gm-tabs button').forEach(b=>b.onclick=()=>{shopTab=+b.dataset.t;ui.tap();draw()});
  $('#gm-free',s.L).onclick=()=>{rewarded(()=>{if(S.freeAds.day!==dayKey())S.freeAds={day:dayKey(),n:0};S.freeAds.n++;addCoins(20);ui.coin();toast('+'+CUR().icon+' 20');draw()})};
  draw();
}
function equipped(){return S.equip.skin||C.shop.skins[0].id}

/* ---------- settings ---------- */
function openSettings(inGame){
  const row=(k,ic,label)=>`<button class="gm-tog${S.set[k]?' on':''}" data-k="${k}">${ic}<span>${label}</span><i class="gm-sw"></i></button>`;
  const priv=window.GMAds&&GMAds.privacyOptionsRequired();
  const s=sheet('gm-setL','Settings',`<div class="gm-set">${row('music',I.music,'Music')}${row('sound',I.sound,'Sound effects')}${row('vibe',I.vibe,'Vibration')}${row('reminder',I.bell,'Daily Challenge reminder')}
    ${inGame?'':`<button class="gm-tog" id="gm-tut">${I.hand}<span>Replay tutorial</span></button>`}
    <button class="gm-tog" id="gm-rate">${I.heart}<span>Rate ${esc(C.name)}</span></button>
    <button class="gm-tog" id="gm-pp">${I.doc}<span>Privacy policy</span></button>
    ${priv?`<button class="gm-tog" id="gm-adp">${I.shield}<span>Ad privacy choices</span></button>`:''}</div>
    <div class="gm-foot">${esc(C.name)} v${C.version||'1.0'} · A game by Goldenmayhem</div>`);
  s.L.querySelectorAll('.gm-tog[data-k]').forEach(b=>b.onclick=()=>{const k=b.dataset.k;S.set[k]=!S.set[k];save();b.classList.toggle('on',S.set[k]);ui.tap();
    if(k==='music')applyMusic();if(k==='vibe'&&S.set.vibe)vibrate(30);
    if(k==='reminder'){if(window.GMApp)GMApp.setReminder(S.set.reminder);else if(S.set.reminder)toast('Reminders work in the Android app')}});
  const tut=$('#gm-tut',s.L);if(tut)tut.onclick=()=>{S.tut=false;save();startGame(()=>C.tutorial())};
  $('#gm-rate',s.L).onclick=()=>{S.rate.done=true;save();if(window.GMApp)GMApp.requestReview();else toast('Thanks! Rating opens in the Android app')};
  $('#gm-pp',s.L).onclick=()=>openUrl(C.privacyUrl);
  const ap=$('#gm-adp',s.L);if(ap)ap.onclick=()=>GMAds.showPrivacyOptions();
}
function openUrl(u){if(window.GMApp&&GMApp.openUrl){GMApp.openUrl(u);return}const a=h('a');a.href=u;a.target='_blank';a.rel='noopener';document.body.appendChild(a);a.click();a.remove()}

/* ---------- gift + chest ---------- */
function openGift(){
  const left=S.gift.next-Date.now();
  if(left>0){sheet('gm-giftL','Free gift',`<div class="gm-prize">${I.giftBig}</div><p class="gm-p">Your next free gift is ready in</p><div class="gm-big" style="font-size:44px">${fmtTime(left)}</div><p class="gm-p">A new gift arrives every 4 hours.</p>`);return}
  const amt=rnd(12,24);
  const s=sheet('gm-giftL','Free gift!',`<div class="gm-prize shake" id="gm-gp">${I.giftBig}</div><div class="gm-earn">${CUR().icon} ${amt}</div>
    <button class="gm-btn good" id="gm-g2">${I.film.replace('<svg','<svg width="22" height="22"')} Claim ×2 <span class="gm-ad">AD</span></button><button class="gm-btn sec" id="gm-g1">Claim ${CUR().icon} ${amt}</button>`);
  const claim=n=>{S.gift.next=Date.now()+4*3600e3;save();addCoins(n);ui.coin();vibrate(20);s.close();toast('+'+CUR().icon+' '+n)};
  $('#gm-g1',s.L).onclick=()=>claim(amt);
  $('#gm-g2',s.L).onclick=()=>rewarded(()=>claim(amt*2));
}
function openChest(){
  const s=sheet('gm-chestL','Supply chest',`<div class="gm-prize shake" id="gm-cp">${I.chest}</div><p class="gm-p" id="gm-ct">Tap the chest to open it!</p><div class="gm-loot" id="gm-cl"></div><button class="gm-btn" id="gm-cok" hidden>Collect</button>`,{noClose:true});
  let opened=false;const p=$('#gm-cp',s.L);
  p.onclick=()=>{if(opened)return;opened=true;p.classList.remove('shake');p.classList.add('open');ui.open();vibrate(40);
    const amt=rnd(25,50);const bs=C.shop.boosters;const b=bs[Math.floor(Math.random()*bs.length)];
    S.chest=0;S.coins+=amt;S.boost[b.id]=(S.boost[b.id]||0)+1;save();
    $('#gm-ct',s.L).textContent='You got:';$('#gm-cl',s.L).innerHTML=`<div class="gm-coin">${CUR().icon} ${amt}</div><div>${b.icon} ${esc(b.name)}</div>`;$('#gm-cok',s.L).hidden=false};
  $('#gm-cok',s.L).onclick=()=>{s.close();refreshHome()};
}

/* ---------- rate us ---------- */
function rateAsk(){
  if(S.rate.done)return;
  const s=sheet('gm-rateL','Enjoying '+esc(C.name)+'?',`<div class="gm-stars">${I.star}${I.star}${I.star}</div><p class="gm-p">A quick rating on Google Play really helps a small studio like Goldenmayhem. Thank you!</p>
    <button class="gm-btn" id="gm-ry">Rate now</button><button class="gm-btn ghost" id="gm-rn">Not now</button>`);
  setTimeout(()=>s.L.querySelectorAll('.gm-stars svg').forEach((e,i)=>setTimeout(()=>e.classList.add('on'),i*150)),100);
  $('#gm-ry',s.L).onclick=()=>{S.rate.done=true;save();s.close();if(window.GMApp)GMApp.requestReview();else toast('Thanks! Rating opens in the Android app')};
  $('#gm-rn',s.L).onclick=()=>{S.rate.last=Date.now();save();s.close()};
}

/* ---------- results ---------- */
/* opts: {win, title, label, score, best, newBest, stars(0-3|null), coins, extra:{label,amount}, canRevive, reviveLabel, onRevive, onRetry, onNext, onHome} */
function results(o){
  S.runs++;if(S.chest<3)S.chest++;
  if(o.win||o.newBest){S.rate.wins++;if(!S.rate.done&&S.rate.wins>=3&&S.runs>=5&&Date.now()-S.rate.last>3*864e5)S.rate.pending=true}
  let earned=(o.coins||0)+((o.extra&&o.extra.amount)||0);S.coins+=earned;save();
  const starsHtml=o.stars==null?'':`<div class="gm-stars">${I.star}${I.star}${I.star}</div>`;
  const s=sheet('gm-resL',esc(o.title),`${starsHtml}
    ${o.label?`<h3>${esc(o.label)}</h3>`:''}<div class="gm-big">${o.score}</div>${o.newBest?'<span class="gm-newbest">NEW BEST!</span>':(o.best!=null?`<p class="gm-p">Best ${o.best}</p>`:'')}
    <div class="gm-earn" id="gm-earn">+ ${CUR().icon} <span id="gm-earnn">${earned}</span></div>
    ${o.extra?`<p class="gm-p" style="font-size:13px">${esc(o.extra.label)} ${coinTxt(o.extra.amount)} included</p>`:''}
    ${o.canRevive?`<button class="gm-btn good" id="gm-rv">${I.film.replace('<svg','<svg width="22" height="22"')} ${esc(o.reviveLabel||'Keep going')} <span class="gm-ad">AD</span></button>`:''}
    ${earned>0?`<button class="gm-btn sec sm" id="gm-dbl">${I.film.replace('<svg','<svg width="18" height="18"')} Double to ${CUR().icon} ${earned*2} <span class="gm-ad">AD</span></button>`:''}
    ${o.onNext?`<button class="gm-btn" id="gm-nx">Next level ${I.play.replace('<svg','<svg width="20" height="20"')}</button>`:''}
    <div class="gm-row"><button class="gm-btn sec" id="gm-hm" aria-label="Home">${I.home.replace('<svg','<svg width="22" height="22"')}</button><button class="gm-btn ${o.onNext?'sec':''}" id="gm-rt" style="flex:3">${I.retry.replace('<svg','<svg width="20" height="20"')} ${o.retryLabel||'Try again'}</button></div>`,{noClose:true,back:()=>{s.close();maybeInterstitial(()=>{(o.onHome||showHome)()})}});
  if(o.stars!=null){if(o.stars>0)ui.win();setTimeout(()=>s.L.querySelectorAll('.gm-stars svg').forEach((e,i)=>{if(i<o.stars)setTimeout(()=>{e.classList.add('on');tone(700+i*200,900+i*200,.15,'triangle',.06)},i*260)}),250)}
  else if(o.newBest)ui.win();
  const go=fn=>{s.close();maybeInterstitial(fn)};
  const rv=$('#gm-rv',s.L);if(rv)rv.onclick=()=>rewarded(()=>{S.runs--;S.chest=Math.max(0,S.chest-1);S.coins-=earned;save();s.close();o.onRevive()});
  const db=$('#gm-dbl',s.L);if(db)db.onclick=()=>rewarded(()=>{S.coins+=earned;save();ui.coin();db.remove();$('#gm-earnn',s.L).textContent=earned*2;toast('Doubled! +'+CUR().icon+' '+earned)});
  const nx=$('#gm-nx',s.L);if(nx)nx.onclick=()=>{ui.tap();go(()=>{mode='game';o.onNext()})};
  $('#gm-rt',s.L).onclick=()=>{ui.tap();go(()=>{mode='game';o.onRetry()})};
  $('#gm-hm',s.L).onclick=()=>{ui.tap();go(()=>(o.onHome||showHome)())};
}

/* ---------- pause ---------- */
function pause(o){
  const tg=(k,ic)=>`<button class="gm-icon${S.set[k]?'':' off'}" data-k="${k}" aria-label="${k}" style="${S.set[k]?'':'opacity:.4'}">${ic}</button>`;
  const s=sheet('gm-pauseL','Paused',`<div style="display:flex;justify-content:center;gap:10px">${tg('music',I.music)}${tg('sound',I.sound)}${tg('vibe',I.vibe)}</div>
    <button class="gm-btn" id="gm-pr">${I.play.replace('<svg','<svg width="22" height="22"')} Resume</button>
    ${o.onRestart?`<button class="gm-btn sec" id="gm-prs">${I.retry.replace('<svg','<svg width="20" height="20"')} Restart</button>`:''}
    <button class="gm-btn sec" id="gm-ph">${I.home.replace('<svg','<svg width="20" height="20"')} Home</button>`,{onClose:()=>{if(!left)o.onResume()}});
  let left=false;
  s.L.querySelectorAll('.gm-icon[data-k]').forEach(b=>b.onclick=()=>{const k=b.dataset.k;S.set[k]=!S.set[k];save();b.style.opacity=S.set[k]?'':'.4';if(k==='music')applyMusic()});
  $('#gm-pr',s.L).onclick=()=>{ui.tap();s.close()};
  const rs=$('#gm-prs',s.L);if(rs)rs.onclick=()=>{ui.tap();left=true;s.close();o.onRestart()};
  $('#gm-ph',s.L).onclick=()=>{ui.tap();left=true;s.close();(o.onHome||showHome)()};
}

/* ---------- tutorial hand ---------- */
const HAND_SVG='<svg class="hand" viewBox="0 0 58 70"><path d="M22 4c3.6 0 6 2.4 6 6v20l2-.6c3-.8 5.6.6 6.4 3l.2.6 1.6-.4c3-.6 5.4 1 6 3.4l1.6-.2c3.2-.2 5.6 1.8 5.8 5l.4 10c.2 8-4.2 14.6-11.6 17.2-3 1-6 1.4-9.2 1.4h-3.6c-5.8 0-10.6-3-13.4-8L4.4 46.6c-1.4-2.8-.4-6 2.4-7.2 2.4-1 5-.2 6.4 1.8l2.8 4V10c0-3.6 2.4-6 6-6z" fill="#fff" stroke="#1a1240" stroke-width="3" stroke-linejoin="round"/><path d="M28 30v10M36.6 32.8V41M44 36.6V42" stroke="#1a1240" stroke-width="2.6" stroke-linecap="round"/></svg>';
let handEl=null,handAnim=null;
function hand(o){
  if(!handEl){handEl=h('div');handEl.id='gm-hand';document.body.appendChild(handEl)}
  handEl.hidden=false;if(handAnim){handAnim.cancel();handAnim=null}
  let html='';
  if(o.mode==='drag'||o.line){html+=`<svg class="line"><path d="M${o.x} ${o.y} L${o.x2} ${o.y2}"/></svg>`}
  if(o.mode==='tap')html+=`<div class="ring" style="left:${o.x}px;top:${o.y}px"></div>`;
  if(o.x!=null)html+=HAND_SVG;
  if(o.text){const below=o.tipAt==='bottom'||(o.tipAt!=='top'&&(o.y||0)<innerHeight*.45);html+=`<div class="tip" style="${below?'bottom:calc(24px + var(--gm-safe-b))':'top:calc(70px + var(--gm-safe-t))'}">${o.text}</div>`}
  handEl.innerHTML=html;
  const hd=$('.hand',handEl);if(!hd)return;
  if(o.mode==='drag'){hd.style.transform=`translate(${o.x}px,${o.y}px)`;handAnim=hd.animate([{transform:`translate(${o.x}px,${o.y}px)`,offset:0},{transform:`translate(${o.x}px,${o.y}px) scale(.9)`,offset:.15},{transform:`translate(${o.x2}px,${o.y2}px) scale(.9)`,offset:.75},{transform:`translate(${o.x2}px,${o.y2}px)`,offset:.85,opacity:1},{transform:`translate(${o.x2}px,${o.y2}px)`,offset:1,opacity:0}],{duration:1700,iterations:Infinity,easing:'ease-in-out'})}
  else{hd.style.setProperty('--hx',o.x+'px');hd.style.setProperty('--hy',o.y+'px');hd.classList.add('tap')}
}
function handHide(){if(handEl)handEl.hidden=true;if(handAnim){handAnim.cancel();handAnim=null}}

/* ---------- Android back button ---------- */
window.__back=function(){
  if($('#gm-intro'))return'ok';
  if($('#gm-adph'))return'ok';
  if(stack.length){stack[stack.length-1].back();return'ok'}
  if(mode==='game'){C.onBack&&C.onBack();return'ok'}
  return'home';
};

/* ---------- boot ---------- */
function init(cfg){
  C=cfg;KEY=cfg.id+'-gm';load();
  if(window.GMApp){S.set.reminder=GMApp.reminderOn();save()}
  if(!S.gift.next)S.gift.next=Date.now();
  buildHome();home.hidden=true;
  intro(()=>{if(!S.tut){mode='game';C.tutorial()}else showHome()});
}
function tutorialDone(){S.tut=true;save()}

window.GM={init,showHome,startGame,results,pause,toast,hand,handHide,rewarded,interstitial,tone,vibrate,ui,audio,
  coins,addCoins,spend,equipped,takeBoosters,setStars,stars:i=>S.stars[i]||0,dailyComplete,dailySeed,dayKey,tutorialDone,
  get store(){return S.game},save,best:(k,v)=>{if(v!=null&&v>(S.best[k]||0)){S.best[k]=v;save();return true}return v!=null?false:(S.best[k]||0)},
  get mode(){return mode},set mode(v){mode=v},openSettings,icons:I,hashStr,sheet,refreshHome};
})();
