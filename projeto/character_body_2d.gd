extends CharacterBody2D



#==================== VARIÁVEIS DE COMBATE ====================

@export var attack_cooldown := 0.05

@export var max_attack_duration := 1.5

@export var dash_speed := 150.0

@export var dash_duration := 0.25

@export var max_health := 10

@export var attack_damage := 1

@export var charged_attack_damage := 3

@export var charged_dash_speed := 250.0



const DAMAGE_BURST_DURATION := 0.05 

const COMBO_WINDOW := 0.25



# Variáveis de Estado

var combo_step := 0

var next_attack_queued := false

var can_combo := false

var current_health := max_health

var current_attack_damage := 0

var can_attack := true

var is_charging := false

var is_attacking := false

var is_dashing := false

var is_frenetic_attack := false



# Variáveis de Movimento

const CHARGED_ATTACK_THRESHOLD := 1.0

const SPEED := 150.0

const JUMP_VELOCITY := -400.0

var attack_timer_charge := 0.0

var dash_direction := Vector2.ZERO

var is_jumping := false

var gravity := 0.0



# Estado de Arma

enum WeaponState { SWORD, GUN }

var current_weapon: WeaponState = WeaponState.SWORD

var can_switch_weapon := true

const SWITCH_DELAY := 0.5

var player: CharacterBody2D = null



# Referências de Nós

@onready var life_bar := $"./life_bar" as AnimatedSprite2D

@onready var attack_timer := $AttackCooldownTimer as Timer

@onready var combo_timer := $ComboTimer as Timer

@onready var animation := $AnimatedSprite2D as AnimatedSprite2D

@onready var attack_hitbox := $AttackHitbox as Area2D





#==================== READY ====================

func _ready():

	add_to_group("player")

	

	if attack_hitbox:

		attack_hitbox.connect("body_entered", Callable(self, "_on_body_entered"))

	

	if attack_timer:

		attack_timer.connect("timeout", Callable(self, "_on_attack_cooldown_timeout"))

	

	if combo_timer:

		combo_timer.connect("timeout", Callable(self, "_on_combo_timer_timeout"))



	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

	_update_weapon_state()

	

	if attack_hitbox and attack_hitbox.get_node("CollisionShape2D"):

		attack_hitbox.monitoring = false

		attack_hitbox.get_node("CollisionShape2D").disabled = true



func get_attack_damage() -> int:

	return current_attack_damage



#==================== DANO E MORTE ====================

func take_damage(amount : int = 0) -> void:

	if is_attacking or is_dashing:

		print("Player evitou dano!")

		return



	if life_bar.frame < life_bar.sprite_frames.get_frame_count(life_bar.animation) - 1:

		life_bar.frame += 1

	current_health -= amount

	print("Player levou dano! HP atual: ", current_health)

	if current_health <= 0:

		die()



func die() -> void:

	print("Player morreu!")

	set_process(false)

	set_physics_process(false)

	animation.play("death")

	await get_tree().create_timer(2.0).timeout

	queue_free()





#==================== PROCESS & PHYSICS ====================

func _process(delta: float) -> void:

	if Input.is_action_just_pressed("pegar_arma"):

		_attempt_switch()



	if current_weapon == WeaponState.SWORD:

		if is_charging and not is_attacking and not Input.is_action_pressed("atirar"):

			if attack_timer_charge >= CHARGED_ATTACK_THRESHOLD:

				start_charged_attack()

			else:

				start_frenetic_attack()

			return



		if Input.is_action_just_pressed("atirar"):

			if is_attacking and is_frenetic_attack:

				next_attack_queued = true

			elif can_attack and not is_attacking and not is_charging:

				start_frenetic_attack()

			elif not is_attacking and not is_charging:

				start_charge()

			

		if is_charging and Input.is_action_pressed("atirar"):

			attack_timer_charge += delta

			attack_timer_charge = min(attack_timer_charge, max_attack_duration)

			

			if attack_timer_charge >= CHARGED_ATTACK_THRESHOLD:

				if animation.animation != "charged_ready":

					animation.play("charged_ready")

			else:

				if animation.animation != "charge_start" and animation.animation != "charge":

					animation.play("charge")





func _physics_process(delta: float) -> void:

	if not is_on_floor():

		velocity.y += gravity * delta

	else:

		velocity.y = 0



	if Input.is_action_just_pressed("ui_accept") and is_on_floor():

		velocity.y = JUMP_VELOCITY

		is_jumping = true

	elif is_on_floor():

		is_jumping = false



	# 🛑 MUDANÇA AQUI: Removida a verificação 'is_attacking' do bloco principal de movimento.

	# O movimento é permitido, contanto que não esteja carregando ou dando dash.

	if not is_charging and not is_dashing:

		var direction := Input.get_axis("esquerda", "direita")

		if direction != 0:

			velocity.x = direction * SPEED

			animation.scale.x = direction

			

			# Lógica de animação de movimento/ataque

			if not is_jumping and not is_attacking:

				animation.play("run")

			elif is_attacking and not is_jumping:

				# 💡 Adicione sua animação de ataque em movimento aqui se for diferente de 'run'

				# Por exemplo: animation.play("attack_run")

				pass # Deixa a animação de ataque continuar (frenetic_attack)

			else:

				animation.play("jump")

		else:

			velocity.x = move_toward(velocity.x, 0, SPEED)

			if not is_jumping and not is_attacking:

				animation.play("idle")

			elif is_attacking and not is_jumping:

				pass # Deixa a animação de ataque continuar (frenetic_attack)

				

		if is_jumping and direction == 0:

			animation.play("jump")

			

	# O ataque carregado ou dash ainda anulam o movimento

	elif not is_dashing: 

		velocity.x = 0



	move_and_slide()





#==================== LÓGICA DE ATAQUE (BURST) ====================



func start_charge() -> void:

	can_attack = false

	is_charging = true

	attack_timer_charge = 0.0

	

	if animation.animation != "charge_start":

		animation.play("charge_start")

		

	if attack_hitbox and attack_hitbox.get_node("CollisionShape2D"):

		attack_hitbox.monitoring = false

		attack_hitbox.get_node("CollisionShape2D").disabled = true





func _start_damage_burst() -> void:

	if attack_hitbox and attack_hitbox.get_node("CollisionShape2D"):

		attack_hitbox.monitoring = true

		attack_hitbox.get_node("CollisionShape2D").disabled = false

	

	await get_tree().create_timer(DAMAGE_BURST_DURATION).timeout

	

	if attack_hitbox and attack_hitbox.get_node("CollisionShape2D"):

		attack_hitbox.monitoring = false

		attack_hitbox.get_node("CollisionShape2D").disabled = true

		attack_hitbox.call_deferred("clear_overlaps")





func start_frenetic_attack() -> void:

	

	is_charging = false

	is_attacking = true

	is_frenetic_attack = true

	can_attack = false

	next_attack_queued = false

	combo_step = 1

	current_attack_damage = attack_damage

	

	if combo_timer:

		combo_timer.stop()

	

	animation.play("attack")

	await animation.animation_finished

	

	while is_frenetic_attack:

		

		if combo_step > 2: 

			combo_step = 1

			

		var golpe_anim_name := ""

		match combo_step:

			1:

				golpe_anim_name = "attack_end"

			2:

				golpe_anim_name = "attack_end2"

		

		animation.play(golpe_anim_name)

		

		_start_damage_burst()

		

		_start_combo_window()

		

		await animation.animation_finished

		

		if not next_attack_queued or combo_step == 2:  # Corrigido para combo_step == 2 (2 golpes de combo)

			break

			

		next_attack_queued = false

		combo_step += 1

		

	end_attack()





func start_charged_attack() -> void:

	is_charging = false

	is_attacking = true

	is_frenetic_attack = false

	

	current_attack_damage = charged_attack_damage

	dash_speed = charged_dash_speed

	dash_direction = Vector2(animation.scale.x, 0).normalized()

	

	if attack_hitbox and attack_hitbox.get_node("CollisionShape2D"):

		attack_hitbox.monitoring = true

		attack_hitbox.get_node("CollisionShape2D").disabled = false

	

	_start_attack_dash(dash_duration * 1.2)

	

	animation.play("charged_attack")

	await animation.animation_finished

	

	animation.play("attack_end")

	await animation.animation_finished

	

	while is_dashing:

		await get_tree().physics_frame

	

	end_attack()



func _start_attack_dash(duration: float):

	is_dashing = true

	var tween = create_tween()

	

	tween.tween_property(self, "velocity", dash_direction * dash_speed, duration).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "velocity", Vector2(0, velocity.y), 0.01)



	await tween.finished

	

	is_dashing = false

	velocity.x = 0





func end_attack() -> void:

	is_attacking = false

	is_dashing = false

	is_frenetic_attack = false

	combo_step = 0

	can_combo = false

	next_attack_queued = false

	

	if combo_timer:

		combo_timer.stop()

	

	if attack_hitbox and attack_hitbox.get_node("CollisionShape2D"):

		attack_hitbox.monitoring = false

		attack_hitbox.get_node("CollisionShape2D").disabled = true

	

	# Garante que a animação volte para run ou idle após o ataque

	var direction := Input.get_axis("esquerda", "direita")

	if velocity.x != 0 or direction != 0:

		animation.play("run")

	else:

		animation.play("idle")

		

	_start_attack_cooldown()



func _start_combo_window() -> void:

	can_combo = true

	if combo_timer:

		combo_timer.start(COMBO_WINDOW)



func _on_combo_timer_timeout():

	can_combo = false

	if is_frenetic_attack:

		end_attack()



func _start_attack_cooldown() -> void:

	if attack_timer:

		attack_timer.start(attack_cooldown)



func _on_attack_cooldown_timeout() -> void:

	can_attack = true



func _on_animation_sequence_finished():

	pass



#==================== OUTROS ====================

func _attempt_switch() -> void:

	if not can_switch_weapon:

		return

	can_switch_weapon = false

	if current_weapon == WeaponState.SWORD:

		current_weapon = WeaponState.GUN

	else:

		current_weapon = WeaponState.SWORD

	_update_weapon_state()

	await get_tree().create_timer(SWITCH_DELAY).timeout

	can_switch_weapon = true



func _update_weapon_state() -> void:

	if current_weapon == WeaponState.SWORD:

		if is_node_ready() and has_node("Arma"):

			$Arma.hide()

	elif current_weapon == WeaponState.GUN:

		if is_node_ready() and has_node("Arma"):

			$Arma.show()
