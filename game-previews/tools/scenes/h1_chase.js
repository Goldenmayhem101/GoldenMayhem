import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';import {road,L,lights,boom,stars} from '/scenes/_road.js';
export default async()=>{const E=await makeEngine({sky:0x8fd6ff,fogNear:16,fogFar:46});
await road(E);
for(const[n,x,z,l] of[['taxi',L[0],-3.4,1.05],['suv',L[2],-5.5,1.05],['truck',L[1],-8,1.4],['van',L[0],-10.5,1.1],['sedan-sports',L[2],-13,1.05],['ambulance',L[1],-15,1.2]])await E.obj('car-kit',n,{x,z,len:l,ry:Math.PI});
for(let i=0;i<4;i++)await E.obj('toy-car-kit','item-coin-gold',{x:L[1],y:.6,z:-1-i*1.2,h:.38,ry:i});
// player hot rod with roof gun
await E.obj('car-kit','sedan-sports',{x:L[1],z:2.4,len:1.15,ry:Math.PI});
await E.obj('blaster-kit_2.1','blaster-h',{x:L[1],y:.72,z:2.35,len:.75,ry:Math.PI});
// police chasing close behind
await E.obj('car-kit','police',{x:L[0]+.2,z:5.0,len:1.25,ry:Math.PI});await E.obj('car-kit','police',{x:L[2]-.1,z:6.2,len:1.25,ry:Math.PI});await E.obj('car-kit','tractor-police',{x:L[1]-.3,z:8.2,len:1.5,ry:Math.PI}).catch(()=>{});
lights(E,L[0]+.2,5.0,.95);lights(E,L[2]-.1,6.2,.95);
E.cam_([0,3.3,10.6],[0,.2,-5],56);
E.label('WANTED!',[0,1.9,-1.6],'font-size:34px;color:#ff5a4a;transform:translate(-50%,-50%) rotate(-5deg)');
E.hud(`<div style="position:absolute;inset:0;box-shadow:inset 0 0 120px 20px rgba(255,40,40,.28),inset 0 0 160px 40px rgba(40,90,255,.22)"></div>`+logo('RUSH HOUR MAYHEM')+
 pill('4,310 m','left:14px;top:112px')+pill('● 640','right:14px;top:112px;border-color:#7dd0ff')+
 `<div class="stroke" style="position:absolute;left:0;right:0;top:162px;text-align:center;font-size:36px;color:#ffb21f;letter-spacing:4px">${stars(4)}</div><div class="stroke" style="position:absolute;left:0;right:0;top:206px;text-align:center;font-size:13px;letter-spacing:5px;color:#fff">HEAT LEVEL 4</div>`+
 `<div style="position:absolute;left:14px;top:260px;width:230px;padding:8px 12px;border:4px solid #170F45;border-radius:16px;background:rgba(255,255,255,.92);color:#170F45;font-size:14px;line-height:1.2">MISSION<br><b style="color:#e0453a">Crash 5 taxis</b> <span style="float:right">3/5</span></div>`+
 `<div class="btn stroke" style="right:20px;bottom:150px;width:96px;height:96px;background:#ff5a2a;font-size:20px">FIRE</div>`+
 `<div class="stroke" style="position:absolute;left:0;right:0;bottom:118px;text-align:center;font-size:20px;color:#ff6b6b;letter-spacing:3px">COPS ON YOUR TAIL!</div>`+
 tag('SWIPE. SHOOT. <em>OUTRUN THE LAW.</em>'));
await E.done();};
