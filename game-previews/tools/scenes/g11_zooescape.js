import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0x9fe0ff,fogNear:14,fogFar:42});
E.ground(0x76c35f,120,160,0,0,-40);
E.box(3.8,.06,160,0x3b3f4d,0,.03,-60);E.box(.14,.07,160,0xffffff,-1.95,.04,-60);E.box(.14,.07,160,0xffffff,1.95,.04,-60);
for(let z=4;z>-70;z-=2){E.box(.08,.07,.9,0xffffff,-.62,.045,z);E.box(.08,.07,.9,0xffffff,.62,.045,z);}
E.box(1.4,.12,160,0xc9c9d4,-2.8,.06,-60);E.box(1.4,.12,160,0xc9c9d4,2.8,.06,-60);
const com='abcdefghijklmn';
for(let i=0;i<12;i++){await E.obj('city-kit-commercial_2.1','building-'+com[(i*3)%14],{x:-6.2,z:3-i*2.8,len:2.2,h:3+((i*3)%4)*1.2,ry:Math.PI/2});await E.obj('city-kit-commercial_2.1','building-'+com[(i*3+7)%14],{x:6.2,z:3-i*2.8,len:2.2,h:3+((i*5)%4)*1.2,ry:-Math.PI/2});}
const L=[-1.25,0,1.25];
for(const[n,x,z,l] of[['taxi',L[2],-3,1.0],['truck',L[0],-6,1.4],['police',L[1],-9,1.1],['suv',L[2],-11,1.0],['firetruck',L[0],-14,1.6]])await E.obj('car-kit',n,{x,z,len:l,ry:Math.PI});
for(let i=0;i<7;i++)await E.obj('food-kit','banana',{x:L[1]-.0,y:.5,z:-1-i*1.0,len:.55,ry:i*.4,rz:.3});
for(let i=0;i<4;i++)await E.obj('food-kit','banana',{x:L[2],y:.5,z:-5-i*1.0,len:.55,ry:i*.4});
// runner animal (Shiba) + chaser
await E.obj('cube-pets_1.0','animal-monkey',{x:L[1],z:2.4,big:.85,ry:Math.PI,anim:'walk',t:.3});
await E.obj('mini-characters','character-worker',{x:L[0]+.2,z:5.2,h:1.1,ry:Math.PI,anim:'run',t:.2});
await E.obj('prototype-kit','coin',{x:L[1],y:1.2,z:-.5,h:.4,s:undefined}).catch(()=>{});
E.cam_([0,3.9,7.6],[0,.3,-5],54);
E.label('ESCAPE x3',[L[0]+.2,1.8,-1],'font-size:36px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-8deg)');
E.hud(logo('ZOO ESCAPE MAYHEM')+pill('1,920 m','left:14px;top:112px')+pill('🍌 86','right:14px;top:112px;border-color:#ffd84a')+
 tag('RUN. DODGE. <em>ESCAPE THE ZOO.</em>'));
await E.done();};
