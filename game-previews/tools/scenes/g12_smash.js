import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0x8fd6ff,fogNear:25,fogFar:60,suny:14,sunx:-6,shadowSize:12});
E.ground(0x6fc15a,80,80,0,0,-5);E.ground(0xa8dd8a,60,12,.02,0,-18);
// tower: crates/blocks at x=3.5
const P='prototype-kit';
const blocks=[];const stackX=2.8;
for(let r=0;r<5;r++){for(let c=0;c<(r%2?2:3);c++){await E.obj(P,r%2?'crate-color':'crate',{x:stackX-.6+c*.6+(r%2?.3:0),y:r*.55,z:-6,w:.55});}}
await E.obj(P,'column-low',{x:stackX-1.6,z:-6,h:1.1});await E.obj(P,'column-low',{x:stackX+1.6,z:-6,h:1.1});
await E.obj(P,'crate-color',{x:stackX,y:2.75,z:-6,w:1.1});
await E.obj('mini-characters','character-zombie',{x:stackX,y:3.55,z:-6,h:1.0,ry:-Math.PI/2,anim:'idle'});
// thrower
await E.obj('mini-characters','character-male-b',{x:-3.4,z:-6,h:1.5,ry:-Math.PI/2,anim:'idle',t:.5});
// slingshot / arc
const arc=[];for(let i=0;i<14;i++){const t=i/13;const x=-3+ t*5.5,y=.9+Math.sin(t*Math.PI)*3.6-t*.9;arc.push([x,y]);E.sphere(.09,0xffffff,x,y,-6,{emissive:0xffffff,ei:.5,noshadow:true});}
await E.obj('food-kit','watermelon',{x:-2.7,y:1.0,z:-6,h:.55});
await E.obj('food-kit','burger-double',{x:1.0,y:3.4,z:-6,h:.5,ry:.5});
// scenery
await E.obj('pirate-kit','palm-detailed-straight',{x:-5.5,z:-9,h:4});await E.obj('pirate-kit','palm-bend',{x:6.5,z:-9,h:3.6});
await E.obj('pirate-kit','rocks-a',{x:0,z:-9,len:2});await E.obj('racing-kit','barrierWhite',{x:-1,z:-3.4,len:1.2});
E.cam_([-.5,3.6,8.6],[.2,1.9,-6],52);
E.label('SMASH!',[1.2,3.8,-6],'font-size:46px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-8deg)');
const dots=`<span style="display:inline-block;width:48px;height:48px;margin:0 5px;border-radius:50%;border:4px solid #170F45;background:#ff7a2a"></span>`.repeat(3);
E.hud(logo('SMASH YARD MAYHEM')+pill('LEVEL 9','left:14px;top:112px')+pill('★★☆','right:14px;top:112px;border-color:#7dd0ff')+
 `<div style="position:absolute;left:0;right:0;bottom:150px;text-align:center">${dots}</div>`+tag('AIM. THROW. <em>SMASH THE MAYHEM.</em>'));
await E.done();};
