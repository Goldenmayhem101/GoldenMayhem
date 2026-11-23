import {makeEngine,THREE} from '/engine.js';import {inject,chip,coin,gem,T} from '/ui.js';
export default async()=>{inject();
const E=await makeEngine({sky:0x8fe0ff,fogColor:0xbfefff,fogNear:24,fogFar:60,sun:2.6,hemi:1.3,sunx:-6,suny:12,sunz:3,ground:0x3fb7d8});
const P='pirate-kit',M='mini-characters',C='cube-pets_1.0';
// water + dock lane
E.ground(0x2bb3dc,80,140,-.05,0,-30);
E.box(6.2,.4,70,0xb98350,0,-.12,-24);
for(let z=10;z>-60;z-=1.2)E.box(6.0,.05,1.05,(Math.floor(z*3)%2)?0xc9945a:0xb98350,0,.1,z);
E.box(.3,.7,70,0x8a5a32,-3.1,.15,-24);E.box(.3,.7,70,0x8a5a32,3.1,.15,-24);
// islands, rocks, palms
for(const[x,z,k] of[[-8,-2,'rocks-sand-a'],[9,-8,'rocks-sand-b'],[-9,-12,'rocks-sand-c'],[8,2,'rocks-a']])await E.obj(P,k,{x,z,len:3.2});
for(const[x,z] of[[-6.5,4],[-7.5,-6],[7,-3],[6.5,-12],[-6,-16]]){await E.obj(P,'patch-sand',{x,z,len:3.5});await E.obj(P,'palm-detailed-bend',{x,z,h:3.4,ry:x});}
await E.obj(P,'ship-pirate-large',{x:-13,z:-22,len:8,ry:.5});await E.obj(P,'ship-pirate-medium',{x:12,z:-28,len:6,ry:-.6});
// enemy tower
await E.obj(P,'tower-complete-large',{x:0,z:-23,h:7.5});
await E.obj(P,'castle-wall',{x:-2.6,z:-21,len:2.4});await E.obj(P,'castle-wall',{x:2.6,z:-21,len:2.4});
// gates
const gate=(x,z,c,w=2.8)=>{const m=new THREE.Mesh(new THREE.BoxGeometry(w,1.5,.1),new THREE.MeshStandardMaterial({color:c,transparent:true,opacity:.6,emissive:c,emissiveIntensity:.6,roughness:.2}));m.position.set(x,.9,z);E.scene.add(m);
 E.box(.16,1.7,.16,0xffffff,x-w/2,.9,z,{emissive:c,ei:.4});E.box(.16,1.7,.16,0xffffff,x+w/2,.9,z,{emissive:c,ei:.4});E.box(w+.16,.16,.16,0xffffff,x,1.7,z,{emissive:c,ei:.4});};
gate(-1.5,-3,0x2f8cff);gate(1.5,-3,0x28c85a);gate(-1.5,-11,0xb04cff);gate(1.5,-11,0x2f8cff);
E.label('x2',[-1.5,1.0,-2.9],'font-size:60px');E.label('+25',[1.5,1.0,-2.9],'font-size:60px');E.label('x3',[-1.5,1.0,-10.9],'font-size:60px');E.label('x2',[1.5,1.0,-10.9],'font-size:60px');
// numbered blocks
for(const[x,z,n] of[[-1.9,-7,'30'],[0,-7,'45'],[1.9,-7,'30']]){await E.obj('prototype-kit','crate-color',{x,z,len:1.5,tint:0xff9a6a});E.label(n,[x,1.8,z+.4],'font-size:34px;color:#fff');}
// animal mob (our twist: Cube Pet army) streaming up the lane
const an=['animal-dog','animal-cat','animal-bunny','animal-fox','animal-pig','animal-panda','animal-koala','animal-lion','animal-tiger','animal-monkey','animal-penguin','animal-chick'];
let seed=7;const rnd=()=>(seed=(seed*16807)%2147483647)/2147483647;
const spots=[];
// dense stream bands (from cannon up through gates)
for(let i=0;i<320;i++){const t=Math.pow(rnd(),.8);const z=2.2-t*14;const spread=.45+t*2.3;const x=(rnd()-.5)*2*spread;spots.push([Math.max(-2.7,Math.min(2.7,x)),z]);}
for(const[x,z] of spots){await E.obj(C,an[Math.floor(rnd()*an.length)],{x,z,h:.5+rnd()*.07,ry:Math.PI+(rnd()-.5)*.5});}
// enemy ghosts near tower
for(let i=0;i<26;i++)await E.obj(M,'character-zombie',{x:(rnd()-.5)*5,z:-15.5-rnd()*3,h:.62,ry:(rnd()-.5)*.5,tint:0xff7a7a,anim:'walk',t:rnd()});
// cannon
await E.obj(P,'cannon',{x:0,y:.1,z:3.9,len:2.2,ry:Math.PI});
E.sphere(.18,0xfff0a0,0,.9,3.0,{emissive:0xffc83a,ei:2,noshadow:true});
// glow tracers
const glow=new THREE.Mesh(new THREE.CircleGeometry(2.6,40),new THREE.MeshBasicMaterial({color:0xffe27a,transparent:true,opacity:.22}));glow.rotation.x=-Math.PI/2;glow.position.set(0,.14,4.0);E.scene.add(glow);
E.cam_([0,11.2,13.2],[0,0,-6.2],52);
E.label('+25',[1.2,1.8,-.5],'font-size:44px;color:#4dff7a;transform:translate(-50%,-50%) rotate(-6deg)');
E.label('+50',[-2.3,1.6,-4.9],'font-size:40px;color:#ffe45a;transform:translate(-50%,-50%) rotate(6deg)');
E.raw(`<div class="plate blue t" style="position:relative;width:118px;height:48px;border-radius:24px;font-size:32px;line-height:40px;text-align:center">x 186</div>`,[0,2.3,.4]);
E.hud(`
${chip(coin(),'1,280','left:12px;top:14px;min-width:132px')}
${chip(gem(),'45','left:152px;top:14px;min-width:96px')}
<div class="plate gold" style="left:352px;top:10px;width:176px;height:50px;border-radius:25px"></div>
${T('BONUS ROUND','left:365px;top:17px;font-size:23px;color:#fff')}
<div class="ab t" style="left:50%;top:72px;transform:translateX(-50%);font-size:20px;color:#ffe45a">CANNON COVE</div>
<div class="ab" style="left:50%;top:104px;transform:translateX(-50%);width:410px"><div class="hp" style="position:relative;width:410px;height:34px"><i style="width:44%;background:linear-gradient(#ffb0a0,#ee3f3f)"></i><b style="line-height:25px;font-size:22px">TOWER 15.0K</b></div></div>
<div class="ab" style="left:50%;top:148px;transform:translateX(-50%);width:330px"><div class="hp" style="position:relative;width:330px;height:22px;background:#c62a3a"><i style="width:58%;background:linear-gradient(#8fd6ff,#2f84ff)"></i><b style="line-height:14px;font-size:15px">PUSH</b></div></div>
<div class="ab t" style="left:50%;bottom:118px;transform:translateX(-50%);font-size:40px;color:#ffe45a;animation:none">RELEASE!</div>
<div class="bigbtn gold glow" style="left:170px;bottom:16px;width:200px;height:92px;flex-direction:column"><div class="t" style="font-size:28px">HOLD TO FIRE</div><div class="t" style="font-size:14px;color:#fff6c0">KEEP HOLDING = FASTER</div></div>
`);
await E.done();};
