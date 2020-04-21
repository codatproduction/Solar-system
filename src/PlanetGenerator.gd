tool
extends MeshInstance

var triangles = []
var verticies = []


export (int, 0, 6) var subdivisions = 2 setget set_subdivisions
export (float) var roughness = 1 setget set_roughness
export (float) var radius = 1.0 setget set_radius
export (OpenSimplexNoise) var noise = null
export (bool) var update_noise = false setget update_noise




func _ready():
	randomize()
	
	triangles.clear()
	verticies.clear()
	mesh = null
	
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
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)	
	
	for index in triangles.size():
		var triangle = triangles[index]
		
		for i in triangle.verticies.size():
			var vertex = verticies[triangle.verticies[(triangle.verticies.size() - 1) - i]]
			if noise != null:
				vertex = vertex.normalized() * ((noise.get_noise_3dv(vertex * noise.period * noise.octaves) + 1) * 0.5)
				
			surface_tool.add_vertex(vertex * radius)
		
	surface_tool.index()
	surface_tool.generate_normals()
	
	var t = MeshDataTool.new()
	t.create_from_surface(surface_tool.commit(), 0)
	self.mesh = surface_tool.commit()

	
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
		pass
	
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
		

func set_subdivisions(value):
	subdivisions = value
	_ready()
	
	
func set_roughness(value):
	roughness = value
	_ready()

func set_radius(value):
	radius = value
	_ready()

func update_noise(value):
	_ready()
