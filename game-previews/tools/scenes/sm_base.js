import {makeEngine,THREE} from '/engine.js';import {inject,chip,coin,gem,T} from '/ui.js';
export default async()=>{inject();
const E=await makeEngine({sky:0x8fe0ff,fogColor:0xbfefff,fogNear:30,fogFar:70,sun:2.6,hemi:1.35,sunx:-7,suny:13,sunz:4,ground:0x3fb7d8});
const P='pirate-kit',M='mini-characters',B='blaster-kit_2.1',I='city-kit-industrial_2.0';
E.ground(0x2bb3dc,120,140,-.2,0,-20);
// island: sand disc + grass disc
const disc=(r,c,y)=>{const m=new THREE.Mesh(new THREE.CylinderGeometry(r,r*1.04,.5,48),new THREE.MeshStandardMaterial({color:c,roughness:1}));m.position.set(0,y,-1);m.receiveShadow=true;E.scene.add(m);};
disc(9.6,0xf0d58c,-.15);disc(8.5,0x7fcf5f,-.06);
// merge board plate
E.box(7.2,.25,6.4,0x6b4a2e,0,.06,1.35);E.box(6.9,.3,6.1,0x2a2060,0,.1,1.35);
// merge grid 5x4
const cols=5,rows=4,ts=1.28,x0=-(cols-1)*ts/2,z0=-.3;
const tiles={};
for(let r=0;r<rows;r++)for(let c=0;c<cols;c++){const x=x0+c*ts,z=z0+r*ts;E.box(1.18,.1,1.18,(r+c)%2?0x4a3aa8:0x5a49bd,x,.27,z,{rough:.5});tiles[r+','+c]=[x,z];}
const ring=(x,z,col,r=.55)=>{const m=new THREE.Mesh(new THREE.CylinderGeometry(r,r,.05,32),new THREE.MeshStandardMaterial({color:col,emissive:col,emissiveIntensity:.35,roughness:.3}));m.position.set(x,.35,z);E.scene.add(m);};
const tier=[null,0xcd7f32,0xdfe6f0,0xffc21f,0xff4fd8];
const place=async(r,c,kit,name,h,lv,o={})=>{const[x,z]=tiles[r+','+c];ring(x,z,tier[lv]);
 await E.obj(kit,name,{x,y:.38,z:z+.02,h,ry:o.ry??0,anim:o.anim,t:o.t||.2});
 E.label('★'.repeat(lv),[x,.38+h+.28,z],'font-size:15px;color:#ffd84a;-webkit-text-stroke:3px #170F45;');};
const sol=['character-male-a','character-female-a','character-male-c','character-female-c','character-male-e'];
// level 1 troops
await place(0,0,M,sol[0],.62,1,{anim:'idle'});await place(0,2,M,sol[1],.62,1,{anim:'idle'});await place(0,4,M,sol[2],.62,1,{anim:'idle'});
await place(1,1,M,sol[3],.62,1,{anim:'idle'});await place(3,0,M,sol[4],.62,1,{anim:'idle'});
// level 2
await place(1,3,M,'character-soldier',.78,2,{anim:'holding-both-shoot'});await place(2,0,M,'character-soldier',.78,2,{anim:'holding-both-shoot'});
await place(3,3,M,'character-female-d',.78,2,{anim:'idle'});
// level 3
await place(2,2,M,'character-raider',.95,3,{anim:'holding-both-shoot'});
// level 4 hero tier
await place(1,0,M,'character-knight',1.1,4,{anim:'idle'});
// weapons
await place(0,1,B,'blaster-b',.34,1);await place(2,4,B,'blaster-g',.4,2);await place(3,1,B,'blaster-g',.4,2);
// vehicle + animal ally + crate
await place(3,2,'car-kit','police',.55,2);await place(2,3,'cube-pets_1.0','animal-fox',.62,1);await place(1,4,'prototype-kit','crate-color',.6,1);
await place(3,4,M,'character-male-e',.62,1,{anim:'idle'});await place(2,1,M,'character-female-b',.62,1,{anim:'idle'});
// merge highlight: two identical L2 soldiers at (3,3)? make pair (1,3),(2,0) glow via arrows -> highlight (1,3)&(3,3)? keep simple: glow around (2,0)-(3,0)... use labels
const[ax,az]=tiles['2,0'],[bx,bz]=tiles['1,3'];
const pulse=(x,z)=>{const m=new THREE.Mesh(new THREE.RingGeometry(.58,.72,40),new THREE.MeshBasicMaterial({color:0xffffff,transparent:true,opacity:.9,side:THREE.DoubleSide}));m.rotation.x=-Math.PI/2;m.position.set(x,.4,z);E.scene.add(m);};
pulse(...tiles['1,3']);pulse(...tiles['0,2']);
// base buildings behind
await E.obj(I,'building-a',{x:-4.9,z:-3.0,len:2.8,ry:.4});await E.obj(I,'building-d',{x:4.8,z:-3.2,len:3.0,ry:-.4});
await E.obj(P,'tower-complete-large',{x:0,z:-4.2,h:5.4});
await E.obj(I,'windmill',{x:-2.6,z:-6.4,h:4.4});await E.obj(I,'water-tower',{x:2.8,z:-6.2,h:4.2});
await E.obj(P,'flag-pennant',{x:1.9,z:-2.2,h:1.8});
await E.obj(I,'shipping-container-a',{x:-7.4,z:-1.2,len:2.0,ry:.3});await E.obj(I,'shipping-container-c',{x:7.5,z:-1.0,len:2.0,ry:-.4});
for(const[x,z,r] of[[-7.2,1,1],[7.4,2,2],[-6.6,-4,3],[6.8,-5.5,4]])await E.obj(P,'palm-detailed-bend',{x,z,h:3.2,ry:r});
await E.obj(P,'ship-pirate-large',{x:-15,z:-9,len:9,ry:.6});await E.obj(P,'boat-row-large',{x:12,z:5,len:4,ry:1});
E.cam_([0,16.5,14.5],[0,0,-3.4],48);
// bubble over the merge pair
E.raw(`<div class="t" style="font-size:30px;color:#6dff8a;transform:rotate(-4deg)">MERGE!</div>`,[0.9,2.3,tiles['1,3'][1]]);
// HUD
E.hud(`
${chip(coin(),'1,280','left:12px;top:14px;min-width:132px')}
${chip(gem(),'45','left:152px;top:14px;min-width:96px')}
<div class="plate" style="left:430px;top:10px;width:98px;height:50px;border-radius:25px"></div>${T('⚙','left:462px;top:12px;font-size:30px')}
<div class="ab t" style="left:50%;top:70px;transform:translateX(-50%);font-size:34px;white-space:nowrap">MAYHEM ISLAND</div>
<div class="plate" style="left:14px;top:118px;width:176px;height:80px;border-radius:18px;padding:6px 10px"><div class="t" style="font-size:16px;color:#ffe45a">QUEST</div><div class="t" style="font-size:15px;line-height:17px">Merge 3 troops<br>to Lv 3  <span style="color:#6dff8a">2/3</span></div></div>
<div class="plate" style="left:350px;top:118px;width:176px;height:80px;border-radius:18px;padding:6px 10px"><div class="t" style="font-size:16px;color:#ffe45a">TOWER LV 4</div><div class="hp" style="position:relative;width:150px;height:22px;margin-top:6px;background:#1c1550"><i style="width:60%;background:linear-gradient(#8cf26a,#34c23c)"></i><b style="line-height:14px;font-size:14px">UPGRADE</b></div></div>
<div class="bigbtn green" style="left:30px;bottom:112px;width:160px;height:74px"><div><div class="t" style="font-size:26px">+ TROOP</div><div class="t" style="font-size:15px">FREE IN 0:12</div></div></div>
<div class="bigbtn purple" style="right:30px;bottom:112px;width:160px;height:74px"><div class="t" style="font-size:24px">AUTO MERGE<br><span style="font-size:14px">▶ WATCH AD</span></div></div>
<div class="plate" style="left:0;right:0;bottom:0;height:104px;border-radius:0;border-width:5px 0 0 0;background:linear-gradient(#352a8a,#1f1660)"></div>
${[['🛒','SHOP'],['🦸','HEROES'],['🏝','BASE'],['📜','QUESTS'],['🏆','EVENTS']].map((n,i)=>i==2?'':`<div class="ab" style="left:${i<2?16+i*94:(i>2?346+(i-3)*92:0)}px;bottom:14px;width:84px;text-align:center"><div style="font-size:34px;line-height:40px">${n[0]}</div><div class="t" style="font-size:15px">${n[1]}</div></div>`).join('')}
<div class="bigbtn red" style="left:206px;bottom:30px;width:128px;height:104px;border-radius:30px"><div class="t" style="font-size:30px;line-height:30px">⚔<br>BATTLE</div></div>
`);
await E.done();};
