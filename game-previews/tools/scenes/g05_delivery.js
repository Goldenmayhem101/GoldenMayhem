import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xbfe3ff,fog:false,shadowSize:11,suny:16});
E.ground(0x8fbf7a,60,70,0,0,-3);
// city grid: roads every 3 tiles
const R='city-kit-roads';
const gx=[-3,0,3],gz=[-6,-3,0,3,6];
// straights
for(const z of gz)for(let x=-6;x<=6;x++){const isX=gx.includes(x);await E.obj(R,isX?'road-crossroad':'road-straight',{x,z,w:1,ry:0}).catch(()=>{});}
for(const x of gx)for(let z=-8;z<=8;z++){if(gz.includes(z))continue;await E.obj(R,'road-straight',{x,z,w:1,ry:Math.PI/2});}
// buildings in blocks
const com=['building-a','building-c','building-e','building-g','building-i','building-k','building-b','building-d','building-f','building-h'];
let k=0;for(const bx of[-4.5,-1.5,1.5,4.5])for(const bz of[-7.5,-4.5,-1.5,1.5,4.5,7.5]){
 for(const[dx,dz] of[[-.55,-.55],[.55,-.55],[-.55,.55],[.55,.55]]){const n=com[(k++)%com.length];await E.obj('city-kit-commercial_2.1',n,{x:bx+dx*0.95,z:bz+dz*0.95,len:.82});}}
// van + route ribbon
E.ribbon([[0,5],[0,3],[0,0.3],[-3,0],[-3,-3],[-1.5,-3],[0,-3],[3,-3],[3,-6]],0.35,0xffd84a,0.1,{n:260,emissive:0xffb000,ei:.5});
await E.obj('car-kit','delivery',{x:0,z:3.2,len:.95,ry:0});
await E.obj('car-kit','van',{x:-3,z:-2,len:.9,ry:Math.PI/2});await E.obj('car-kit','taxi',{x:3,z:0,len:.9,ry:Math.PI});await E.obj('car-kit','sedan',{x:3,z:-5,len:.9});
// package targets
for(const[x,z] of[[-3,-3.4],[3,-6.3],[0,-6.4]]){await E.obj('prototype-kit','crate',{x,z,h:.5,y:0});await E.obj('prototype-kit','indicator-round-a',{x,z,y:.12,w:1.1}).catch(()=>{});}
E.label('▼',[-3,1.4,-3.4],'font-size:54px;color:#ff4d4d');E.label('▼',[3,1.4,-6.3],'font-size:54px;color:#ff4d4d');E.label('▼',[0,1.4,-6.4],'font-size:54px;color:#ff4d4d');
E.label('+$120',[0.6,1.2,2.2],'font-size:32px;color:#7dff7d');
E.cam_([2.5,15,12],[0,0,-0.5],44);
E.hud(logo('DELIVERY MAYHEM')+pill('DELIVER 2/5','left:14px;top:112px')+pill('⏱ 0:42','right:14px;top:112px;border-color:#7dd0ff')+pill('$ 1,250','left:14px;top:172px')+
 tag('PICK UP. <em>DROP FAST.</em> DODGE THE MAYHEM.'));
await E.done();};
