import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xffe3a1,fog:false,suny:12,sunz:9,hemi:1.4,shadowSize:6});
E.ground(0xe8b86b,40,40);E.box(4.2,.22,4.2,0xb5532c,0,.11,0,{});E.box(4.4,.1,4.4,0xf5e6c8,0,.27,0);
// plate
await E.obj('food-kit','plate-dinner',{x:0,y:.32,z:0,len:2.2});
// stacked tower of foods
const st=[['bread',2.0,.0],['patty',0,0]];
const layers=[['loaf',1.5,0,.02],['meat-patty',1.5,.0,0],['cheese',1.5,0,0],['meat-patty',1.5,.03,0],['cheese',1.5,-.04,0],['salad',1.5,.06,0],['burger',1.4,.1,0]];
let y=.42;const hs={'loaf':.62,'meat-patty':.2,'cheese':.14,'tomato-slice':.12,'salad':.3,'burger':.6};
let i=0;for(const[n,len,dx,_] of layers){const o=await E.obj('food-kit',n,{x:dx+i*.04,y,z:0,len,ry:i*.5});const bb=new E.THREE.Box3().setFromObject(o);y=bb.max.y-.02;i++;}
// swinging next piece
await E.obj('food-kit','sandwich',{x:1.0,y:y+.7,z:0,len:1.3,ry:.3,rz:.12});
E.box(.04,1.2,.04,0x8a4b2a,1.0,y+1.6,0);
// customer
await E.obj('blocky-characters_20','character-d',{x:-2.7,z:-.3,h:2.2,ry:.5,anim:'idle',t:.3});
await E.obj('food-kit','bottle-ketchup',{x:2.7,y:.3,z:.8,h:1.2});await E.obj('food-kit','fries',{x:-1.9,y:.3,z:1.8,h:.9});await E.obj('food-kit','soda',{x:2.2,y:.3,z:1.9,h:1.0});
E.cam_([0,4.2,11.5],[0,2.6,0],48);
E.label('PERFECT!',[.2,y-1.4,1.6],'font-size:42px;color:#7dff7d;transform:translate(-50%,-50%) rotate(-6deg)');
E.hud(logo('FOOD TRUCK MAYHEM')+pill('ORDER #14','left:14px;top:112px')+pill('★ 4.8','right:14px;top:112px;border-color:#7dd0ff')+
 `<div style="position:absolute;left:34px;top:178px;width:300px;padding:10px 14px;border:4px solid #170F45;border-radius:20px;background:#fff;color:#170F45;font-size:18px;line-height:1.1;font-family:Arial Black">I WANT IT <span style="color:#e0453a">SKY HIGH!</span><br>🍔 x 8 layers</div>`+
 tag('TAP TO DROP. <em>STACK IT SKY HIGH.</em>'));
await E.done();};
