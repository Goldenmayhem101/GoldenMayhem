import json, sys, numpy as np, cv2
from PIL import Image
from scipy import ndimage
SRC='/home/user/goldenmayhem/new-game/animal-warriors/Standalone_Warriors/'
OUT=sys.argv[1]; SCALE=0.5
spec=json.load(open('rigspec.json'))
import os; os.makedirs(OUT,exist_ok=True)
manifest={}
for name,v in spec.items():
    a=np.asarray(Image.open(SRC+v['src']).convert('RGB')).astype(np.int32); H,W=a.shape[:2]
    bg=a[5,5]; d=np.abs(a-bg).sum(2)
    light=d<45
    lab,n=ndimage.label(light); edge=np.unique(np.concatenate([lab[0],lab[-1],lab[:,0],lab[:,-1]]))
    szl=ndimage.sum(light,lab,range(n+1))
    isbg=np.isin(np.arange(n+1),edge[edge>0])|(szl>1500); isbg[0]=False
    fg=~isbg[lab]
    # remove ground shadow: low-saturation pixels below shadow_y
    sat=a.max(2)-a.min(2); lum=a.mean(2); yy=np.arange(H)[:,None]
    shadow=(yy>v['shadow_y'])&(sat<38)&(lum>35)
    fg&=~shadow
    fg=ndimage.binary_opening(fg,iterations=2)
    lab2,n2=ndimage.label(fg); sz=ndimage.sum(fg,lab2,range(n2+1)); sz[0]=0
    fg=lab2==sz.argmax()  # main body only
    
    union=np.zeros((H,W),bool); parts={}
    for pn,p in v['parts'].items():
        m=np.zeros((H,W),np.uint8); cv2.fillPoly(m,[np.array(p['poly'],np.int32)],1)
        pm=(m>0)&fg; union|=m>0; parts[pn]=pm
    body=fg&~union
    lb,nb=ndimage.label(body); sb=ndimage.sum(body,lb,range(nb+1)); sb[0]=0; main=sb.argmax()
    for i in range(1,nb+1):
        if i==main: continue
        comp=lb==i; ring=ndimage.binary_dilation(comp,iterations=6)
        best=max(parts,key=lambda k:(parts[k]&ring).sum())
        if (parts[best]&ring).sum()>0: parts[best]|=comp
        body&=~comp
    # inpaint the body where limbs were removed, within reach of the torso
    near=ndimage.binary_dilation(body,iterations=28)&union&ndimage.binary_dilation(fg,iterations=2)
    img=a.astype(np.uint8)[:,:,::-1].copy()
    holes=(~body).astype(np.uint8)*255
    filled=cv2.inpaint(img,holes,9,cv2.INPAINT_TELEA)[:,:,::-1]
    bodymask=body|near
    def save(rgb,mask,fn):
        alpha=(ndimage.gaussian_filter(mask.astype(float),0.8)*255).astype(np.uint8)
        im=Image.fromarray(np.dstack([rgb.astype(np.uint8),alpha]),'RGBA')
        bb=im.getbbox(); im=im.crop(bb)
        im=im.resize((max(1,int(im.width*SCALE)),max(1,int(im.height*SCALE))),Image.LANCZOS)
        im.save(fn); return bb
    rgb=a.astype(np.uint8); comp=np.where(near[:,:,None],filled,rgb)
    bb=save(comp,bodymask,f'{OUT}/{name}_body.png')
    # feet bottom = ground reference
    ys=np.where(fg.any(1))[0]; ground=ys.max()
    man={'scale':SCALE,'ground_y':ground,'parts':{'body':{'file':f'{name}_body.png','origin':[bb[0],bb[1]],'z':0,'parent':None,'pivot':[(bb[0]+bb[2])/2,(bb[1]+bb[3])/2]}}}
    for pn,p in v['parts'].items():
        bb=save(rgb,parts[pn],f'{OUT}/{name}_{pn}.png')
        man['parts'][pn]={'file':f'{name}_{pn}.png','origin':[bb[0],bb[1]],'z':p['z'],'parent':p['parent'],'pivot':p['pivot']}
    manifest[name]=man
json.dump(manifest,open(f'{OUT}/rig.json','w'),indent=1,default=int)
print('ok')
