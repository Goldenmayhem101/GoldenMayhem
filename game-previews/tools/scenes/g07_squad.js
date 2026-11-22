import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xffb88a,fogColor:0xffc9a0,fogNear:14,fogFar:40,sun:2.4,sunx:-5,suny:8,sunz:-4});
E.ground(0x7a6f66,80,160,0,0,-40);
E.box(5,0.05,120,0x474b5c,0,0.03,-40);for(let z=4;z>-80;z-=2)E.box(0.1,.06,1,0xe8c84a,0,.05,z);
// industrial buildings
const ind='abcdefghijklmn';
for(let i=0;i<9;i++){await E.obj('city-kit-industrial_2.0','building-'+ind[(i*2)%14],{x:-5.5,z:2-i*3.6,len:3.2,ry:Math.PI/2});await E.obj('city-kit-industrial_2.0','building-'+ind[(i*2+3)%14],{x:5.5,z:2-i*3.6,len:3.2,ry:-Math.PI/2});}
// gates (math gates) as glowing boxes
const gate=(x,z,c,t)=>{E.box(2.0,.9,0.12,c,x,.55,z,{emissive:c,ei:.55,rough:.3});E.box(.12,1.0,.12,0x222,x-1.05,.5,z);E.box(.12,1.0,.12,0x222,x+1.05,.5,z);E.label(t,[x,.6,z+.1],'font-size:44px;color:#fff');};
gate(-1.2,-2.6,0x3fa4ff,'+5');gate(1.2,-2.6,0xff5a4a,'-3');
gate(-1.2,-8,0xff5a4a,'÷2');gate(1.2,-8,0x3fa4ff,'x3');
// zombie horde
for(let i=0;i<22;i++){const x=(i%7-3)*0.55+Math.sin(i)*.15,z=-11-Math.floor(i/7)*1.3-(i%2)*.4;await E.obj('mini-characters',i%5==0?'character-zombie':'character-zombie',{x,z,h:.8,ry:0,anim:'walk',t:(i%4)*.2});}
await E.obj('mini-characters','character-zombie',{x:0,z:-19,h:2.6,ry:0,anim:'idle'});
// squad
const sq=[['character-soldier',0,1.6],['character-male-a',-.6,2.1],['character-female-c',.6,2.1],['character-male-d',-1.1,2.6],['character-raider',0,2.7],['character-male-f',1.1,2.6]];
for(const[n,x,z] of sq){await E.obj('mini-characters',n,{x,z,h:.9,ry:Math.PI,anim:'idle',t:.2});}
for(const[x,z] of[[-.35,2.55],[.35,2.55],[0,2.2]])await E.obj('blaster-kit_2.1','bullet-foam',{x,y:.7,z:z-1.5,h:.25,rx:Math.PI/2});
await E.obj('blaster-kit_2.1','crate-wide',{x:-1.9,z:-1.5,len:.9});await E.obj('blaster-kit_2.1','crate-medium',{x:1.9,z:-6,len:.8});
E.cam_([0,6.6,7.4],[0,-.4,-5.2],58);
E.label('x6',[0,1.8,1.6],'font-size:46px;color:#ffd84a');
E.hud(logo('SQUAD MAYHEM')+pill('LEVEL 12','left:14px;top:112px')+pill('☠ 128','right:14px;top:112px;border-color:#ff6b6b')+
 tag('DRAG. GROW THE SQUAD. <em>MOW DOWN THE MAYHEM.</em>'));
await E.done();};
