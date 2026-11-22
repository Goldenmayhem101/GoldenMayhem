import {makeEngine} from '/engine.js';import {logo,tag,pill,bar} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0x8fd6ff,fogNear:16,fogFar:46});
E.ground(0x6fb35a,120,160,0,0,-40);
E.box(3.8,0.06,160,0x3b3f4d,0,0.03,-60);            // asphalt
E.box(0.14,0.07,160,0xe9e9e9,-1.95,0.04,-60);E.box(0.14,0.07,160,0xe9e9e9,1.95,0.04,-60);
for(let z=4;z>-70;z-=2){E.box(0.08,0.07,0.9,0xffffff,-0.62,0.045,z);E.box(0.08,0.07,0.9,0xffffff,0.62,0.045,z);}
E.box(1.4,0.12,160,0xb9b9c4,-2.8,0.06,-60);E.box(1.4,0.12,160,0xb9b9c4,2.8,0.06,-60);
const L=[-1.25,0,1.25];
// buildings both sides
const sub=['building-type-a','building-type-c','building-type-e','building-type-g','building-type-i','building-type-k'];
for(let i=0;i<14;i++){const z=4-i*3.2;
 await E.obj('city-kit-suburban_20',sub[i%6],{x:-5.2,z,len:2.4,ry:Math.PI/2});
 await E.obj('city-kit-suburban_20',sub[(i+3)%6],{x:5.2,z,len:2.4,ry:-Math.PI/2});
 if(i%2==0){await E.obj('city-kit-suburban_20','tree-large',{x:-3.5,z:z-1,h:1.6}).catch(()=>{});await E.obj('city-kit-roads','light-square',{x:2.6,z:z-.5,h:1.5,ry:-Math.PI/2}).catch(()=>{});}
}
// traffic ahead
const cars=[['taxi',L[0],-3.2],['police',L[2],-4.6],['truck',L[1],-7],['van',L[0],-9.5],['suv',L[2],-10.5],['ambulance',L[1],-13],['sedan-sports',L[2],-15.5],['delivery',L[0],-16.5],['hatchback-sports',L[1],-19],['firetruck',L[2],-22]];
for(const [n,x,z] of cars)await E.obj('car-kit',n,{x,z,len:1.05,ry:Math.PI});
for(const z of[-3.4,-6])await E.obj('car-kit','cone',{x:L[1],z,h:.4});
// coins
for(let i=0;i<6;i++)await E.obj('toy-car-kit','item-coin-gold',{x:L[1],y:.6,z:-2.0-i*1.1,h:.38,ry:i});
// player car + boost smoke
const pc=await E.obj('car-kit','race',{x:L[1]+0.0,z:2.2,len:1.15,ry:Math.PI});
await E.obj('toy-car-kit','smoke',{x:L[1],y:.1,z:3.2,h:.4}).catch(()=>{});
E.cam_([0,2.5,5.6],[0,0.2,-6],52);
E.label('NEAR MISS!',[L[0]+.5,1.2,-1.5],'font-size:34px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-8deg)');
E.label('+250',[L[0]+.5,0.8,-1.5],'font-size:26px;color:#7dff7d');
E.hud(logo('TRAFFIC MAYHEM')+pill('2,480 m','left:14px;top:112px')+pill('● 312','right:14px;top:112px;border-color:#7dd0ff')+
 bar('left:90px;right:90px;top:168px;',72)+`<div class="stroke" style="position:absolute;top:150px;left:0;right:0;text-align:center;font-size:13px;letter-spacing:3px;color:#ffd84a">MAYHEM METER</div>`+
 `<div class="pop stroke" style="left:300px;top:640px;font-size:46px;color:#fff;transform:rotate(-4deg)">x7</div>`+
 tag('SWIPE. WEAVE. <em>CAUSE MAYHEM.</em>'));
await E.done();};
