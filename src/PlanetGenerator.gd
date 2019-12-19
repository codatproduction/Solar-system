tool
extends MeshInstance

var triangles = []
var verticies = []
var surface_tool = null
export (int) var subdivisions = 2
export (bool) var apply_noise = false
export(bool) var update_planet = null setget _update_planet
export (float) var roughness = 1

export (int) var noise_layers = 1
export (float) var persistence = 0.5
export (float) var init_roughness = 1

var noise = OpenSimplexNoise.new()
	

func _ready():
	
	if self.mesh != null:
		_update_planet(0)
	else:
		generate_icosphere()
		subdivide_icosphere()
		generate_mesh()
	
	
func generate_icosphere():
	
	var t = (1.0 + sqrt(5.0)) / 2
	
	verticies.push_back(Vector3(-1, t, 0).normalized())
	verticies.push_back(Vector3(1, t, 0).normalized())
	verticies.push_back(Vector3(-1, -t, 0).normalized())
	verticies.push_back(Vector3(1, -t, 0).normalized())
	verticies.push_back(Vector3(0, -1, t).normalized())
	verticies.push_back(Vector3(0, 1, t).normalized())
	verticies.push_back(Vector3(0, -1, -t).normalized())
	verticies.push_back(Vector3(0, 1, -t).normalized())
	verticies.push_back(Vector3(t, 0, -1).normalized())
	verticies.push_back(Vector3(t, 0, 1).normalized())
	verticies.push_back(Vector3(-t, 0, -1).normalized())
	verticies.push_back(Vector3(-t, 0, 1).normalized())
	
	triangles.push_back(Triangle.new(0, 11, 5))
	triangles.push_back(Triangle.new(0, 5, 1))
	triangles.push_back(Triangle.new(0, 1, 7))
	triangles.push_back(Triangle.new(0, 7, 10))
	triangles.push_back(Triangle.new(0, 10, 11))
	triangles.push_back(Triangle.new(1, 5, 9))
	triangles.push_back(Triangle.new(5, 11, 4))
	triangles.push_back(Triangle.new(11, 10, 2))
	triangles.push_back(Triangle.new(10, 7, 6))
	triangles.push_back(Triangle.new(7, 1, 8))
	triangles.push_back(Triangle.new(3, 9, 4))
	triangles.push_back(Triangle.new(3, 4, 2))
	triangles.push_back(Triangle.new(3, 2, 6))
	triangles.push_back(Triangle.new(3, 6, 8))
	triangles.push_back(Triangle.new(3, 8, 9))
	triangles.push_back(Triangle.new(4, 9, 5))
	triangles.push_back(Triangle.new(2, 4, 11))
	triangles.push_back(Triangle.new(6, 2, 10))
	triangles.push_back(Triangle.new(8, 6, 7))
	triangles.push_back(Triangle.new(9, 8, 1))
	
func generate_mesh():
	surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	if apply_noise:
		randomize()
		noise.seed = randi()
		
	
	for index in triangles.size():
		var triangle = triangles[index]
		
		for i in triangle.verticies.size():
			var vertex = verticies[triangle.verticies[(triangle.verticies.size() - 1) - i]]
			if apply_noise:		
				vertex = apply_noise(vertex)
			
			surface_tool.add_vertex(vertex)
		
	surface_tool.index()
	surface_tool.generate_normals()
	
	self.mesh = surface_tool.commit()

func caclulate(vertex):
	var value = 0
	var freq = init_roughness
	var ampl = 1
	
	for i in noise_layers:
		var v = noise.get_noise_3dv(vertex * noise.period * freq)
		value += (v + 1) * 0.5 * ampl
		
		freq *= roughness
		ampl *= persistence
	
	return (value + 1) * 0.5
	
func apply_noise(vertex):
	return vertex * caclulate(vertex)
	
func subdivide_icosphere():
	
	var cache = {}
	
	for i in subdivisions:
		var new_triangle = []
		
		for triangle in triangles:
			var a = triangle.verticies[0]
			var b = triangle.verticies[1]
			var c = triangle.verticies[2]
			
			var ab = get_mid(cache, a, b)
			var bc = get_mid(cache, b, c)
			var ca = get_mid(cache, c, a)
			
			new_triangle.push_back(Triangle.new(a, ab, ca))
			new_triangle.push_back(Triangle.new(b, bc, ab))
			new_triangle.push_back(Triangle.new(c, ca, bc))
			new_triangle.push_back(Triangle.new(ab, bc, ca))
		
		triangles = new_triangle
	
	
func get_mid(cache : Dictionary, a, b):
	var smaller = min(a, b)
	var greater = max(a, b)
	var key = (smaller << 16) + greater
	
	if cache.has(key):
		return cache.get(key)
	
	var p1 = verticies[a]
	var p2 = verticies[b]
	var middle = lerp(p1, p2, 0.5).normalized()
	var ret = verticies.size()
	verticies.push_back(middle)
	cache[key] = ret
	return ret


class Triangle:
	var verticies = []
	func _init(a, b, c):
		verticies.push_back(a)
		verticies.push_back(b)
		verticies.push_back(c)
		
func _update_planet(value):
	self.mesh = null
	triangles.clear()
	verticies.clear()
	generate_icosphere()
	subdivide_icosphere()
	generate_mesh()

