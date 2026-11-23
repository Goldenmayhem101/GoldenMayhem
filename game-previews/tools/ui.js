// Squad Mayhem UI kit: chunky game UI in HTML/CSS over the 3D view
export const css=`
.t{font-family:'Lilita';color:#fff;-webkit-text-stroke:5px #170F45;paint-order:stroke fill;text-shadow:0 3px 0 #170F45;letter-spacing:.5px}
.ab{position:absolute}
.coin{display:inline-block;width:26px;height:26px;border-radius:50%;background:radial-gradient(circle at 35% 30%,#fff3a6,#ffc21f 55%,#d98a00);border:3px solid #170F45;vertical-align:middle;box-sizing:border-box;box-shadow:inset 0 -3px 0 rgba(0,0,0,.18)}
.gem{display:inline-block;width:24px;height:24px;background:linear-gradient(135deg,#9bf0ff,#2aa7ff 60%,#1566d6);transform:rotate(45deg) scale(.8);border:3px solid #170F45;border-radius:5px;vertical-align:middle;box-sizing:border-box}
.chip{position:absolute;height:42px;min-width:100px;border-radius:21px;background:linear-gradient(#3a2d86,#251b66);border:4px solid #170F45;box-shadow:0 3px 0 rgba(0,0,0,.25),inset 0 3px 0 rgba(255,255,255,.18);display:flex;align-items:center;justify-content:flex-end;padding:0 14px 0 44px;font-size:24px;box-sizing:border-box}
.chip .ic{position:absolute;left:-6px;top:-6px}
.plate{position:absolute;border-radius:22px;background:linear-gradient(#4a3aa8,#2c2078);border:5px solid #170F45;box-shadow:0 5px 0 #170F45,inset 0 4px 0 rgba(255,255,255,.2);box-sizing:border-box}
.gold{background:linear-gradient(#ffe36a,#ffb21f 55%,#e48a00)}
.green{background:linear-gradient(#8cf26a,#34c23c 55%,#1f9a32)}
.red{background:linear-gradient(#ff8a7a,#ee3f3f 55%,#c11f2e)}
.blue{background:linear-gradient(#8fd6ff,#3b9bff 55%,#2467d8)}
.purple{background:linear-gradient(#d9a2ff,#9a4cf0 55%,#6a28c4)}
.bigbtn{position:absolute;border-radius:26px;border:5px solid #170F45;box-shadow:0 7px 0 #170F45,inset 0 5px 0 rgba(255,255,255,.4);display:flex;align-items:center;justify-content:center;text-align:center;box-sizing:border-box}
.hp{position:absolute;height:26px;border-radius:14px;border:4px solid #170F45;background:#3a1020;overflow:hidden;box-sizing:border-box}
.hp i{display:block;height:100%;background:linear-gradient(#ff8a7a,#e83a3a)}
.hp b{position:absolute;inset:0;text-align:center;line-height:18px;font-weight:400;font-size:17px;-webkit-text-stroke:3px #170F45;paint-order:stroke fill;color:#fff}
.skill{position:absolute;width:84px;height:84px;border-radius:50%;border:5px solid #170F45;box-shadow:0 5px 0 #170F45,inset 0 4px 0 rgba(255,255,255,.4);display:flex;align-items:center;justify-content:center;font-size:36px;box-sizing:border-box}
.skill small{position:absolute;bottom:-14px;left:50%;transform:translateX(-50%);font-size:15px;white-space:nowrap}
.star{color:#ffd84a;-webkit-text-stroke:2px #170F45;paint-order:stroke fill;font-size:16px;letter-spacing:-1px}
.glow{box-shadow:0 0 28px 8px rgba(255,220,90,.85)}
`;
export const inject=()=>{const s=document.createElement('style');s.textContent=css;document.head.appendChild(s);};
export const coin=()=>'<span class="coin"></span>';
export const gem=()=>'<span class="gem"></span>';
export const chip=(icon,txt,css)=>`<div class="chip t" style="${css}"><span class="ic">${icon}</span>${txt}</div>`;
export const T=(txt,css)=>`<div class="ab t" style="${css}">${txt}</div>`;
