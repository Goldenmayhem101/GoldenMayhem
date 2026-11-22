import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xffb3d9,fogColor:0xffd0e8,fogNear:20,fogFar:50,sunx:-8,suny:14,sunz:4,shadowSize:14});
E.ground(0x7fcf6a,90,90,0,0,-4);
const C='coaster-kit';
const seq=['straight','straight','straight','straight','looping','straight','straight'];
let z=6;
for(const n of seq){const name='coaster-steel-'+n;await E.obj(C,name,{x:0,z,s:1.0,ry:0}).catch(async e=>{await E.obj(C,'coaster-steel-straight',{x:0,z,s:1})});z-=4;}
// scenery
await E.obj(C,'bench',{x:3,z:2,len:1.2,ry:-Math.PI/2});
for(const[x,zz] of[[-5,3],[5,-2],[-6,-8],[6,-12],[-4,-16],[5,-20]])await E.obj('pirate-kit',(x>0?'palm-bend':'palm-detailed-bend'),{x,z:zz,h:3.4});
for(const[x,zz] of[[4,-5],[-4,-3]])await E.obj('city-kit-commercial_2.1','building-'+(x>0?'c':'h'),{x:x*1.6,z:zz-6,len:2.4,h:3});
// riders: characters in cart
await E.obj('blocky-characters_20','character-a',{x:0,y:.7,z:1.8,h:1.1,ry:Math.PI,anim:'idle',t:.3});await E.obj('blocky-characters_20','character-g',{x:0,y:.7,z:2.5,h:1.1,ry:Math.PI,anim:'idle',t:.3});
E.cam_([5.5,5,10],[0,1.4,-8],54);
E.label('LOOP!',[0,4.4,-16],'font-size:40px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-8deg)');
const card=(t,c)=>`<div style="display:inline-block;width:76px;height:76px;margin:0 5px;border:5px solid #170F45;border-radius:16px;background:${c};font-size:12px;line-height:66px;text-align:center">${t}</div>`;
E.hud(logo('COASTER MAYHEM')+pill('LEVEL 21','left:14px;top:112px')+pill('★★★','right:14px;top:112px;border-color:#ffd84a')+
 `<div class="stroke" style="position:absolute;left:0;right:0;bottom:132px;text-align:center">${card('HILL','#ff9a1f')}${card('CURVE','#43c0ff')}${card('LOOP','#9b6bff')}${card('JUMP','#5fd35f')}${card('RIDE','#ff4d6d')}</div>`+
 tag('BUILD THE TRACK. <em>SURVIVE THE MAYHEM.</em>'));
await E.done();};
