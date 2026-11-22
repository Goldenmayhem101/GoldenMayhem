import sys
from PIL import Image
names=sys.argv[2:];out=sys.argv[1]
ims=[Image.open(f'out/{n}.png').resize((540,960)) for n in names]
s=Image.new('RGB',(540*len(ims),960));[s.paste(im,(i*540,0)) for i,im in enumerate(ims)];s.save(f'out/{out}.png')
