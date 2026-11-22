import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xb6a8d8,fogColor:0xb6a8d8,fogNear:14,fogFar:34,sun:1.9,hemi:1.0,shadowSize:11});
E.ground(0x5d8a4a,60,80,0,0,-10);
// lanes
const lx=[-2.4,-1.2,0,1.2,2.4];
for(let i=0;i<5;i++)E.box(1.1,0.04,18,i%2?0x6f9d5a:0x7aab63,lx[i],0.03,-3);
E.box(7.6,0.05,1.6,0x8a7a6a,0,0.04,5.4);
// houses behind (far) and sides
const sub=['building-type-b','building-type-d','building-type-f','building-type-h','building-type-j','building-type-l'];
for(let i=0;i<5;i++)await E.obj('city-kit-suburban_20',sub[i],{x:-4.5+i*2.25,z:-13,len:2,ry:0});
for(let i=0;i<5;i++){await E.obj('city-kit-suburban_20',sub[(i+2)%6],{x:-5.6,z:-7+i*2.8,len:2.2,ry:Math.PI/2});await E.obj('city-kit-suburban_20',sub[(i+4)%6],{x:5.6,z:-7+i*2.8,len:2.2,ry:-Math.PI/2});}
// zombies marching down lanes
const zs=[[0,-9,0],[0,-6,1],[1,-8,0],[2,-5.5,0],[2,-9.5,1],[3,-7.5,0],[4,-4.5,0],[4,-8.3,0],[1,-3.4,0],[3,-2.5,0]];
const zt=['character-zombie'];
for(const[l,z,v] of zs)await E.obj('mini-characters','character-zombie',{x:lx[l],z,h:.95,ry:0,anim:'walk',t:v?0.15:0.5});
// defenders on bottom row
const df=[['character-soldier',0],['character-male-c',1],['character-soldier',2],['character-female-b',3],['character-raider',4]];
for(const[n,l] of df){await E.obj('mini-characters',n,{x:lx[l],z:2.5,h:.95,ry:Math.PI,anim:'idle',t:.4});
 await E.obj('blaster-kit_2.1','blaster-'+'abcdefghi'[l*2%9],{x:lx[l]+.26,y:.5,z:2.05,len:.5,ry:Math.PI});}
for(const l of[1,3])await E.obj('blaster-kit_2.1','crate-medium',{x:lx[l],z:1.4,len:.7});
// muzzle bullets
for(const[l,z] of[[0,1.4],[2,0.4],[2,-1.2],[4,1],[3,-0.6]])await E.obj('blaster-kit_2.1','bullet-foam',{x:lx[l],y:.7,z,h:.28,rx:Math.PI/2});
E.cam_([0,9.5,10.2],[0,0,-0.2],48);
E.label('-35',[0,1.4,-3],'font-size:30px;color:#ff6b6b');
const card=(t,c,p)=>`<div style="display:inline-block;width:96px;height:100px;margin:0 5px;border:5px solid #170F45;border-radius:18px;background:${c};text-align:center;font-size:15px;padding-top:30px;box-sizing:border-box">${t}<br><span style="color:#ffd84a">${p}</span></div>`;
E.hud(logo('ZOMBIE YARD MAYHEM')+pill('WAVE 4/10','left:14px;top:112px')+pill('⚙ 175','right:14px;top:112px;border-color:#7dd0ff')+
 `<div class="stroke" style="position:absolute;left:0;right:0;bottom:130px;text-align:center">${card('POP','#59c36a','50')}${card('RAPID','#ff9a1f','100')}${card('BOOM','#e0453a','150')}${card('WALL','#4b8bf5','25')}</div>`+
 tag('DEFEND THE YARD. <em>OUTSMART THE HORDE.</em>'));
await E.done();};
