extends RigidBody3D

@onready var mesh_instance = $MeshInstance3D

var active_color = Color.GREEN
var inactive_color = Color.RED
var is_pressed = false

func _ready():
	set_button_color(inactive_color)

func _on_body_entered(body: Node3D):
	if body.is_in_group("boxes") and not is_pressed:
		press_button()

func press_button():
	is_pressed = true
	set_button_color(active_color)

func set_button_color(new_color: Color):
	var material = mesh_instance.get_active_material(0).duplicate()
	material.albedo_color = new_color
	mesh_instance.set_surface_override_material(0, material)
