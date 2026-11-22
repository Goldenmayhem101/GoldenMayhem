import {makeEngine} from '/engine.js';import {logo,tag,pill,bar} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xffc98a,fogColor:0xffd9a8,fogNear:18,fogFar:46,sun:2.6,sunx:-6,suny:9,sunz:4,hemi:1.1});
E.ground(0x6a9e4e,90,90,0,0,0);
const pts=[[0,12],[0,5],[-1,0],[-4,-3],[-5,-7],[-2,-10],[2,-13],[4,-17],[1,-21],[-3,-24]];
E.ribbon(pts,2.6,0x3d4150,0.03,{n:200});
// curbs
const cv=E.curve(pts);
for(let i=0;i<110;i++){const t=i/110;const p=cv.getPoint(t),tg=cv.getTangent(t);const nx=-tg.z,nz=tg.x;
 for(const sd of[-1,1]){const c=(i%2)?0xe8332f:0xf4f4f4;E.box(0.3,0.08,0.5,c,p.x+nx*1.45*sd,0.06,p.z+nz*1.45*sd,{ry:Math.atan2(tg.x,tg.z)});}}
for(let i=0;i<30;i++){const t=0.05+i*0.03;if(t>1)break;const p=cv.getPoint(t);E.box(0.07,0.02,0.5,0xffffff,p.x,0.05,p.z,{ry:Math.atan2(cv.getTangent(t).x,cv.getTangent(t).z)});}
// car drifting
const car=await E.obj('racing-kit','raceCarOrange',{x:-1.7,z:-1.2,len:1.9,ry:-1.2});
for(let i=0;i<6;i++)await E.obj('toy-car-kit','smoke',{x:-0.6+i*0.55+Math.random()*.1,z:-0.4+i*0.5,y:0.05,h:.35+i*.1,ry:i}).catch(()=>{});
// trackside
await E.obj('racing-kit','grandStand',{x:-8,z:2,len:6,ry:Math.PI/2});await E.obj('racing-kit','grandStandCovered',{x:7,z:-14,len:6,ry:-Math.PI/2});
for(const [x,z] of[[3,-3],[-7,-10],[6,-9],[-6,-19],[8,-21]])await E.obj('racing-kit','bannerTowerRed',{x,z,h:2.6});
for(let i=0;i<14;i++){const t=i/14*.9+.05;const p=cv.getPoint(t),tg=cv.getTangent(t);const nx=-tg.z,nz=tg.x;await E.obj('racing-kit',(i%2?'barrierRed':'barrierWhite'),{x:p.x+nx*2.2,z:p.z+nz*2.2,len:.9,ry:Math.atan2(tg.x,tg.z)});}
for(let i=0;i<8;i++){const t=0.18+i*0.1;const p=cv.getPoint(t);await E.obj('toy-car-kit','item-coin-gold',{x:p.x,y:.55,z:p.z,h:.35,ry:i});}
await E.obj('racing-kit','flagCheckers',{x:-1.3,z:8,h:1.8});await E.obj('racing-kit','overhead',{x:0,z:9,len:3.4,ry:Math.PI/2}).catch(()=>{});
E.cam_([3.2,12.5,9.5],[-1.0,0,-5.5],50);
E.label('DRIFT x4',[-0.2,1.6,-1.6],'font-size:44px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-8deg)');
E.hud(logo('DRIFT MAYHEM')+pill('LAP 2/3','left:14px;top:112px')+pill('00:48.2','right:14px;top:112px;border-color:#7dd0ff')+
 `<div class="stroke" style="position:absolute;left:14px;bottom:150px;font-size:40px">3,420</div>`+
 `<div class="btn stroke" style="right:24px;bottom:150px;width:104px;height:104px;background:#ff9a1f;font-size:22px">HOLD</div>`+
 tag('HOLD TO DRIFT. <em>RELEASE TO ROCKET.</em>'));
await E.done();};
