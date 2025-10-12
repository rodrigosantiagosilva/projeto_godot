extends Node2D

const SPEED := 300
var shooter: CharacterBody2D = null
var has_hit := false

# Layers: ajuste para as layers de inimigo (por exemplo 0) e cenário (por exemplo 1)
const COLLISION_MASK := (1 << 0) | (1 << 1)

func _process(delta: float) -> void:
	if has_hit:
		return

	var dir_vec = transform.x.normalized()
	var travel = dir_vec * SPEED * delta
	var from = global_position
	var to = from + travel

	# Configura os parâmetros do raycast
	var params = PhysicsRayQueryParameters2D.new()
	params.from = from
	params.to = to
	params.exclude = [self, shooter]
	params.collision_mask = COLLISION_MASK

	var space = get_world_2d().direct_space_state
	var result = space.intersect_ray(params)
	if result:
		var collider = result.collider
		if collider.is_in_group("enemy") and collider.has_method("take_damage"):
			has_hit = true
			collider.take_damage(shooter, self)
			print("Bala acertou inimigo:", collider.name)
		else:
			print("Bala bateu em:", collider.name)
		queue_free()
	else:
		global_position = to
