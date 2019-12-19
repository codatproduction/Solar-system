extends Spatial

export (float) var planet_rotation_speed = 1.0
export (float) var moon_rotation_speed = 0.5

func _ready():
	add_to_group("Planet")

func _process(delta):
	$Mass.rotate_object_local(Vector3(0, 1, 0), planet_rotation_speed * delta)
	$MoonContainer.rotate_y(moon_rotation_speed * delta)
