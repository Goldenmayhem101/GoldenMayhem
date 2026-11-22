import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';import {road,L,boom,stars} from '/scenes/_road.js';
export default async()=>{const E=await makeEngine({sky:0x4a3a78,fogColor:0x5b4a8c,fogNear:12,fogFar:38,sun:1.3,sunx:-4,suny:10,hemi:.9,ground:0x2b3a55});
await road(E,{grass:0x3d5a45});
// moon glow sphere
E.sphere(5,0xfff3c4,-14,26,-60,{emissive:0xfff3c4,ei:1.6,noshadow:true});
// zombie horde in the road
const Z=[[L[0],-3],[L[1]-.3,-4],[L[2],-3.6],[L[0]+.4,-6],[L[1],-6.8],[L[2]-.3,-7.5],[L[0],-9],[L[1]+.3,-9.5],[L[2],-11],[L[0]-.2,-12],[L[1],-13.5],[L[2]+.1,-14]];
for(const[x,z] of Z)await E.obj('mini-characters','character-zombie',{x,z,h:.95,ry:Math.PI*(Math.random()>.5?1:0)+Math.random()*.6,anim:'walk',t:Math.random()});
// flung zombies
await E.obj('mini-characters','character-zombie',{x:L[1]-.9,y:2.2,z:-2,h:.95,rx:1.3,rz:.8,anim:'idle'});await E.obj('mini-characters','character-zombie',{x:L[2]-.3,y:1.6,z:-1.2,h:.95,rx:-1.0,rz:-.6,anim:'idle'});
// green splats
for(const[x,z,r] of[[L[1]-.2,-1.0,.5],[L[0]+.3,-2.2,.4],[L[2],-1.8,.45]])E.sphere(r,0x6bff4a,x,.06,z,{emissive:0x3acf2a,ei:.6,noshadow:true}).scale.y=.05;
// player truck with plow + gun
await E.obj('car-kit','tractor-shovel',{x:L[1],z:2.4,len:1.6,ry:Math.PI});await E.obj('blaster-kit_2.1','blaster-q',{x:L[1],y:1.0,z:2.2,len:.8,ry:Math.PI}).catch(()=>{});
// headlight cones
for(const dx of[-.35,.35]){const c=E.sphere(.9,0xfff6c0,L[1]+dx,.6,.2,{emissive:0xfff0a0,ei:1.2,op:.22,noshadow:true});c.scale.set(.7,.5,3.2);}
E.cam_([0,3.3,8.8],[0,.4,-5],56);
E.label('ROADKILL x12!',[0,2.6,-3],'font-size:38px;color:#7dff7d;transform:translate(-50%,-50%) rotate(-5deg)');
E.hud(logo('RUSH HOUR MAYHEM')+`<div class="stroke" style="position:absolute;left:0;right:0;top:92px;text-align:center;font-size:13px;letter-spacing:5px;color:#9bff7d">NIGHT · ZOMBIE MODE</div>`+pill('☠ 37 / 50','left:14px;top:132px;border-color:#9bff7d')+pill('● 860','right:14px;top:132px;border-color:#7dd0ff')+
 `<div style="position:absolute;left:14px;top:192px;width:240px;padding:8px 12px;border:4px solid #170F45;border-radius:16px;background:rgba(255,255,255,.92);color:#170F45;font-size:14px;line-height:1.2">MISSION<br><b style="color:#2a9a3a">Mow down 50 zombies</b></div>`+
 `<div class="btn stroke" style="right:20px;bottom:150px;width:96px;height:96px;background:#5fd35f;font-size:18px">NITRO</div>`+
 tag('SURVIVE THE NIGHT. <em>RUN THEM DOWN.</em>'));
await E.done();};
