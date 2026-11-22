import {makeEngine} from '/engine.js';import {logo,tag,pill} from '/common.js';
export default async()=>{const E=await makeEngine({sky:0xa8e6ff,fog:false,shadowSize:11,suny:16});
E.ground(0x2c9fd0,60,70,0,0,0);const w=E.ground(0x5dd0f2,60,70,.02,0,0);w.material.transparent=true;w.material.opacity=.5;
// quays: left, right, top
E.box(3,.5,16,0xc9b79c,-6.5,.1,0);E.box(3,.5,16,0xc9b79c,6.5,.1,0);E.box(14,.5,2.6,0xc9b79c,0,.1,-8.6);
const WP='watercraft-pack';
// boats at the bottom needing dock
const B=[['boat-speed-a',-2.6,3.8,.4],['boat-fishing-small',0,5.5,0],['boat-sail-a',2.8,3.4,-.5],['boat-tug-a',-3.5,-1,1.2],['boat-speed-d',3.6,-3,-1.3],['ship-cargo-a',0.2,-1.6,0]];
for(const[n,x,z,r] of B)await E.obj(WP,n,{x,z,len:n.startsWith('ship')?3.6:1.8,ry:r+Math.PI});
// docks with colored pads
const pads=[[-5,-4,0xff5a4a],[5,-1,0x3fa4ff],[-5,3,0x59c36a],[5,5,0xffc23a],[-2,-8,0xb06bff]];
for(const[x,z,c] of pads){E.box(1.5,.05,1.5,c,x,.38,z,{emissive:c,ei:.4});}
await E.obj('pirate-kit','structure-platform-dock-small',{x:-4.4,y:.1,z:0,len:2}).catch(()=>{});
await E.obj(WP,'cargo-container-a',{x:6.6,y:.3,z:-6,len:2.2,ry:Math.PI/2});await E.obj(WP,'cargo-container-b',{x:6.4,y:.3,z:-3.5,len:2.2,ry:Math.PI/2});await E.obj(WP,'cargo-pile-a',{x:-6.6,y:.3,z:-5.5,len:2.2});await E.obj(WP,'cargo-pile-b',{x:-6.6,y:.3,z:5.5,len:2.2});
await E.obj(WP,'buoy',{x:-1,z:-4.2,h:.6});await E.obj(WP,'buoy',{x:2.4,z:-5,h:.6});await E.obj(WP,'buoy-flag',{x:0.5,z:1.8,h:.9});
// drag paths
E.ribbon([[-2.6,3],[-2.6,0],[-3.8,-3],[-5,-4]],.28,0xff5a4a,.06,{n:60,emissive:0xff5a4a,ei:.6});
E.ribbon([[2.8,2.6],[3.5,0],[5,-1]],.28,0x3fa4ff,.06,{n:50,emissive:0x3fa4ff,ei:.6});
E.ribbon([[0,4.8],[0,2.5],[-2,1],[-4,3]],.28,0x59c36a,.06,{n:60,emissive:0x59c36a,ei:.6});
E.cam_([0,19,10.5],[0,0,-1.5],46);
E.label('DOCK!',[-4.4,1.4,-4],'font-size:34px;color:#ffd84a;transform:translate(-50%,-50%) rotate(-6deg)');
E.hud(logo('HARBOR MAYHEM')+pill('DOCKED 3/6','left:14px;top:112px')+pill('⏱ 1:10','right:14px;top:112px;border-color:#7dd0ff')+
 tag('DRAG. DOCK. <em>DON\'T CRASH.</em>'));
await E.done();};
