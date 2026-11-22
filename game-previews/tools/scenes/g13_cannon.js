import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0x8fe0ff,fogColor:0xb8ecff,fogNear:16,fogFar:40,suny:14});
E.ground(0x2aa7d9,100,120,0,0,-20);
const w=E.ground(0x57c9f0,100,120,.02,0,-20);w.material.transparent=true;w.material.opacity=.55;
// island (bottom)
await E.obj('pirate-kit','platform',{x:0,z:5.2,len:4}).catch(()=>{});
E.box(8,.5,3.2,0xf2d9a0,0,.0,6.4);
await E.obj('pirate-kit','cannon',{x:0,y:.5,z:5.6,len:1.9,ry:Math.PI-.15});
await E.obj('pirate-kit','cannon-ball',{x:-1.1,y:.5,z:6.4,h:.3});await E.obj('pirate-kit','cannon-ball',{x:-1.4,y:.5,z:6.0,h:.3});await E.obj('pirate-kit','barrel',{x:1.6,y:.5,z:5.9,h:.8});await E.obj('pirate-kit','chest',{x:-2.4,y:.5,z:6.2,len:1});
await E.obj('pirate-kit','palm-bend',{x:3.4,y:.5,z:6.6,h:3.2});await E.obj('pirate-kit','palm-detailed-bend',{x:-3.5,y:.5,z:6.8,h:3.4});
// enemy ships
await E.obj('pirate-kit','ship-pirate-large',{x:-2.3,z:-5,len:4.2,ry:Math.PI/2+.2});
await E.obj('pirate-kit','ship-pirate-medium',{x:2.6,z:-10,len:3.4,ry:-Math.PI/2+.3});
await E.obj('pirate-kit','ship-medium',{x:-1.6,z:-14,len:3,ry:Math.PI/2-.2});
await E.obj('pirate-kit','ship-ghost',{x:2.2,z:-20,len:3.8,ry:Math.PI/2});
await E.obj('pirate-kit','ship-wreck',{x:-4.8,z:-1.5,len:3});
for(const[x,z] of[[4.8,-3],[-5,-9],[5.5,-15]])await E.obj('pirate-kit','rocks-sand-a',{x,z,len:1.6});
for(const[x,z] of[[0.3,-5.6],[.8,-1.6]])await E.obj('watercraft-pack','buoy',{x,z,h:.5});
// aim dotted line + splash
for(let i=0;i<12;i++){const t=i/11;E.sphere(.08,0xffffff,0.15*t-0.0+(-2.3+0)*t*.3,.8+Math.sin(t*Math.PI)*2.2,5-t*9.5,{emissive:0xffffff,ei:.6,noshadow:true});}
await E.obj('pirate-kit','cannon-ball',{x:-.45,y:2.8,z:-.2,h:.4});
E.cam_([0,9.5,13],[0,0,-3],50);
E.label('BOOM!',[-1.6,3.2,-5],'font-size:46px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-8deg)');
E.hud(logo('CANNON COVE MAYHEM')+pill('SHIPS 3/8','left:14px;top:112px')+pill('BALLS ●●●○','right:14px;top:112px;border-color:#7dd0ff')+
 tag('AIM. FIRE. <em>SINK THE MAYHEM.</em>'));
await E.done();};
