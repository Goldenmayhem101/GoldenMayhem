import {makeEngine,THREE} from '/engine.js';import {inject,chip,coin,gem,T} from '/ui.js';
export default async()=>{inject();
const E=await makeEngine({sky:0xf3a56e,fogColor:0xf0b184,fogNear:22,fogFar:52,sun:3.0,hemi:1.35,sunx:-9,suny:7,sunz:-6,ground:0x6a5a7a,bloom:{s:.55,r:.7,t:.8}});
const K='city-kit-commercial_2.1',Z='mixamo/zombie_packs/',G='mixamo/guns/';
E.r.toneMappingExposure=1.3;E.scene.children.find(o=>o.isHemisphereLight).color.set(0xffd9b8);
// road
E.ground(0x4a4658,70,140,0,0,-34);
E.box(5.4,0.06,100,0x3a3748,0,0.03,-34);
E.box(.14,.07,100,0xf1e7cf,-2.55,.05,-34);E.box(.14,.07,100,0xf1e7cf,2.55,.05,-34);
for(let z=8;z>-60;z-=2.2)E.box(.12,.07,1.1,0xf5d142,0,.06,z);
E.box(1.5,.12,100,0x8b8296,-3.6,.06,-34);E.box(1.5,.12,100,0x8b8296,3.6,.06,-34);
// city blocks
const names=['building-a','building-b','building-c','building-d','building-e','building-f','building-g','building-h','building-i','building-j','building-k','building-l'];
for(let i=0;i<9;i++){const z=7-i*4.4;
 await E.obj(K,names[(i*5)%12],{x:-6.4,z,len:3.8,ry:Math.PI/2});await E.obj(K,names[(i*5+4)%12],{x:6.4,z,len:3.8,ry:-Math.PI/2});}
// wrecks / barricades
await E.obj('car-kit','police',{x:-2.2,z:-10.5,len:2.0,ry:.5});await E.obj('car-kit','taxi',{x:2.3,z:-15.5,len:2.0,ry:-.4});await E.obj('car-kit','ambulance',{x:-2.0,z:-22,len:2.3,ry:.3});
// gates
const gate=(x,z,c,w=2.3)=>{const m=new THREE.Mesh(new THREE.BoxGeometry(w,1.5,.08),new THREE.MeshStandardMaterial({color:c,transparent:true,opacity:.55,emissive:c,emissiveIntensity:1.3,roughness:.2}));m.position.set(x,.85,z);E.scene.add(m);
 for(const dx of[-w/2,w/2])E.box(.16,1.7,.16,0xffffff,x+dx,.88,z,{emissive:c,ei:1.2});E.box(w+.16,.16,.16,0xffffff,x,1.7,z,{emissive:c,ei:1.2});};
gate(-1.3,-6.4,0x2f8cff);gate(1.3,-6.4,0xff3b3b);
E.label('+12',[-1.3,.9,-6.3],'font-size:60px');E.label('-5',[1.3,.9,-6.3],'font-size:60px');
// zombies
const zs=[['Scary_Zombie_Pack_1/copzombie_l_actisdato.fbx'],['Not_So_Scary_Zombie_Pack_4/Zombiegirl W Kurniawan.fbx'],['Not_So_Scary_Zombie_Pack_5/Warzombie F Pedroso.fbx'],['Not_So_Scary_Zombie_Pack_6/Whiteclown N Hallin.fbx'],['Not_So_Scary_Zombie_Pack_7/Skeletonzombie T Avelange.fbx']];
const walk=Z+'Not_So_Scary_Zombie_Pack_4/walking.fbx',run=Z+'Not_So_Scary_Zombie_Pack_4/zombie running.fbx';
let n=0;for(let r=0;r<5;r++)for(let c=0;c<6;c++){if((r*6+c)%4==3)continue;
 const x=(c-2.5)*.82+Math.sin(r*5+c)*.2,z=-9.2-r*1.15+Math.cos(c*2)*.25;
 await E.fbx(Z+zs[(r+c)%5][0],(r+c)%3?walk:run,{x,z,h:1.5+((r*c)%3)*.06,ry:Math.PI+Math.sin(c+r)*.3,t:((r*3+c)%7)*.13+.1});n++;}
// boss (clawed war zombie, huge)
await E.fbx(Z+'Not_So_Scary_Zombie_Pack_5/Warzombie F Pedroso.fbx',Z+'Not_So_Scary_Zombie_Pack_4/zombie scream.fbx'.replace('Not_So_Scary_Zombie_Pack_4','Scary_Zombie_Pack_2'),{x:0,z:-20.5,h:5.2,ry:Math.PI,t:.8,tint:0xffc2b0});
E.sphere(.01,0,0,0,0);
// squad: X Bot soldiers with hard hats
const cols=[0x3a8cff,0x3a8cff,0x2fd0b0,0x3a8cff,0xffb02e];const run8=G+'Pro_Rifle_Pack/run forward.fbx';
const gun=await E.loadF('weapons/ultimate-guns/Assault Rifle/AssaultRifle_4.fbx');
let k=0;const ranks=[3,4,4,3];
for(let r=0;r<ranks.length;r++)for(let c=0;c<ranks[r];c++){
 const x=(c-(ranks[r]-1)/2)*.74+(r%2?.05:-.05),z=-3.0+r*.85;
 const s=await E.fbx(G+'Pro_Rifle_Pack/X Bot.fbx',G+'Pro_Rifle_Pack/idle aiming.fbx',{x,z,h:1.55,ry:0,t:(k++%5)*.12+.05,tint:cols[(r*3+c)%5]});
 if(r<2){const gg=gun.clone();const bb=new THREE.Box3().setFromObject(gg);const sz=bb.getSize(new THREE.Vector3());const L=Math.max(sz.x,sz.y,sz.z);gg.scale.setScalar(.8/L);
  gg.traverse(m=>{if(m.isMesh){m.castShadow=true;}});const wrap=new THREE.Group();wrap.add(gg);wrap.position.set(x+.12,1.05,z-.35);wrap.rotation.y=Math.PI;E.scene.add(wrap);}
 await E.obj('prototype-kit','hat-hard',{x,y:1.4,z:z+.0,len:.24,ry:0,tint:cols[(r*3+c)%5]===0xffb02e?0xffffff:0xffe14a});}
// tracers
for(let i=0;i<16;i++){const x=(i%8-3.5)*.5,z=-4.2-Math.floor(i/8)*2.4-(i*.41)%1.3;E.box(.07,.07,.8,0xfff08a,x,.8,z,{emissive:0xffe45a,ei:2.2,rough:.2});}
const aura=new THREE.Mesh(new THREE.CircleGeometry(2.4,40),new THREE.MeshBasicMaterial({color:0x4aa8ff,transparent:true,opacity:.24}));aura.rotation.x=-Math.PI/2;aura.position.set(0,.08,-1.6);E.scene.add(aura);
E.cam_([0,8.6,9.4],[0,.4,-6.6],52);
E.raw(`<div class="plate blue t" style="position:relative;width:96px;height:44px;border-radius:22px;font-size:30px;line-height:36px;text-align:center">19</div>`,[0,.5,.9]);
E.label('-96',[-1.7,1.6,-9.6],'font-size:38px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-8deg)');
E.label('CRIT! -240',[1.6,2.0,-11.2],'font-size:30px;color:#ff9a1f;transform:translate(-50%,-50%) rotate(6deg)');
E.label('142',[0,2.1,-9.0],'font-size:40px;color:#ff5a5a');
E.hud(`
${chip(coin(),'1,280','left:12px;top:14px;min-width:132px')}
${chip(gem(),'45','left:152px;top:14px;min-width:96px')}
<div class="plate" style="left:430px;top:12px;width:98px;height:46px;border-radius:23px"></div>${T('LV 12','left:446px;top:16px;font-size:26px')}
<div class="ab" style="left:50%;top:70px;transform:translateX(-50%);text-align:center"><div class="t" style="font-size:20px;color:#ffe45a">ZOMBIE TOWN</div>
 <div style="display:flex;gap:6px;margin-top:3px;justify-content:center">${[1,1,1,0,0].map(o=>`<div style="width:46px;height:14px;border-radius:8px;border:3px solid #170F45;background:${o?'linear-gradient(#ffe36a,#ffa51f)':'#3a2d86'}"></div>`).join('')}</div></div>
<div class="ab" style="left:50%;top:112px;transform:translateX(-50%);width:300px"><div class="t" style="text-align:center;font-size:21px;margin-bottom:2px">WAR BRUTE</div><div class="hp" style="position:relative;width:300px"><i style="width:68%"></i><b>12.4K</b></div></div>
<div class="ab" style="left:20px;right:20px;bottom:142px"><div class="hp" style="position:relative;height:30px;width:100%;background:#2a1a68"><i style="width:72%;background:linear-gradient(#ffb0f0,#c63cff)"></i><b style="line-height:22px;font-size:19px">MAYHEM METER</b></div></div>
<div class="skill red" style="left:56px;bottom:36px">💥<small class="t">GRENADE</small></div>
<div class="skill gold glow" style="left:228px;bottom:30px;width:92px;height:92px">⚡<small class="t">HERO: RICO</small></div>
<div class="skill blue" style="right:56px;bottom:36px">❄<small class="t" style="color:#bfe9ff">FREEZE 8s</small></div>
`);
await E.done();};
