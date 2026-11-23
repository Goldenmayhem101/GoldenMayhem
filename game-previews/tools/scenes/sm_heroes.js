import {makeEngine,THREE} from '/engine.js';import {inject,chip,coin,gem,T} from '/ui.js';
export default async()=>{inject();
const E=await makeEngine({sky:0x5b34c8,fog:false,sun:2.2,hemi:1.5,sunx:-4,suny:9,sunz:10});
const M='mini-characters',C='cube-pets_1.0';
E.cam_([0,1.6,15],[0,1.6,0],32);
const mat=(c,o=.35)=>new THREE.MeshBasicMaterial({color:c,transparent:true,opacity:o,depthWrite:false});
// backdrop glow + rays
const g=new THREE.Mesh(new THREE.CircleGeometry(4.4,48),mat(0xffd86a,.42));g.position.set(0,2.8,-3);E.scene.add(g);
const g2=new THREE.Mesh(new THREE.CircleGeometry(2.8,48),mat(0xfff3b0,.5));g2.position.set(0,2.8,-2.9);E.scene.add(g2);
for(let i=0;i<10;i++){const r=new THREE.Mesh(new THREE.PlaneGeometry(.55,9),mat(0xffe27a,.13));r.position.set(0,2.8,-3.2);r.rotation.z=i*Math.PI/10;E.scene.add(r);}
// podium
const pod=new THREE.Mesh(new THREE.CylinderGeometry(1.45,1.7,.3,40),new THREE.MeshStandardMaterial({color:0xffc21f,metalness:.4,roughness:.3,emissive:0xff9a00,emissiveIntensity:.25}));pod.position.set(0,2.2,0);E.scene.add(pod);
const pod2=new THREE.Mesh(new THREE.CylinderGeometry(1.2,1.2,.08,40),new THREE.MeshStandardMaterial({color:0x4a2bb0,roughness:.5}));pod2.position.set(0,2.38,0);E.scene.add(pod2);
// hero
await E.obj(M,'character-soldier',{x:0,y:2.42,z:0,h:2.25,ry:.35,anim:'holding-both',t:.3});
// sparkles
let s=3;const rr=()=>(s=(s*16807)%2147483647)/2147483647;
for(let i=0;i<26;i++)E.sphere(.035+rr()*.05,0xfff6b8,(rr()-.5)*5,1.8+rr()*4.2,(rr()-.5)*2,{emissive:0xffe27a,ei:2,noshadow:true});
// roster slots
const xs=[-1.93,-.96,0,.96,1.93];
const slot=(x,c)=>{E.box(.84,.12,.84,c,x,-1.4,0,{rough:.5});};
xs.forEach((x,i)=>slot(x,i==2?0xffc21f:0x3a2a96));
await E.obj(M,'character-female-c',{x:xs[0],y:-1.32,z:0,h:.95,ry:.2,anim:'idle'});
await E.obj(M,'character-raider',{x:xs[1],y:-1.32,z:0,h:.95,ry:.1,anim:'idle'});
await E.obj(M,'character-soldier',{x:xs[2],y:-1.32,z:0,h:1.0,ry:.2,anim:'holding-both-shoot',t:.1});
await E.obj(C,'animal-fox',{x:xs[3],y:-1.32,z:0,h:.8,ry:.2});
await E.obj(M,'character-knight',{x:xs[4],y:-1.32,z:0,h:.95,ry:-.1,tint:0x222222});
E.cam_([0,1.6,15],[0,1.6,0],32);
const bar=(label,pct,c)=>`<div style="display:flex;align-items:center;margin:5px 0"><div class="t" style="width:74px;font-size:17px">${label}</div><div class="hp" style="position:relative;width:150px;height:18px;border-width:3px;background:#1c1550"><i style="width:${pct}%;background:${c}"></i></div></div>`;
E.hud(`
<div class="plate" style="left:12px;top:12px;width:52px;height:46px;border-radius:23px"></div>${T('◀','left:24px;top:14px;font-size:26px')}
${T('HEROES','left:50%;top:14px;transform:translateX(-50%);font-size:36px')}
${chip(coin(),'1,280','right:12px;top:14px;min-width:132px')}
<div class="ab" style="left:50%;top:74px;transform:translateX(-50%);text-align:center"><div class="t" style="font-size:19px;color:#ffe45a;letter-spacing:2px">LEGENDARY</div><div class="star" style="font-size:26px;margin-top:-2px">★★★★☆</div></div>
<div class="plate gold" style="left:70px;right:70px;top:412px;height:76px;border-radius:20px;text-align:center"><div class="t" style="font-size:36px;line-height:42px;margin-top:2px">SGT. RICO</div><div class="t" style="font-size:16px;color:#fff6c0;margin-top:-2px">ROCKET SERGEANT  ·  LV 18</div></div>
<div class="plate" style="left:20px;right:20px;top:500px;height:150px;border-radius:22px;padding:12px 16px">
 <div style="display:flex;justify-content:space-between">
  <div>${bar('ATTACK',82,'linear-gradient(#ff9a8a,#ee3f3f)')}${bar('HP',64,'linear-gradient(#8cf26a,#34c23c)')}${bar('SPEED',48,'linear-gradient(#8fd6ff,#3b9bff)')}</div>
  <div style="width:204px"><div class="skill gold" style="position:relative;width:62px;height:62px;font-size:28px;float:left;margin-right:10px">⚡</div><div class="t" style="font-size:19px;color:#ffe45a;line-height:20px">OVERDRIVE</div><div class="t" style="font-size:14px;line-height:15px;margin-top:2px;-webkit-text-stroke:3px #170F45">Squad fires twice as fast for 6 seconds.</div></div>
 </div>
 <div class="t" style="font-size:15px;margin-top:6px;color:#bfe9ff">AURA: +10% squad damage for every hero</div>
</div>
<div class="ab t" style="left:20px;top:658px;font-size:19px;color:#ffe45a">YOUR SQUAD</div>
<div class="ab t" style="right:20px;top:660px;font-size:15px;color:#bfe9ff">EARN HEROES BY PLAYING</div>
${['NOVA','BRUTE','RICO','PIP','???'].map((n,i)=>`<div class="ab t" style="left:${54+i*108-50}px;width:100px;text-align:center;top:${i==4?'810':'812'}px;font-size:16px;${i==2?'color:#ffe45a':''}">${n}</div>`).join('')}
<div class="ab t" style="left:${54+4*108-50}px;width:100px;text-align:center;top:752px;font-size:30px">🔒</div>
<div class="ab t" style="left:${54+3*108-50}px;width:100px;text-align:center;top:716px;font-size:13px;color:#8cf26a">ANIMAL ALLY</div>
<div class="bigbtn gold" style="left:24px;bottom:22px;width:300px;height:84px;flex-direction:column"><div class="t" style="font-size:32px">UPGRADE</div><div class="t" style="font-size:17px">${'12/20 shards  ·  '}<span style="color:#fff">800</span> ${coin()}</div></div>
<div class="bigbtn purple" style="right:24px;bottom:22px;width:170px;height:84px"><div class="t" style="font-size:26px">SET<br>ACTIVE</div></div>
`);
await E.done();};
