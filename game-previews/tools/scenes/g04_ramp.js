import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0x7fd0ff,fogNear:20,fogFar:55,suny:16});
E.ground(0xf0d089,80,100,0,0,-12);
// track pieces along -z: start straight, ramp up, gap, landing
const T=(n,z,o={})=>E.obj('toy-car-kit',n,Object.assign({z,x:0,ry:0},o));
const trk='track-road-narrow-straight';
for(const z of[8,4])await T(trk,z,{len:4.4});
const r=await E.obj('toy-car-kit','track-road-narrow-straight-hill-beginning',{z:0,x:0,s:1}).catch(e=>null);
await E.obj('racing-kit','roadRampLong',{x:0,z:-3.2,len:5});
// landing platform far
await E.obj('racing-kit','roadStraightLong',{x:0,y:0,z:-15,len:6,ry:0}).catch(()=>{});
for(const z of[-12,-16,-20])await T(trk,z,{len:4.4});
await E.obj('toy-car-kit','gate-finish',{x:0,z:-22,len:3.4});
// coins in arc
for(let i=0;i<7;i++){const t=i/6;await E.obj('toy-car-kit','item-coin-gold',{x:0,y:2.2+Math.sin(t*Math.PI)*1.6,z:-4.5-t*7,h:.45,ry:i});}
// car mid-air flipping
await E.obj('car-kit','race',{x:0,y:3.6,z:-8,len:1.7,rx:-.55});
// side props: cones banners pylons
for(let i=0;i<5;i++){await E.obj('toy-car-kit','item-cone',{x:-2.2,z:6-i*6,h:.6});await E.obj('toy-car-kit','item-cone',{x:2.2,z:6-i*6,h:.6});}
await E.obj('racing-kit','bannerTowerGreen',{x:-3.4,z:-2,h:3});await E.obj('racing-kit','bannerTowerRed',{x:3.4,z:-14,h:3});
await E.obj('racing-kit','grandStandCovered',{x:-16,z:-11,len:7,ry:Math.PI/2});
await E.obj('pirate-kit','palm-detailed-bend',{x:6,z:-2,h:3.2});await E.obj('pirate-kit','palm-bend',{x:-6,z:5,h:3.4});
E.cam_([6.5,4.4,10],[0,1.8,-7],50);
E.label('FLIP! x2',[0.8,5.6,-8],'font-size:46px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-9deg)');
const card=(t,c)=>`<div style="display:inline-block;width:92px;height:92px;margin:0 6px;border:5px solid #170F45;border-radius:18px;background:${c};font-size:15px;line-height:88px;text-align:center">${t}</div>`;
E.hud(logo('RAMP MAYHEM')+pill('JUMP 3/10','left:14px;top:112px')+pill('★★☆','right:14px;top:112px;border-color:#7dd0ff')+
 `<div class="stroke" style="position:absolute;left:0;right:0;bottom:146px;text-align:center">${card('RAMP','#ff9a1f')}${card('BOOST','#43c0ff')}${card('LOOP','#9b6bff')}${card('SPIN','#5fd35f')}</div>`+
 tag('BUILD THE RAMP. <em>LAUNCH THE MAYHEM.</em>'));
await E.done();};
