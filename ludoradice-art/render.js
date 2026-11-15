const {chromium}=require('playwright');const fs=require('fs');
(async()=>{const b=await chromium.launch();const p=await b.newPage();
const F='/home/claude/gmkit/fonts/';
const b64=f=>fs.readFileSync(F+f).toString('base64');const css=`@font-face{font-family:'Baloo 2';font-weight:800;src:url(data:font/woff;base64,${b64('baloo2.woff')})}@font-face{font-family:Nunito;font-weight:700 800;src:url(data:font/woff;base64,${b64('nunito.woff')})}`;
async function r(svg,w,h,out,omit){const s=fs.readFileSync(svg,'utf8');
await p.setViewportSize({width:w,height:h});
await p.setContent(`<style>${css}html,body{margin:0;background:${omit?'transparent':'#000'}}svg{width:${w}px;height:${h}px;display:block}</style>${s}`);
await p.evaluate(()=>document.fonts.ready);await p.waitForTimeout(300);
await p.screenshot({path:out,omitBackground:!!omit});}
await r('icon.svg',512,512,'icon-512.png');
await r('feature.svg',1024,500,'feature-graphic-1024x500.png');
await r('bg.svg',432,432,'bg432.png');
await r('fg.svg',432,432,'fg432.png',true);
for(const [n,s] of [['mdpi',48],['hdpi',72],['xhdpi',96],['xxhdpi',144],['xxxhdpi',192]]) await r('icon.svg',s,s,`ic_${n}.png`);
await b.close();})();
