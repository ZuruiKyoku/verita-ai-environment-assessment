extends RigidBody3D # Ensure this is a RigidBody3D to use apply_central_impulse

@onready var box_small = $"box-small"
@onready var outline_mesh = $"box-small/box_small/MeshInstance3D"

var lookedAt: bool = false
var picked: bool = false
var outlineWidth = 0.05

func _ready():
	add_to_group("boxes")
	# Ensure the box starts by detecting Layer 2 (Player)
	set_collision_mask_value(2, true)

func _process(_delta):
	# Handle outline visibility
	outline_mesh.visible = lookedAt and not picked 
	
	# Keep visual offset if picked 
	if picked: 
		box_small.position.y = outlineWidth
		# Keep physics in sync with the CarryLocation
		global_transform = get_parent().global_transform
	else: 
		box_small.position.y = 0

func set_looked_at(boolean: bool):
	lookedAt = boolean

func set_picked(boolean: bool):
	picked = boolean
	if picked:
		# Disable collision WITH the player (Layer 2)
		set_collision_mask_value(2, false)
		freeze = true 
	else:
		# Re-enable collision WITH the player
		set_collision_mask_value(2, true)
		freeze = false
