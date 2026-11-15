import math
C={'r':'#F0343E','g':'#2FD34E','b':'#2F86FF','y':'#FFC82A'}
def die(cx,cy,s,rot=0,pips=5,idp=''):
    # white rounded die centred at cx,cy, side s
    h=s/2; r=s*0.2; u=s/4.2
    pos={5:[(-1,-1,'r'),(1,-1,'g'),(0,0,'gold'),(-1,1,'b'),(1,1,'y')],
         4:[(-1,-1,'r'),(1,-1,'g'),(-1,1,'b'),(1,1,'y')],
         6:[(-1,-1,'r'),(1,-1,'g'),(-1,0,'b'),(1,0,'y'),(-1,1,'r'),(1,1,'g')],
         3:[(-1,-1,'r'),(0,0,'gold'),(1,1,'b')]}[pips]
    o=f'<g transform="translate({cx} {cy}) rotate({rot})">'
    o+=f'<rect x="{-h+s*.03}" y="{-h+s*.05}" width="{s}" height="{s}" rx="{r}" fill="#000" opacity=".28"/>'
    o+=f'<rect x="{-h}" y="{-h}" width="{s}" height="{s}" rx="{r}" fill="#fff" stroke="#0A0F3A" stroke-width="{s*.03}"/>'
    o+=f'<rect x="{-h+s*.05}" y="{-h+s*.05}" width="{s*.9}" height="{s*.38}" rx="{r*.8}" fill="#e9edff" opacity=".7"/>'
    for dx,dy,c in pos:
        col='#FFD23F' if c=='gold' else C[c]
        st='#B87A10' if c=='gold' else '#0A0F3A'
        o+=f'<circle cx="{dx*u*1.4}" cy="{dy*u*1.4}" r="{u*.44}" fill="{col}" stroke="{st}" stroke-width="{s*.012}"/>'
    return o+'</g>'
def tiles(ox,oy,sc,op=1):
    o=f'<g transform="translate({ox} {oy}) scale({sc})" opacity="{op}">'
    for (x,y,c) in [(60,60,'r'),(276,60,'g'),(60,276,'b'),(276,276,'y')]:
        o+=f'<rect x="{x}" y="{y}" width="176" height="176" rx="38" fill="{C[c]}" stroke="#fff" stroke-width="8"/><rect x="{x+8}" y="{y+8}" width="160" height="70" rx="30" fill="#fff" opacity=".22"/>'
    return o+'</g>'
GR='<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#1B2480"/><stop offset="1" stop-color="#070B2E"/></linearGradient></defs>'
def sparkle(x,y,s,op=1):
    return f'<path d="M{x} {y-s} L{x+s*.28} {y-s*.28} L{x+s} {y} L{x+s*.28} {y+s*.28} L{x} {y+s} L{x-s*.28} {y+s*.28} L{x-s} {y} L{x-s*.28} {y-s*.28}Z" fill="#FFD23F" opacity="{op}"/>'
# icon 512 (full bleed)
icon=f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">{GR}<rect width="512" height="512" fill="url(#g)"/>{tiles(0,0,1,.55)}<rect width="512" height="512" fill="#070B2E" opacity=".35"/>{die(256,262,270,-9)}{sparkle(98,100,26)}{sparkle(420,420,20,.9)}</svg>'
open('icon.svg','w').write(icon)
# adaptive layers 432
bg=f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 432 432">{GR}<rect width="432" height="432" fill="url(#g)"/>{tiles(-6,-6,.86,.55)}<rect width="432" height="432" fill="#070B2E" opacity=".35"/></svg>'
fg=f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 432 432">{die(216,220,196,-9)}{sparkle(120,120,18)}{sparkle(318,320,14,.9)}</svg>'
open('bg.svg','w').write(bg); open('fg.svg','w').write(fg)
# feature graphic
import random; random.seed(7)
stars=''.join(f'<circle cx="{random.randint(0,1024)}" cy="{random.randint(0,500)}" r="{random.choice([1.5,2,3])}" fill="#fff" opacity="{random.choice([.3,.5,.8])}"/>' for _ in range(70))
ft=f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 500">{GR}<rect width="1024" height="500" fill="url(#g)"/>{stars}
{tiles(600,10,.9,.5)}{die(838,262,200,-11)}{die(700,360,120,14,4)}{die(960,120,90,18,3)}{sparkle(610,90,22)}{sparkle(985,330,18)}
<text x="60" y="215" font-family="'Baloo 2'" font-weight="800" font-size="150" fill="#fff" stroke="#0A0F3A" stroke-width="10" paint-order="stroke">Ludora</text>
<text x="66" y="290" font-family="Nunito" font-weight="800" font-size="48" fill="#FFD23F">Fair Play Dice Game</text>
<text x="66" y="350" font-family="Nunito" font-weight="700" font-size="30" fill="#cfd6ff">Roll. Race. Win.</text></svg>'''
open('feature.svg','w').write(ft)
