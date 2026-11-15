"""Give a bone-only GLB (no skin) a skin + tiny proxy mesh so engines build a skeleton from it."""
import sys, json, struct
import numpy as np
def q2m(q):
    x, y, z, w = q
    return np.array([[1-2*(y*y+z*z), 2*(x*y-z*w), 2*(x*z+y*w)], [2*(x*y+z*w), 1-2*(x*x+z*z), 2*(y*z-x*w)], [2*(x*z-y*w), 2*(y*z+x*w), 1-2*(x*x+y*y)]])
def local(n):
    m = np.eye(4); m[:3, :3] = q2m(n.get('rotation', [0, 0, 0, 1])) @ np.diag(n.get('scale', [1, 1, 1])); m[:3, 3] = n.get('translation', [0, 0, 0]); return m
src, dst = sys.argv[1:3]
d = open(src, 'rb').read()
jl = struct.unpack('<I', d[12:16])[0]; j = json.loads(d[20:20+jl])
bl = struct.unpack('<I', d[20+jl:24+jl])[0]; buf = bytearray(d[28+jl:28+jl+bl])
nodes = j['nodes']
parent = {}
for i, n in enumerate(nodes):
    for c in n.get('children', []): parent[c] = i
names = [n.get('name', '') for n in nodes]
root = names.index('root') if 'root' in names else names.index('pelvis')
joints = []
def walk(i):
    joints.append(i)
    for c in nodes[i].get('children', []): walk(c)
walk(root)
# optional: replace each joint's rest with the bind pose from a reference GLB (sys.argv[3])
if len(sys.argv) > 3:
    rd = open(sys.argv[3], 'rb').read(); rl = struct.unpack('<I', rd[12:16])[0]; rj = json.loads(rd[20:20+rl])
    rb = rd[28+rl:]
    sk = max(rj['skins'], key=lambda s: len(s['joints'])); acc = rj['accessors'][sk['inverseBindMatrices']]; bv = rj['bufferViews'][acc['bufferView']]
    ib = np.frombuffer(rb[bv.get('byteOffset', 0)+acc.get('byteOffset', 0):][:64*acc['count']], dtype=np.float32).reshape(-1, 4, 4)
    W = {rj['nodes'][jn]['name']: np.linalg.inv(ib[k].T) for k, jn in enumerate(sk['joints'])}
    from scipy.spatial.transform import Rotation as Rot
    def setrest(i, pw):
        n = nodes[i]; nm = n.get('name')
        if nm in W:
            w = W[nm]
            loc = np.linalg.inv(pw) @ w
            n['translation'] = loc[:3, 3].tolist()
            r = loc[:3, :3] / np.linalg.norm(loc[:3, :3], axis=0)
            n['rotation'] = Rot.from_matrix(r).as_quat().tolist(); n.pop('scale', None)
        else:
            w = pw @ local(n)
        for c in n.get('children', []): setrest(c, w)
    pw = np.eye(4); p = parent.get(root)
    chainp = []
    while p is not None: chainp.insert(0, p); p = parent.get(p)
    for q in chainp: pw = pw @ local(nodes[q])
    setrest(root, pw)
def world(i):
    m = local(nodes[i]); p = parent.get(i)
    while p is not None: m = local(nodes[p]) @ m; p = parent.get(p)
    return m
def add(arr, typ, ctype=5126, dtype=np.float32):
    a = np.asarray(arr, dtype=dtype); off = len(buf); buf.extend(a.tobytes())
    while len(buf) % 4: buf.append(0)
    j['bufferViews'].append({'buffer': 0, 'byteOffset': off, 'byteLength': a.nbytes})
    j['accessors'].append({'bufferView': len(j['bufferViews'])-1, 'componentType': ctype, 'count': len(a), 'type': typ}); return len(j['accessors'])-1
ibm = add([np.linalg.inv(world(i)).T.flatten() for i in joints], 'MAT4')
pos = add([[0, 0, 0], [0.01, 0, 0], [0, 0.01, 0]], 'VEC3'); j['accessors'][pos]['min'] = [0, 0, 0]; j['accessors'][pos]['max'] = [0.01, 0.01, 0]
ja = add(np.zeros((3, 4)), 'VEC4', 5123, np.uint16)
wt = add([[1, 0, 0, 0]]*3, 'VEC4')
j.setdefault('meshes', []).append({'primitives': [{'attributes': {'POSITION': pos, 'JOINTS_0': ja, 'WEIGHTS_0': wt}}]})
j.setdefault('skins', []).append({'joints': joints, 'inverseBindMatrices': ibm})
nodes.append({'name': 'Proxy', 'mesh': len(j['meshes'])-1, 'skin': len(j['skins'])-1})
j['scenes'][j.get('scene', 0)]['nodes'].append(len(nodes)-1)
j['buffers'] = [{'byteLength': len(buf)}]
js = json.dumps(j).encode()
while len(js) % 4: js += b' '
out = struct.pack('<III', 0x46546C67, 2, 12+8+len(js)+8+len(buf)) + struct.pack('<II', len(js), 0x4E4F534A) + js + struct.pack('<II', len(buf), 0x004E4942) + bytes(buf)
open(dst, 'wb').write(out)
