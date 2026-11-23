extends SceneTree
const MAXTEX := 512
func shrink(tex: Texture2D) -> Texture2D:
	if tex == null: return null
	var img: Image = tex.get_image()
	if img == null: return null
	if img.is_compressed(): img.decompress()
	var w := img.get_width(); var h := img.get_height()
	var m: int = max(w, h)
	if m > MAXTEX:
		var s := float(MAXTEX) / float(m)
		img.resize(max(1, int(w * s)), max(1, int(h * s)), Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)
func conv(path: String, outname: String):
	var ps = load(path)
	if ps == null: print("FAIL load ", path); return
	var root: Node = ps.instantiate()
	var stack := [root]
	var cache := {}
	while stack.size() > 0:
		var x = stack.pop_back()
		for c in x.get_children(): stack.append(c)
		if x is MeshInstance3D and x.mesh:
			for s in range(x.mesh.get_surface_count()):
				var m = x.get_active_material(s)
				if m is BaseMaterial3D:
					var nm: BaseMaterial3D = m.duplicate()
					var key = m.albedo_texture
					if key != null and cache.has(key): nm.albedo_texture = cache[key]
					else:
						var t = shrink(m.albedo_texture)
						if key != null: cache[key] = t
						nm.albedo_texture = t
					nm.normal_enabled = false; nm.normal_texture = null
					nm.roughness_texture = null; nm.metallic_texture = null; nm.ao_texture = null
					nm.emission_texture = null; nm.emission_enabled = false
					nm.metallic = 0.0; nm.roughness = 0.85
					nm.cull_mode = BaseMaterial3D.CULL_DISABLED if nm.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED else BaseMaterial3D.CULL_BACK
					x.set_surface_override_material(s, nm)
	var doc := GLTFDocument.new(); var st := GLTFState.new()
	var e = doc.append_from_scene(root, st)
	if e != OK: print("FAIL append ", path); return
	e = doc.write_to_filesystem(st, "res://out_glb/" + outname + ".glb")
	print("OK ", outname, " ", e)
	root.free()
func _init():
	for f in DirAccess.open("res://raw").get_files():
		if f.ends_with(".fbx"): conv("res://raw/" + f, f.get_basename())
	for f in DirAccess.open("res://raw2/z").get_files():
		if f.ends_with(".fbx"): conv("res://raw2/z/" + f, "z_" + f.get_basename())
	# animations
	var lib := AnimationLibrary.new()
	for f in DirAccess.open("res://raw2/a").get_files():
		if not f.ends_with(".fbx"): continue
		var ps = load("res://raw2/a/" + f)
		var n: Node = ps.instantiate()
		var ap: AnimationPlayer = null
		var st := [n]
		while st.size() > 0:
			var x = st.pop_back()
			for c in x.get_children(): st.append(c)
			if x is AnimationPlayer: ap = x
		if ap == null: print("NO ANIM ", f); continue
		for an in ap.get_animation_list():
			if an == "RESET": continue
			var a: Animation = ap.get_animation(an).duplicate()
			# lock hips horizontal root motion
			for i in range(a.get_track_count()):
				var p := str(a.track_get_path(i))
				if a.track_get_type(i) == Animation.TYPE_POSITION_3D and p.ends_with("mixamorig_Hips"):
					var k0: Vector3 = a.track_get_key_value(i, 0)
					for k in range(a.track_get_key_count(i)):
						var v: Vector3 = a.track_get_key_value(i, k)
						a.track_set_key_value(i, k, Vector3(k0.x, v.y, k0.z))
			print("ANIM ", f, " ", an, " len=", a.length, " tracks=", a.get_track_count(), " ex=", a.track_get_path(0))
			lib.add_animation(f.get_basename(), a)
			break
		n.free()
	ResourceSaver.save(lib, "res://out_anim/anims.res")
	quit()
