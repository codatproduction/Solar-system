extends Spatial

onready var orbits = $Sun/Orbits

var orbits_speed = []
	

func _ready():
	randomize()
	
	$Player.connect("stop_system", self, "on_stop_system")
	
	for i in orbits.get_child_count():
		orbits_speed.push_back(rand_range(0.005, 0.01))
		var orbit = orbits.get_child(i)
		orbit.rotate_y(deg2rad(rand_range(0, 360)))
		


func _process(delta):
	for i in orbits.get_child_count():
		var orbit = orbits.get_child(i)
		orbit.rotate_y(orbits_speed[i] * delta)


func on_stop_system():
	set_process(!is_processing())
	
