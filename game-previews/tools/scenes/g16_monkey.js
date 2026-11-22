import {makeEngine} from '/engine.js';import {logo,tag,pill,bar} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0x9fdcff,fogNear:16,fogFar:44,suny:14,sunx:-6});
E.ground(0x75bf5a,90,90,0,0,-8);
E.box(11,.05,30,0xe4d2a8,0,.03,6);   // zoo path
E.box(5.6,.1,3.8,0x9a7b52,0,.05,-2.4);// cage floor
// cage bars
for(let i=-5;i<=5;i++)E.box(.07,2.8,.07,i%4==0?0xd9a52b:0x4a5578,i*.5,1.4,-.5);
E.box(5.6,.1,.1,0x4a5578,0,2.8,-.5);E.box(.1,2.8,3.8,0x6c7388,-2.8,1.4,-2.4);E.box(.1,2.8,3.8,0x6c7388,2.8,1.4,-2.4);E.box(5.6,2.8,.1,0x6c7388,0,1.4,-4.3);E.box(5.6,.08,3.8,0x4a5578,0,2.85,-2.4);
// monkey: real model if loads else cube pet
let m=null;try{m=await E.obj3('/assets/animals/animals-big-pack/monkey/Monkey.obj','/assets/animals/animals-big-pack/monkey/Monkey_BaseColor.png',{x:-.4,z:-2.4,h:2.0,ry:.35});}catch(e){m=await E.obj('cube-pets_1.0','animal-monkey',{x:-.4,z:-2.4,big:2.0,ry:.35});}
await E.obj('food-kit','banana',{x:.6,y:.12,z:-1.8,len:.7,ry:.8});await E.obj('food-kit','banana',{x:-1.8,y:.12,z:-3,len:.7,ry:-.4});await E.obj('food-kit','watermelon',{x:1.4,y:.12,z:-3.2,h:.6});await E.obj('food-kit','apple',{x:1.9,y:.12,z:-2.2,h:.3});
await E.obj('food-kit','soda-can',{x:-1.2,y:.12,z:-1.4,h:.4}).catch(()=>{});
// visitors in front
const V=[['character-a',-3.4,2.6],['character-g',-1.6,4.4],['character-d',1.9,3.2],['character-k',3.6,4.8]];
let i=0;for(const[n,x,z] of V){await E.obj('blocky-characters_20',n,{x,z,h:1.55,ry:Math.PI+(x*.08),anim:i%2?'idle':'walk',t:.3+i*.2});i++;}
await E.obj('food-kit','ice-cream-cne',{x:-3.0,y:1.2,z:2.4,h:.45});await E.obj('food-kit','burger',{x:1.6,y:1.0,z:3.0,h:.35});
await E.obj('mini-characters','character-worker',{x:4.7,z:-1.5,h:1.2,ry:-Math.PI/2+.3,anim:'idle',t:.4});
// scenery
await E.obj('pirate-kit','palm-bend',{x:-6,z:-1,h:4.2});await E.obj('pirate-kit','palm-detailed-straight',{x:6.2,z:1,h:4.2});
await E.obj('coaster-kit','bench',{x:-4.5,z:4.5,len:1.4,ry:Math.PI});await E.obj('city-kit-roads','light-square',{x:4,z:5,h:2.4}).catch(()=>{});
await E.obj('prototype-kit','animal-horse',{x:-6,z:-8,h:1.2}).catch(()=>{});
E.cam_([0,4.8,9.4],[0,1.3,-2.2],50);
E.label('GRAB!',[-.1,2.4,-1.8],'font-size:40px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-7deg)');
E.hud(logo('MONKEY MAYHEM')+pill('🍌 128','left:14px;top:112px')+
 `<div class="stroke" style="position:absolute;left:0;right:0;top:152px;text-align:center;font-size:13px;letter-spacing:3px;color:#ffd84a">CHAOS · ANNOYED GUESTS</div>`+bar('left:90px;right:90px;top:174px;',54)+
 `<div class="btn stroke" style="right:26px;bottom:150px;width:92px;height:92px;background:#ffd84a;color:#170F45;font-size:18px">THROW</div><div class="btn stroke" style="left:26px;bottom:150px;width:92px;height:92px;background:#59c36a;font-size:18px">GRAB</div>`+
 tag('SWIPE. STEAL. <em>CAUSE MAYHEM.</em>'));
await E.done();};
