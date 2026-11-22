export async function road(E,o={}){
 E.ground(o.grass||0x6fb35a,120,160,0,0,-40);
 E.box(3.8,0.06,160,0x3b3f4d,0,0.03,-60);E.box(0.14,0.07,160,0xe9e9e9,-1.95,0.04,-60);E.box(0.14,0.07,160,0xe9e9e9,1.95,0.04,-60);
 for(let z=10;z>-70;z-=2){E.box(0.08,0.07,0.9,0xffffff,-0.62,0.045,z);E.box(0.08,0.07,0.9,0xffffff,0.62,0.045,z);}
 E.box(1.4,0.12,160,0xb9b9c4,-2.8,0.06,-60);E.box(1.4,0.12,160,0xb9b9c4,2.8,0.06,-60);
 const sub=['building-type-a','building-type-c','building-type-e','building-type-g','building-type-i','building-type-k'];
 for(let i=0;i<14;i++){const z=8-i*3.2;
  await E.obj('city-kit-suburban_20',sub[i%6],{x:-5.2,z,len:2.4,ry:Math.PI/2});await E.obj('city-kit-suburban_20',sub[(i+3)%6],{x:5.2,z,len:2.4,ry:-Math.PI/2});
  if(i%2==0)await E.obj('city-kit-roads','light-square',{x:2.6,z:z-.5,h:1.5,ry:-Math.PI/2}).catch(()=>{});}
}
export const L=[-1.25,0,1.25];
export function lights(E,x,z,y=1.0){ // police light glows
 E.sphere(.22,0xff2a2a,x-.22,y,z,{emissive:0xff2a2a,ei:2.5,noshadow:true});E.sphere(.22,0x2a6bff,x+.22,y,z,{emissive:0x2a6bff,ei:2.5,noshadow:true});
 const g1=E.sphere(.5,0xff2a2a,x-.22,y,z,{emissive:0xff2a2a,ei:1,op:.12,noshadow:true});const g2=E.sphere(.5,0x2a6bff,x+.22,y,z,{emissive:0x2a6bff,ei:1,op:.12,noshadow:true});
}
export function boom(E,x,y,z,s=1){ // cartoon fireball
 E.sphere(.7*s,0xffe36a,x,y,z,{emissive:0xffd23a,ei:2.2,noshadow:true});E.sphere(1.0*s,0xff9a1f,x+.1,y+.1,z,{emissive:0xff7a10,ei:1.4,op:.75,noshadow:true});
 E.sphere(1.35*s,0xff4a1a,x-.15,y+.2,z-.1,{emissive:0xff3a10,ei:.8,op:.4,noshadow:true});
 E.sphere(.5*s,0x444444,x+.5*s,y+.9*s,z-.2,{op:.8,noshadow:true});E.sphere(.65*s,0x333333,x-.3*s,y+1.3*s,z,{op:.7,noshadow:true});
}
export function stars(n,t=5){return '★'.repeat(n)+'<span style="opacity:.35">'+'★'.repeat(t-n)+'</span>';}
