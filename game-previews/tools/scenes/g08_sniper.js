import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xe9a46a,fogColor:0xf0b080,fogNear:12,fogFar:38,sun:2.6,sunx:-9,suny:7,sunz:2,hemi:1.0,shadowSize:12});
E.ground(0x5b5f6b,60,80,0,0,-12);
// street along z with buildings left right (commercial tall)
E.box(3.4,.05,60,0x3a3d4a,0,.03,-14);for(let z=2;z>-40;z-=2)E.box(.08,.06,.9,0xe8c84a,0,.05,z);
const com='abcdefghijklmn';
for(let i=0;i<10;i++){await E.obj('city-kit-commercial_2.1','building-'+com[(i*3)%14],{x:-3.2,z:1-i*2.3,len:2.1,h:2.4+((i*5)%4)*.9,ry:Math.PI/2});await E.obj('city-kit-commercial_2.1','building-'+com[(i*3+5)%14],{x:3.2,z:1-i*2.3,len:2.1,h:2.4+((i*3)%4)*.9,ry:-Math.PI/2});}
// zombies in street + a few civilians
const zz=[[-.6,-3.5],[.5,-5],[-.2,-7],[.7,-9],[-.8,-11],[.1,-14],[.9,-6.5],[-.5,-9.5]];
for(const[x,z] of zz)await E.obj('mini-characters','character-zombie',{x,z,h:.75,ry:0,anim:'walk',t:(Math.abs(x)*2)%.9});
await E.obj('mini-characters','character-zombie',{x:0.3,z:-1.5,h:1.7,ry:0,anim:'walk',t:.4});
await E.obj('car-kit','police',{x:-1.0,z:-2.5,len:1.4,ry:.2});await E.obj('car-kit','taxi',{x:.9,z:-12,len:1.3,ry:Math.PI});
await E.obj('city-kit-roads','construction-barrier',{x:0,z:-16,len:1.2});
E.cam_([.6,7.2,6.2],[0,0,-6],46);
// scope vignette
E.label('HEADSHOT!',[0.3,2.8,-1.5],'font-size:34px;color:#ff5a4a;transform:translate(-50%,-50%) rotate(-6deg)');
E.hud(`<div style="position:absolute;inset:0;background:radial-gradient(circle at 50% 46%,transparent 0 236px,#000 238px)"></div>
<div style="position:absolute;left:50%;top:46%;width:476px;height:476px;margin:-238px 0 0 -238px;border:6px solid #170F45;border-radius:50%;box-shadow:0 0 0 4px #ffd84a"></div>
<div style="position:absolute;left:50%;top:calc(46% - 238px);width:3px;height:476px;background:#1b1b1b"></div>
<div style="position:absolute;top:46%;left:calc(50% - 238px);height:3px;width:476px;background:#1b1b1b"></div>
<div style="position:absolute;left:50%;top:46%;width:30px;height:30px;margin:-15px;border:3px solid #ff3b3b;border-radius:50%"></div>`+
 logo('ROOFTOP MAYHEM')+pill('WAVE 3','left:14px;top:112px')+pill('AMMO 5/8','right:14px;top:112px;border-color:#7dd0ff')+
 tag('HOLD STEADY. <em>TAKE THE SHOT.</em>'));
await E.done();};
