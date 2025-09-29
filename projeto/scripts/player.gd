extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
var is_jumping := false
var player_life := 8
var knockback_vector := Vector2.ZERO

# Sistema de level e atributos
var level: int = 1
var exp: int = 0
var exp_next_level: int = 100
var pontos_disponiveis: int = 0
var carisma: int = 1
var inteligencia: int = 1
var arma: int = 1
var armadura: int = 1

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var life_bar := $"../life_bar" as AnimatedSprite2D  # Ajuste o caminho se necessário

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false

	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animation.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_jumping:
		animation.play("jump")
	elif direction:
		animation.play("run")
	else:
		animation.play("idle")

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		
	move_and_slide()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if player_life <= 0:
		queue_free()
	else:
		if $ray_right.is_colliding():
			take_damage(Vector2(-200, -200))
		elif $ray_left.is_colliding():
			take_damage(Vector2(200, -200))

func take_damage(knockback_force := Vector2.ZERO, duration := 0.25):
	player_life -= 1
	
	# Avança o frame da barra de vida (1 frame por dano)
	if life_bar.frame < life_bar.sprite_frames.get_frame_count(life_bar.animation) - 1:
		life_bar.frame += 1

	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		
		var knockback_tween := get_tree().create_tween()
		knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1, 0, 0, 1)
		knockback_tween.parallel().tween_property(animation, "modulate", Color(1, 1, 1, 1), duration)

func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
