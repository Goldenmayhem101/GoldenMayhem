import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xbfe6ff,fog:false,shadowSize:9,sun:2.2});
E.ground(0x7fbf6a,40,60);
E.box(6.6,0.1,8.0,0x474b5c,0,0.03,0);E.box(6.9,0.08,8.3,0xcfd3e0,0,0.02,0);
// lines
for(let c=-2;c<=2;c++)for(let r of[-2.4,-0.8,0.8,2.4]){} 
for(let i=-2.5;i<=2.5;i+=1){E.box(0.05,0.02,7.4,0xe8e8e8,i*1.0,0.09,0.0);}
// cars: grid positions (x across, z down) with orientation
const cars=[['taxi',-2,-3,0],['police',-0.6,-3,0],['suv',0.8,-3,0],['sedan',2.1,-3,0],
['van',-2,-1.1,0],['ambulance',-0.6,-1.1,0],['sedan-sports',0.8,-1.1,0],['hatchback-sports',2.1,-1.1,0],
['firetruck',-2,1.1,0],['truck',-0.6,1.1,0],['delivery',0.8,1.1,0],['race',2.1,1.1,0],
['suv-luxury',-2,3.0,0],['kart-oodi',-0.6,3.0,0],['tractor',0.8,3.0,0],['garbage-truck',2.1,3.0,0]];
let i=0;for(const [n,x,z] of cars){await E.obj('car-kit',n,{x:x,z:z,len:1.35,ry:(i%5==0)?Math.PI/2:0,tint:undefined});i++;}
// exit gate arrow
await E.obj('prototype-kit','indicator-special-arrow',{x:0.1,y:.1,z:-4.6,h:.1,w:1.2}).catch(()=>{});
await E.obj('racing-kit','flagCheckers',{x:-2.8,z:-4.2,h:1.6});await E.obj('racing-kit','flagCheckers',{x:3.0,z:-4.2,h:1.6});
for(const x of[-3.4,3.5])for(const z of[-3,-1,1,3])await E.obj('city-kit-roads','construction-cone',{x,z,h:.35});
E.cam_([0,15,8.6],[0,0,-1.6],44);
E.label('EXIT',[0,0.9,-5.2],'font-size:30px;color:#7dff7d');
E.label('TAP!',[-0.6,2.0,-1.1],'font-size:34px;color:#fff;transform:translate(-50%,-50%) rotate(-6deg)');
E.hud(logo('PARKING MAYHEM')+pill('LEVEL 47','left:14px;top:112px')+pill('MOVES 12','right:14px;top:112px;border-color:#7dd0ff')+
 tag('TAP A CAR. SLIDE IT OUT. <em>BEAT THE JAM.</em>'));
await E.done();};
