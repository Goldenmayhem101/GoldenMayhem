import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0x241a52,fog:false,sun:2.2,hemi:.9,suny:9,sunz:6,sunx:-5,shadowSize:7});
E.ground(0x2b2260,40,40);
// platform
E.box(4.6,.25,4.6,0xffd84a,0,.12,0);E.box(4.2,.3,4.2,0x3a2f7a,0,.14,0);E.box(3.6,.04,3.6,0x120a3a,0,.31,0);
// hero car with gun
await E.obj('car-kit','sedan-sports',{x:0,y:.33,z:0,len:2.4,ry:Math.PI*1.25});await E.obj('blaster-kit_2.1','blaster-h',{x:-.05,y:1.3,z:0,len:1.3,ry:Math.PI*1.25});
// carousel of other cars (smaller, behind)
const oth=[['police',-3.6,-3.4],['taxi',3.6,-3.4],['race',-5,-6.5],['truck',5,-6.8]];
for(const[n,x,z] of oth)await E.obj('car-kit',n,{x,y:.2,z,len:1.9,ry:Math.PI*1.1});
// spotlight cones
const c=E.sphere(2.2,0xffffff,0,3.2,0,{emissive:0xffffff,ei:.4,op:.06,noshadow:true});c.scale.set(1,1.6,1);
E.cam_([0,4.6,11.5],[0,-.2,-1.5],46);
const up=(n,p,c)=>`<div style="margin:9px 0"><div style="display:flex;justify-content:space-between;font-size:15px"><span>${n}</span><span style="color:#ffd84a">LV ${Math.round(p/20)}</span></div><div class="bar" style="position:relative;height:16px"><i style="width:${p}%;background:linear-gradient(${c},${c})"></i></div></div>`;
E.hud(logo('GARAGE')+pill('● 4,820','left:14px;top:112px')+pill('◆ 36','right:14px;top:112px;border-color:#ff9bd0')+
 `<div class="stroke" style="position:absolute;left:0;right:0;top:170px;text-align:center;font-size:24px;color:#ffd84a">STREET SHARK</div>`+
 `<div style="position:absolute;left:18px;right:18px;bottom:150px;padding:6px 18px;border:4px solid #170F45;border-radius:20px;background:rgba(36,26,82,.94)" class="stroke">${up('ENGINE',80,'#ffb21f')}${up('ARMOR',40,'#43c0ff')}${up('GUN DAMAGE',60,'#ff5a4a')}${up('TIRES',20,'#59c36a')}</div>`+
 `<div class="btn stroke" style="right:24px;bottom:350px;width:auto;height:48px;border-radius:24px;padding:0 20px;background:#59c36a;font-size:17px">UPGRADE 450</div>`+
 tag('UPGRADE. ARM UP. <em>RULE THE ROAD.</em>'));
await E.done();};
