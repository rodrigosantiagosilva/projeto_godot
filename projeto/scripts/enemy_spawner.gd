extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_time: float = 7.0  # Tempo total de spawn (em segundos)
@export var interval: float = 3.5     # Intervalo entre spawns de inimigos

var spawn_timer: float

@onready var timer := $Timer
@onready var label := $Label
@onready var portal_anim := $Portal as AnimatedSprite2D

func _ready():
	spawn_timer = spawn_time
	timer.wait_time = interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	portal_anim.visible = true
	portal_anim.play("spawn")  # Começa a animação (certifique-se de ter a animação "spawn")

func _process(delta: float) -> void:
	if spawn_timer > 0:
		spawn_timer -= delta
		_update_label()
	else:
		if timer.is_stopped() == false:
			timer.stop()
			label.text = "Spawner encerrado!"

			# Oculta o portal e para a animação
			portal_anim.stop()
			portal_anim.visible = false

func _on_timer_timeout():
	if spawn_timer > 0:
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.position = self.global_position
		get_parent().add_child(enemy_instance)

func _update_label():
	label.text = str(max(spawn_timer, 0.0)).pad_decimals(2) + "s"
