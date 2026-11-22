import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';import {road,L,lights,boom,stars} from '/scenes/_road.js';
export default async()=>{const E=await makeEngine({sky:0x8fd6ff,fogNear:16,fogFar:46});
await road(E);
await E.obj('car-kit','suv',{x:L[2],z:-9,len:1.05,ry:Math.PI});await E.obj('car-kit','delivery',{x:L[0],z:-6,len:1.4,ry:Math.PI});await E.obj('car-kit','van',{x:L[2],z:-13,len:1.1,ry:Math.PI});
// exploding taxi
await E.obj('car-kit','taxi',{x:L[1],y:.9,z:-4.2,len:1.05,ry:Math.PI+.6,rx:-.35,rz:.4});
boom(E,L[1],.9,-4.4,1.25);
for(const[n,x,y,z,rx,ry] of[['debris-bumper',L[1]-1,1.8,-3.4,.6,1],['debris-door',L[1]+1,2.2,-3.2,1,.3],['debris-tire',L[1]-.2,2.8,-4.0,.2,.2],['debris-spoiler-a',L[1]+.6,1.4,-2.7,.5,2],['debris-wheel',L[1]-.9,1.1,-2.5,0,1]])
 await E.obj('car-kit',n,{x,y,z,h:.4,rx,ry}).catch(()=>{});
// tracers
for(let i=0;i<7;i++)E.box(.05,.05,.5,0xfff07a,L[1]+(Math.sin(i)*.03),.75+i*.0,1.5-i*.55,{emissive:0xffe14a,ei:2.2});
// player
await E.obj('car-kit','sedan-sports',{x:L[1],z:2.4,len:1.15,ry:Math.PI});await E.obj('blaster-kit_2.1','blaster-m',{x:L[1],y:.72,z:2.3,len:.8,ry:Math.PI});
E.sphere(.28,0xffe36a,L[1],.8,1.8,{emissive:0xffd23a,ei:3,noshadow:true});
await E.obj('car-kit','police',{x:L[0],z:6.4,len:1.25,ry:Math.PI});lights(E,L[0],6.4,.95);
for(let i=0;i<4;i++)await E.obj('toy-car-kit','item-coin-gold',{x:L[0],y:.6,z:-1.5-i*1.2,h:.38,ry:i});
E.cam_([0,3.4,9.8],[0,.4,-5],56);
E.label('BOOM!',[-.9,2.9,-3.5],'font-size:58px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-9deg)');
E.label('+500',[.9,2.6,-3.5],'font-size:34px;color:#7dff7d');
E.hud(logo('RUSH HOUR MAYHEM')+pill('COMBO x6','left:14px;top:112px;border-color:#ffd84a')+pill('● 1,120','right:14px;top:112px;border-color:#7dd0ff')+
 `<div class="stroke" style="position:absolute;left:0;right:0;top:162px;text-align:center;font-size:36px;color:#ffb21f;letter-spacing:4px">${stars(5)}</div><div class="stroke" style="position:absolute;left:0;right:0;top:206px;text-align:center;font-size:13px;letter-spacing:5px;color:#fff">MAX HEAT!</div>`+
 `<div style="position:absolute;left:14px;bottom:160px;width:180px"><div class="stroke" style="font-size:12px;letter-spacing:2px">AMMO</div><div class="bar" style="position:relative;height:20px"><i style="width:68%"></i></div></div>`+
 `<div class="btn stroke" style="right:20px;bottom:150px;width:96px;height:96px;background:#ff5a2a;font-size:20px">FIRE</div>`+
 tag('MOUNT A GUN. <em>WRECK EVERYTHING.</em>'));
await E.done();};
