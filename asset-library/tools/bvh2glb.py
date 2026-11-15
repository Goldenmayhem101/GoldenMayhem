"""Convert a BVH (CMU MotionBuilder-friendly release) into a GLB with a skeleton and one animation.
Frame 1 (T-pose) becomes the rest pose. Resampled to 30 fps. Units scaled to metres (hips ~0.95 m)."""
import sys, json, struct, math
import numpy as np

def parse(path):
    tok = open(path).read().split()
    i = 0; joints = []; stack = []
    def nxt():
        nonlocal i; i += 1; return tok[i-1]
    assert nxt() == 'HIERARCHY'
    while True:
        t = nxt()
        if t in ('ROOT', 'JOINT'):
            name = nxt(); j = {'name': name, 'parent': stack[-1] if stack else -1}
            joints.append(j); stack.append(len(joints)-1)
        elif t == 'End':
            nxt(); stack.append(None)
        elif t == '{': pass
        elif t == '}':
            stack.pop()
        elif t == 'OFFSET':
            o = [float(nxt()) for _ in range(3)]
            if stack[-1] is not None: joints[stack[-1]]['off'] = o
        elif t == 'CHANNELS':
            n = int(nxt()); joints[stack[-1]]['ch'] = [nxt() for _ in range(n)]
        elif t == 'MOTION':
            break
    nxt(); nf = int(nxt()); nxt(); nxt(); ft = float(nxt())
    data = np.array([float(x) for x in tok[i:]], dtype=np.float64).reshape(nf, -1)
    return joints, data, ft

def qaxis(ax, deg):
    h = math.radians(deg) / 2
    v = {'X': (1, 0, 0), 'Y': (0, 1, 0), 'Z': (0, 0, 1)}[ax]
    return np.array([v[0]*math.sin(h), v[1]*math.sin(h), v[2]*math.sin(h), math.cos(h)])

def qmul(a, b):
    ax, ay, az, aw = a; bx, by, bz, bw = b
    return np.array([aw*bx+ax*bw+ay*bz-az*by, aw*by-ax*bz+ay*bw+az*bx, aw*bz+ax*by-ay*bx+az*bw, aw*bw-ax*bx-ay*by-az*bz])

def main(src, dst, t0=None, t1=None):
    joints, data, ft = parse(src)
    # scale: hips height from T-pose leg offsets
    col = 0
    for j in joints:
        j['col'] = col; col += len(j.get('ch', []))
    step = max(1, round((1/30) / ft))
    frames = list(range(0, len(data), step))
    if t0 is not None:
        frames = [0] + [f for f in frames if t0 <= f*ft <= t1]
    S = 0.0254 * 1.0  # CMU BVH units are ~inches*? -> tuned below
    # normalise: total leg length -> 0.9 m
    def chain(n):
        L = 0; k = next(x for x, j in enumerate(joints) if j['name'] == n)
        return k
    leg = sum(np.linalg.norm(joints[chain(n)]['off']) for n in ('LeftLeg', 'LeftFoot'))
    S = 0.88 / leg
    nodes = []; anim_r = {}; anim_t = []
    for k, j in enumerate(joints):
        nd = {'name': j['name'], 'translation': [x*S for x in j['off']]}
        nodes.append(nd)
    for k, j in enumerate(joints):
        ch = [c for c in joints[k]['children']] if 'children' in j else None
    kids = {k: [] for k in range(len(joints))}
    for k, j in enumerate(joints):
        if j['parent'] >= 0: kids[j['parent']].append(k)
    for k in kids:
        if kids[k]: nodes[k]['children'] = kids[k]
    times = []
    for n, f in enumerate(frames):
        times.append(n / 30.0)
        row = data[f]
        for k, j in enumerate(joints):
            q = np.array([0, 0, 0, 1.0])
            for ci, c in enumerate(j['ch']):
                if c.endswith('rotation'):
                    q = qmul(q, qaxis(c[0], row[j['col']+ci]))
            anim_r.setdefault(k, []).append(q)
            if k == 0:
                p = [row[j['col']+ci] * S for ci, c in enumerate(j['ch']) if c.endswith('position')]
                anim_t.append(p)
    # first sample = T-pose frame: use as rest (identity rotations already), drop it from the clip
    times = [t - times[1] for t in times[1:]] if len(times) > 1 else times
    tpose_r = {k: anim_r[k][0] for k in anim_r}
    for k in anim_r: anim_r[k] = anim_r[k][1:]
    hip0 = anim_t[0]; anim_t = anim_t[1:]
    nodes[0]['translation'] = hip0
    # build buffers
    buf = bytearray(); views = []; accs = []
    def add(arr, typ, minmax=False):
        a = np.asarray(arr, dtype=np.float32); off = len(buf); buf.extend(a.tobytes())
        while len(buf) % 4: buf.append(0)
        views.append({'buffer': 0, 'byteOffset': off, 'byteLength': a.nbytes})
        acc = {'bufferView': len(views)-1, 'componentType': 5126, 'count': len(a), 'type': typ}
        if minmax: acc['min'] = [float(a.min())]; acc['max'] = [float(a.max())]
        accs.append(acc); return len(accs)-1
    ti = add(times, 'SCALAR', True)
    samplers = []; channels = []
    for k in anim_r:
        samplers.append({'input': ti, 'output': add(anim_r[k], 'VEC4'), 'interpolation': 'LINEAR'})
        channels.append({'sampler': len(samplers)-1, 'target': {'node': k, 'path': 'rotation'}})
    samplers.append({'input': ti, 'output': add(anim_t, 'VEC3'), 'interpolation': 'LINEAR'})
    channels.append({'sampler': len(samplers)-1, 'target': {'node': 0, 'path': 'translation'}})
    # one-key 'tpose' animation from frame 1 (the reference pose for retargeting)
    t2 = add([0.0, 0.1], 'SCALAR', True); ts = []; tc = []
    for k in tpose_r:
        ts.append({'input': t2, 'output': add([tpose_r[k], tpose_r[k]], 'VEC4'), 'interpolation': 'LINEAR'})
        tc.append({'sampler': len(ts)-1, 'target': {'node': k, 'path': 'rotation'}})
    # skin so Godot makes a Skeleton3D
    nj = len(joints)
    G = [None]*nj
    for k in range(nj):
        t = np.array(nodes[k]['translation']); p = joints[k]['parent']
        G[k] = t if p < 0 else G[p] + t
    ibm = []
    for k in range(nj):
        m = np.eye(4, dtype=np.float32); m[3, :3] = -G[k]; ibm.append(m.flatten())
    ib = add(ibm, 'MAT4')
    root_node = {'name': 'Armature', 'children': [0]}
    nodes.append(root_node)
    # tiny dummy mesh bound to the skin (Godot needs a skinned mesh to build a Skeleton3D)
    pos = add([[0, 0, 0], [0.01, 0, 0], [0, 0.01, 0]], 'VEC3'); accs[pos]['min'] = [0, 0, 0]; accs[pos]['max'] = [0.01, 0.01, 0]
    jn = np.zeros((3, 4), dtype=np.uint16); off = len(buf); buf.extend(jn.tobytes())
    while len(buf) % 4: buf.append(0)
    views.append({'buffer': 0, 'byteOffset': off, 'byteLength': jn.nbytes}); accs.append({'bufferView': len(views)-1, 'componentType': 5123, 'count': 3, 'type': 'VEC4'}); ja = len(accs)-1
    wt = add([[1, 0, 0, 0]]*3, 'VEC4')
    nodes.append({'name': 'Proxy', 'mesh': 0, 'skin': 0})
    g = {'asset': {'version': '2.0'}, 'scene': 0, 'scenes': [{'nodes': [nj, nj+1]}], 'nodes': nodes,
         'skins': [{'joints': list(range(nj)), 'inverseBindMatrices': ib, 'skeleton': 0}],
         'meshes': [{'primitives': [{'attributes': {'POSITION': pos, 'JOINTS_0': ja, 'WEIGHTS_0': wt}}]}],
         'animations': [{'name': 'clip', 'samplers': samplers, 'channels': channels}, {'name': 'tpose', 'samplers': ts, 'channels': tc}],
         'accessors': accs, 'bufferViews': views, 'buffers': [{'byteLength': len(buf)}]}
    js = json.dumps(g).encode()
    while len(js) % 4: js += b' '
    out = struct.pack('<III', 0x46546C67, 2, 12 + 8 + len(js) + 8 + len(buf))
    out += struct.pack('<II', len(js), 0x4E4F534A) + js + struct.pack('<II', len(buf), 0x004E4942) + bytes(buf)
    open(dst, 'wb').write(out)
    print(dst, len(times), 'frames')

if __name__ == '__main__':
    a = sys.argv
    main(a[1], a[2], *(float(x) for x in a[3:5])) if len(a) > 3 else main(a[1], a[2])
