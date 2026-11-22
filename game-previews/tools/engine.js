import * as THREE from 'three';
import {GLTFLoader} from 'three/addons/loaders/GLTFLoader.js';
import {OBJLoader} from 'three/addons/loaders/OBJLoader.js';
import * as SU from 'three/addons/utils/SkeletonUtils.js';
export {THREE};
const GL=new GLTFLoader();const cache={};
const KEN='/assets/kenney/';
export async function makeEngine(opt={}){
  const W=540,H=960;
  const r=new THREE.WebGLRenderer({antialias:true,preserveDrawingBuffer:true});
  r.setSize(W,H);r.setPixelRatio(2);r.shadowMap.enabled=true;r.shadowMap.type=THREE.PCFSoftShadowMap;
  r.toneMapping=THREE.ACESFilmicToneMapping;r.toneMappingExposure=1.05;r.outputColorSpace=THREE.SRGBColorSpace;
  document.getElementById('c').appendChild(r.domElement);
  const scene=new THREE.Scene();
  scene.background=new THREE.Color(opt.sky||0x9fd8ff);
  if(opt.fog!==false)scene.fog=new THREE.Fog(opt.fogColor||opt.sky||0x9fd8ff,opt.fogNear||14,opt.fogFar||40);
  scene.add(new THREE.HemisphereLight(0xffffff,opt.ground||0x6a8f4e,opt.hemi||1.25));
  const sun=new THREE.DirectionalLight(0xfff2d6,opt.sun||2.4);sun.position.set(opt.sunx||-8,opt.suny||14,opt.sunz||6);sun.castShadow=true;
  const ex=opt.shadowSize||14;Object.assign(sun.shadow.camera,{left:-ex,right:ex,top:ex,bottom:-ex,near:1,far:60});
  sun.shadow.mapSize.set(2048,2048);sun.shadow.bias=-0.0004;scene.add(sun);scene.add(sun.target);
  const cam=new THREE.PerspectiveCamera(opt.fov||45,W/H,0.1,200);
  const E={THREE,r,scene,cam,sun,mixers:[]};
  E.cam_=(p,t,fov)=>{cam.position.set(...p);cam.lookAt(...t);if(fov){cam.fov=fov;}cam.updateProjectionMatrix();sun.target.position.set(t[0],0,t[2]);};
  E.load=async(kit,name)=>{const key=kit+'/'+name;if(!cache[key]){
    if(kit.startsWith('A:')){ // other packs: path under assets
      cache[key]=await GL.loadAsync('/assets/'+kit.slice(2)+'/'+name);
    } else cache[key]=await GL.loadAsync(KEN+kit+'/'+name+'.glb');}
    return cache[key];};
  // place: returns Group whose origin is base-center
  E.obj=async(kit,name,o={})=>{
    const g=await E.load(kit,name);const inner=SU.clone(g.scene);
    inner.traverse(m=>{if(m.isMesh){m.castShadow=true;m.receiveShadow=true;if(m.material&&o.tint){m.material=m.material.clone();m.material.color.multiply(new THREE.Color(o.tint));}}});
    const grp=new THREE.Group();grp.add(inner);
    if(o.anim!==undefined&&g.animations.length){const mx=new THREE.AnimationMixer(inner);
      const clip=typeof o.anim==='string'?(g.animations.find(c=>c.name.toLowerCase().includes(o.anim))||g.animations[0]):g.animations[o.anim];
      const a=mx.clipAction(clip);a.play();mx.setTime(o.t||0.3);E.mixers.push(mx);}
    let box=new THREE.Box3().setFromObject(inner);let sz=box.getSize(new THREE.Vector3());
    let s=o.s||1;if(o.len)s=o.len/Math.max(sz.x,sz.z);if(o.h)s=o.h/sz.y;if(o.w)s=o.w/sz.x;if(o.big)s=o.big/Math.max(sz.x,sz.y,sz.z);
    inner.scale.multiplyScalar(s);box=new THREE.Box3().setFromObject(inner);const c=box.getCenter(new THREE.Vector3());
    inner.position.set(-c.x,-box.min.y,-c.z);
    grp.position.set(o.x||0,o.y||0,o.z||0);grp.rotation.set(o.rx||0,o.ry||0,o.rz||0);
    scene.add(grp);return grp;};
  E.ground=(color,w=60,l=120,y=0,cx=0,cz=0)=>{const m=new THREE.Mesh(new THREE.PlaneGeometry(w,l),new THREE.MeshStandardMaterial({color,roughness:1}));m.rotation.x=-Math.PI/2;m.position.set(cx,y,cz);m.receiveShadow=true;scene.add(m);return m;};
  E.box=(w,h,d,color,x,y,z,o={})=>{const m=new THREE.Mesh(new THREE.BoxGeometry(w,h,d),new THREE.MeshStandardMaterial({color,roughness:o.rough??0.7,metalness:o.metal||0,emissive:o.emissive||0,emissiveIntensity:o.ei||0}));m.position.set(x,y,z);m.castShadow=true;m.receiveShadow=true;if(o.ry)m.rotation.y=o.ry;scene.add(m);return m;};
  E.hud=(html)=>{document.getElementById('hud').innerHTML=html;};
  E.labels=[];
  E.label=(text,p,css='')=>{E.labels.push({text,p,css});};
  E.ribbon=(pts,width,color,y=0.01,o={})=>{const c=new THREE.CatmullRomCurve3(pts.map(p=>new THREE.Vector3(p[0],0,p[1])));
    const N=o.n||120;const pos=[],idx=[];for(let i=0;i<=N;i++){const t=i/N;const p=c.getPoint(t);const tg=c.getTangent(t);const nx=-tg.z,nz=tg.x;
      pos.push(p.x+nx*width/2,y,p.z+nz*width/2,p.x-nx*width/2,y,p.z-nz*width/2);if(i<N){const a=i*2;idx.push(a,a+1,a+2,a+1,a+3,a+2);}}
    const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));g.setIndex(idx);g.computeVertexNormals();
    const m=new THREE.Mesh(g,new THREE.MeshStandardMaterial({color,roughness:o.rough??0.9,side:THREE.DoubleSide,emissive:o.emissive||0,emissiveIntensity:o.ei||0}));m.receiveShadow=true;scene.add(m);m.userData.curve=c;return m;};
  E.curve=(pts)=>new THREE.CatmullRomCurve3(pts.map(p=>new THREE.Vector3(p[0],0,p[1])));
  E.sphere=(rad,color,x,y,z,o={})=>{const m=new THREE.Mesh(new THREE.SphereGeometry(rad,24,16),new THREE.MeshStandardMaterial({color,roughness:o.rough??0.5,emissive:o.emissive||0,emissiveIntensity:o.ei||0,transparent:!!o.op,opacity:o.op||1}));m.position.set(x,y,z);m.castShadow=!o.noshadow;scene.add(m);return m;};
  E.obj3=async(objUrl,texUrl,o={})=>{const {OBJLoader}=await import('three/addons/loaders/OBJLoader.js');const ol=new OBJLoader();const g=await ol.loadAsync(objUrl);
    const tex=await new THREE.TextureLoader().loadAsync(texUrl);tex.colorSpace=THREE.SRGBColorSpace;tex.flipY=true;
    g.traverse(m=>{if(m.isMesh){m.material=new THREE.MeshStandardMaterial({map:tex,roughness:.8});m.castShadow=true;m.receiveShadow=true;}});
    const grp=new THREE.Group();grp.add(g);let box=new THREE.Box3().setFromObject(g);let sz=box.getSize(new THREE.Vector3());
    let sc=o.s||1;if(o.h)sc=o.h/sz.y;if(o.big)sc=o.big/Math.max(sz.x,sz.y,sz.z);g.scale.multiplyScalar(sc);box=new THREE.Box3().setFromObject(g);const c=box.getCenter(new THREE.Vector3());g.position.set(-c.x,-box.min.y,-c.z);
    grp.position.set(o.x||0,o.y||0,o.z||0);grp.rotation.set(o.rx||0,o.ry||0,o.rz||0);scene.add(grp);return grp;};
  E.done=async()=>{await new Promise(r=>setTimeout(r,400));cam.updateMatrixWorld();r.render(scene,cam);r.render(scene,cam);
    const hud=document.getElementById('hud');for(const l of E.labels){const v=new THREE.Vector3(...l.p).project(cam);const x=(v.x*0.5+0.5)*W,y=(-v.y*0.5+0.5)*H;
      const d=document.createElement('div');d.style.cssText='position:absolute;transform:translate(-50%,-50%);white-space:nowrap;left:'+x+'px;top:'+y+'px;'+l.css;d.className='stroke';d.innerHTML=l.text;hud.appendChild(d);}
    window.__done=true;};
  return E;
}
export const sleep=ms=>new Promise(r=>setTimeout(r,ms));
