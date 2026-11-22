import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xffd6ec,fog:false,suny:12,sunz:8,hemi:1.5,shadowSize:6});
E.ground(0xffe9f5,40,40);
// tray
E.box(4.6,.3,.3,0xffffff,0,.15,2.1);E.box(.3,4.2,.3,0xffffff,-2.3,2.1,2.1);E.box(.3,4.2,.3,0xffffff,2.3,2.1,2.1);E.box(4.6,.2,4,0xf6c3e0,0,0,0.2);
E.box(4.2,3.8,.06,0xffd0ea,0,2.1,-1.6,{});const glass=E.box(4.4,4.2,.08,0xbfe9ff,0,2.2,2.2);glass.material.transparent=true;glass.material.opacity=.18;glass.castShadow=false;
// pets by tier: [name, x, y, size]
const pets=[['animal-elephant',-.9,.05,1.6],['animal-lion',1.1,.05,1.35],['animal-tiger',-1.6,1.4,1.1],['animal-panda',.2,1.45,1.0],['animal-fox',1.75,1.25,.9],
 ['animal-dog',-1.2,2.4,.85],['animal-cat',.55,2.35,.7],['animal-bunny',-.2,2.9,.6],['animal-chick',1.4,2.45,.5],['animal-bee',-1.7,2.9,.42]];
for(const[n,x,y,s] of pets)await E.obj('cube-pets_1.0',n,{x,y,z:.4,big:s*0.95,ry:Math.PI*.08*(x>0?-1:1)});
// next pet falling with guide line
await E.obj('cube-pets_1.0','animal-cat',{x:.55,y:4.3,z:.4,big:.7,ry:0});
E.box(.04,2.2,.04,0xff4fa0,.55,3.1,.4,{emissive:0xff4fa0,ei:.8});
E.cam_([0,3.3,11.2],[0,2.3,0],45);
E.label('MERGE!',[1.0,3.3,1],'font-size:44px;color:#ff4fa0;transform:translate(-50%,-50%) rotate(-7deg)');
// evolution chain
const ch=['bee','chick','bunny','cat','dog','fox','panda','tiger','lion','elephant'].map((n,i)=>`<div style="display:inline-block;width:42px;height:42px;margin:2px;border:3px solid #170F45;border-radius:50%;background:hsl(${i*34},80%,65%);font-size:9px;line-height:36px">${n.slice(0,2)}</div>`).join('');
E.hud(logo('PET MERGE MAYHEM')+pill('SCORE 18,420','left:14px;top:112px')+pill('NEXT ▶','right:14px;top:112px;border-color:#ff9bd0')+
 `<div class="stroke" style="position:absolute;left:0;right:0;bottom:148px;text-align:center;line-height:1">${ch}</div>`+tag('DROP. MATCH. <em>MERGE THE MAYHEM.</em>'));
await E.done();};
