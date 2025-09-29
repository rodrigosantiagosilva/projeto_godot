# cutscene.gd
extends Control

signal cutscene_finished

@export var typing_speed: float = 20.0

# Esta variável agora servirá como um "molde" ou um valor padrão.
# O valor real virá do script do mundo (word2.gd).
@export var dialogue_lines: Array[Dictionary] = [] # Deixamos vazio por padrão

@onready var label: Label = $label
 # ATENÇÃO: Renomeei para bater com sua imagem da cena
@onready var timer: Timer = $Timer
@onready var image: TextureRect = $TextureRect # ATENÇÃO: Renomeei para bater com sua imagem

var current_line_index: int = 0
var current_char_index: int = 0
var is_typing: bool = false

func _ready() -> void:
	timer.wait_time = 1.0 / typing_speed
	timer.timeout.connect(_on_timer_timeout)
	DialogueBox.start_dialogue("cutscene")
	
	# REMOVEMOS start_cutscene() daqui!
	# A cutscene agora vai esperar ser iniciada por outro script.

func start_cutscene() -> void:
	current_line_index = 0
	show_next_line()
	Globals.game_paused = true


func show_next_line() -> void:

	if current_line_index >= dialogue_lines.size():
		finish_cutscene()
		return

	var line_data: Dictionary = dialogue_lines[current_line_index]
	print("Exibindo fala:", line_data["text"])

	current_char_index = 0
	is_typing = true

	label.text = line_data["text"]
	label.visible_characters = 0

	# Usando a variável @onready que já criamos
	if line_data.has("image") and line_data["image"] != null:
		image.texture = load(line_data["image"])
		image.visible = true
	else:
		image.texture = null
		image.visible = false

	timer.start()

func _on_timer_timeout() -> void:
	if not is_typing:
		timer.stop()
		return

	current_char_index += 1
	label.visible_characters = current_char_index

	if current_char_index >= label.text.length():
		is_typing = false
		timer.stop()


func _unhandled_input(event: InputEvent) -> void:
	if not self.visible: # Se a cutscene não estiver visível, não faça nada
		return

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			is_typing = false
			timer.stop()
			label.visible_characters = label.text.length()
		else:
			current_line_index += 1
			show_next_line()
func finish_cutscene() -> void:
	cutscene_finished.emit()
	Globals.game_paused = false
	self.visible = false # Em vez de destruir, apenas escondemos a cutscene
	# queue_free() # Comentamos isso para poder chamá-la de novo se precisar
