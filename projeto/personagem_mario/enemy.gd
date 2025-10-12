extends CharacterBody2D

# --- VARIÁVEIS DE STATUS ---
@export var max_health := 10
@export var normal_speed := 30.0
@export var alert_speed := 60.0
@export var enraged_speed := 100.0
@export var alert_duration := 5.0        # segundos que fica alerta
@export var attack_range := 40.0
@export var damage_amount := 1

var current_health: int
var is_alert := false
var is_enraged := false
var direction := 1
var player: CharacterBody2D = null

var is_attacking := false
var attack_stage := 1  # 1 = primeiro, 2 = demais

# Timers
var damage_timer: Timer
var attack_timer: Timer
var alert_timer: Timer

# --- REFERÊNCIAS ---
@onready var wall_detector := $wall_detector as RayCast2D

func _ready():
	current_health = max_health

	var sign = -1 if direction < 0 else 1
	wall_detector.target_position.x = sign * abs(wall_detector.target_position.x)

	$Hurtbox.connect("area_entered", Callable(self, "_on_Hurtbox_area_entered"))
	$HitBoxDamage.connect("body_entered", Callable(self, "_on_HitBoxDamage_body_entered"))
	$HitBoxDamage.connect("body_exited", Callable(self, "_on_HitBoxDamage_body_exited"))

	damage_timer = Timer.new()
	damage_timer.one_shot = true
	damage_timer.connect("timeout", Callable(self, "_on_damage_timer_timeout"))
	add_child(damage_timer)

	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	add_child(attack_timer)

	alert_timer = Timer.new()
	alert_timer.one_shot = true
	alert_timer.wait_time = alert_duration
	alert_timer.connect("timeout", Callable(self, "_on_alert_timer_timeout"))
	add_child(alert_timer)


func _physics_process(delta: float) -> void:
	if current_health <= 0:
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.target_position.x *= -1
		wall_detector.position.x *= -1

	$AnimatedSprite2D.flip_h = direction < 0

	if is_alert and player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		var dir_x = sign(player.global_position.x - global_position.x)
		var speed = enraged_speed if is_enraged else alert_speed
		velocity.x = dir_x * speed
		$AnimatedSprite2D.flip_h = dir_x < 0
		if dist <= attack_range and not is_attacking:
			_start_attack_sequence()
	else:
		velocity.x = normal_speed * direction
		$AnimatedSprite2D.play("walk")

	move_and_slide()


func _start_attack_sequence():
	if is_attacking or player == null or not player.is_in_group("player"):
		return
	is_attacking = true
	$AnimatedSprite2D.play("attack")

	damage_timer.start(0.2)
	var dur = 0.6 if attack_stage == 1 else 0.3
	attack_timer.start(dur)


func _on_damage_timer_timeout():
	if player and is_instance_valid(player) and player.is_in_group("player"):
		player.take_damage(damage_amount)
		print("Inimigo causou dano ao player!")


func _on_attack_timer_timeout():
	is_attacking = false
	if is_alert and player and is_instance_valid(player):
		attack_stage = 2
	else:
		attack_stage = 1
		$AnimatedSprite2D.play("idle")


func take_damage(source = null, area = null):
	# Filtra: só reage a PLAYER ou BALAS
	var valid_hit := false
	if source and source is CharacterBody2D and source.is_in_group("player"):
		valid_hit = true
	elif area and area.is_in_group("bullet"):
		valid_hit = true
	if not valid_hit:
		return

	print("Dano recebido por:", name, "| posição:", global_position)
	current_health -= 1
	print("HP", name, "=", current_health)

	if source and source is CharacterBody2D and source.is_in_group("player"):
		player = source
		is_alert = true
		alert_timer.start()
		print(name, "está alerta! Player:", player.name)

	if area and area.is_in_group("bullet"):
		is_enraged = true
		print(name, "ficou enfurecido!")

	if current_health <= 0:
		die()


func _on_alert_timer_timeout():
	is_alert = false
	print(name, "voltou à patrulha.")


func die():
	print("Inimigo derrotado.")
	queue_free()


func _on_Hurtbox_area_entered(area):
	var src = null
	if area.has_method("get_owner"):
		src = area.get_owner()
	take_damage(src, area)


func _on_HitBoxDamage_body_entered(body):
	# Só detecta o player, não outros inimigos
	if body.is_in_group("player"):
		var c = body
		while c and not c is CharacterBody2D:
			c = c.get_parent()
		if c and c.has_method("take_damage") and c.is_in_group("player"):
			player = c
			is_alert = true
			alert_timer.start()
			print("DEBUG: player entrou na área, inimigo alerta:", player.name)


func _on_HitBoxDamage_body_exited(body):
	pass
