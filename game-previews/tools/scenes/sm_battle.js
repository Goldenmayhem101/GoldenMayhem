import {makeEngine,THREE} from '/engine.js';import {inject,chip,coin,gem,T} from '/ui.js';
export default async()=>{inject();
const E=await makeEngine({sky:0xa9dcff,fogColor:0xcfeaff,fogNear:26,fogFar:55,sun:2.5,hemi:1.3,sunx:-6,suny:12,sunz:2,ground:0x7fbf6a});
const K='city-kit-suburban_20',M='mini-characters',B='blaster-kit_2.1';
E.ground(0x86c46c,60,120,0,0,-30);
// road
E.box(5.4,0.06,90,0x4c5068,0,0.03,-30);
E.box(.16,.07,90,0xf3f0e6,-2.55,.05,-30);E.box(.16,.07,90,0xf3f0e6,2.55,.05,-30);
for(let z=8;z>-50;z-=2.2)E.box(.12,.07,1.1,0xf5d142,0,.06,z);
E.box(1.4,.08,90,0xcfc7b5,-3.55,.04,-30);E.box(1.4,.08,90,0xcfc7b5,3.55,.04,-30);
// houses and trees
const bt='abcdefghijklmnopqrstu';
for(let i=0;i<10;i++){const z=6-i*4.2;
 await E.obj(K,'building-type-'+bt[(i*3)%21],{x:-6.2,z,len:3.3,ry:Math.PI/2});
 await E.obj(K,'building-type-'+bt[(i*3+7)%21],{x:6.2,z,len:3.3,ry:-Math.PI/2});
 if(i%2==0){await E.obj(K,'tree-large',{x:-4.5,z:z+2,h:2.1});await E.obj(K,'tree-small',{x:4.5,z:z-1,h:1.5});}}
// wrecked barrier at far end
// gates (translucent panels with frames)
const gate=(x,z,c,w=2.3)=>{
 const m=new THREE.Mesh(new THREE.BoxGeometry(w,1.35,.08),new THREE.MeshStandardMaterial({color:c,transparent:true,opacity:.62,emissive:c,emissiveIntensity:.55,roughness:.2}));
 m.position.set(x,.8,z);E.scene.add(m);
 E.box(.14,1.5,.14,0xffffff,x-w/2,.78,z,{emissive:c,ei:.4});E.box(.14,1.5,.14,0xffffff,x+w/2,.78,z,{emissive:c,ei:.4});
 E.box(w+.14,.14,.14,0xffffff,x,1.5,z,{emissive:c,ei:.4});};
gate(-1.3,-3.4,0x2f8cff);gate(1.3,-3.4,0xff3b3b);
E.label('+12',[-1.3,.85,-3.3],'font-size:62px;color:#fff');E.label('-5',[1.3,.85,-3.3],'font-size:62px;color:#fff');
// weapon crate & captive
await E.obj(B,'crate-wide',{x:-1.35,z:-7,len:1.3});
E.label('RIFLE +1',[-1.35,1.3,-7],'font-size:30px;color:#ffd84a');
const jar=new THREE.Mesh(new THREE.BoxGeometry(1.3,1.5,1.3),new THREE.MeshStandardMaterial({color:0x9fe9ff,transparent:true,opacity:.35,roughness:.1}));jar.position.set(1.4,.78,-7.4);E.scene.add(jar);
await E.obj('cube-pets_1.0','animal-dog',{x:1.4,y:.05,z:-7.4,h:.9,ry:0});
E.label('HELP!',[1.4,2.0,-7.4],'font-size:32px;color:#ffe45a');
// zombie horde
let n=0;for(let r=0;r<7;r++)for(let c=0;c<7;c++){if((r*7+c)%5==3)continue;
 const x=(c-3)*.62+Math.sin(r*3+c)*.12,z=-11.6-r*.85;
 await E.obj(M,'character-zombie',{x,z,h:.85,ry:Math.sin(c+r)*.25,anim:'walk',t:((r+c)%5)*.18});n++;}
E.label('142',[0,1.9,-10.8],'font-size:44px;color:#ff5a5a');
// boss
await E.obj(M,'character-zombie',{x:0,z:-19.5,h:4.6,ry:0,anim:'idle',t:.5,tint:0xd9b7ff});
E.sphere(.01,0,0,0,0);
// squad
const names=['character-soldier','character-male-a','character-female-a','character-male-c','character-raider','character-female-c','character-male-e','character-male-f','character-female-e','character-male-b','character-soldier','character-female-b'];
let k=0;const ranks=[4,5,6,5];
for(let r=0;r<ranks.length;r++){for(let c=0;c<ranks[r];c++){
 const x=(c-(ranks[r]-1)/2)*.52+(r%2?.04:-.04),z=1.0+r*.6;
 await E.obj(M,names[k++%names.length],{x,z,h:.72,ry:Math.PI,anim:'holding-both-shoot',t:(k%4)*.12});
 if(r<2)await E.obj(B,'blaster-'+'abcdefghijklmnopqr'[(k*5)%18],{x:x+.12,y:.38,z:z-.42,len:.46,ry:Math.PI});}}
// tracers + muzzle flashes
for(let i=0;i<14;i++){const x=(i%7-3)*.46,z=-.2-Math.floor(i/7)*3.4-(i*.37)%1.2;
 E.box(.07,.07,.7,0xfff08a,x,.5,z,{emissive:0xffe45a,ei:1.4,rough:.2});}
// aura under squad
const aura=new THREE.Mesh(new THREE.CircleGeometry(2.1,40),new THREE.MeshBasicMaterial({color:0x4aa8ff,transparent:true,opacity:.28}));aura.rotation.x=-Math.PI/2;aura.position.set(0,.08,2.6);E.scene.add(aura);
E.cam_([0,10.4,13.2],[0,0,-5.4],52);
// labels: counts, damage numbers
E.raw(`<div class="plate blue t" style="position:relative;width:96px;height:44px;border-radius:22px;font-size:30px;line-height:36px;text-align:center">24</div>`,[0,1.4,.2]);
E.label('-48',[-1.9,1.0,-11.2],'font-size:34px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-8deg)');
E.label('-96',[1.9,1.4,-12.6],'font-size:40px;color:#ffd84a;transform:translate(-50%,-50%) rotate(6deg)');
E.label('CRIT!',[.2,2.2,-12.5],'font-size:26px;color:#ff9a1f');
// HUD
E.hud(`
${chip(coin(),'1,280','left:12px;top:14px;min-width:132px')}
${chip(gem(),'45','left:152px;top:14px;min-width:96px')}
<div class="plate" style="left:430px;top:12px;width:98px;height:46px;border-radius:23px"></div>
${T('LV 12','left:446px;top:16px;font-size:26px')}
<div class="ab" style="left:50%;top:70px;transform:translateX(-50%);text-align:center">
 <div class="t" style="font-size:20px;color:#ffe45a">ZOMBIE TOWN</div>
 <div style="display:flex;gap:6px;margin-top:3px;justify-content:center">${[1,1,1,0,0].map((o,i)=>`<div style="width:46px;height:14px;border-radius:8px;border:3px solid #170F45;background:${o?'linear-gradient(#ffe36a,#ffa51f)':'#3a2d86'}"></div>`).join('')}</div></div>
<div class="ab" style="left:50%;top:112px;transform:translateX(-50%);width:300px"><div class="t" style="text-align:center;font-size:21px;margin-bottom:2px">ZOMBIE BRUTE</div><div class="hp" style="position:relative;width:300px"><i style="width:68%"></i><b>12.4K</b></div></div>
<div class="ab" style="left:20px;right:20px;bottom:142px"><div class="hp" style="position:relative;height:30px;width:100%;background:#2a1a68"><i style="width:72%;background:linear-gradient(#ffb0f0,#c63cff)"></i><b style="line-height:22px;font-size:19px">MAYHEM METER</b></div></div>
<div class="skill red" style="left:56px;bottom:36px">💥<small class="t">GRENADE</small></div>
<div class="skill gold glow" style="left:228px;bottom:30px;width:92px;height:92px">⚡<small class="t">HERO: RICO</small></div>
<div class="skill blue" style="right:56px;bottom:36px">❄<small class="t" style="color:#bfe9ff">FREEZE 8s</small></div>
`);
await E.done();};
