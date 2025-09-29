extends CharacterBody2D
 
const SPEED = 700.0
const JUMP_VELOCITY = -400.0
 
@onready var wall_detector := $wall_detector as RayCast2D
@onready var texture := $texture as Sprite2D
@onready var anim := $anim as AnimationPlayer
var direction := -1
 
func _ready():
	# Garante que o RayCast comece no lado certo
	if direction == -1:
		wall_detector.target_position.x = -abs(wall_detector.target_position.x)
	else:
		wall_detector.target_position.x = abs(wall_detector.target_position.x)
 
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
 
	if wall_detector.is_colliding():
		direction *= -1
 
		# Inverter o raio (direção e posição)
		wall_detector.target_position.x *= -1
		wall_detector.position.x *= -1
 
	# Inverte o sprite visualmente
	texture.flip_h = direction == 1
 
	# Movimento lateral
	velocity.x = direction * SPEED * delta
	move_and_slide()
 
func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt":
		queue_free()
 
# ✅ Nova função pública para o hitbox chamar
func hurt():
	anim.play("hurt")
