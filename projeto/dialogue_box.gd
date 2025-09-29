extends CanvasLayer

signal dialogue_finished

const CHAR_READ_RATE = 0.05

@onready var dialoguebox_container = $DialogueBoxContainer
@onready var start_symbol = $DialogueBoxContainer/MarginContainer/HBoxContainer/StartSymbol
@onready var end_symbol = $DialogueBoxContainer/MarginContainer/HBoxContainer/EndSymbol
@onready var text_label = $DialogueBoxContainer/MarginContainer/HBoxContainer/Label

@onready var sound_player = $TypingSoundPlayer
@onready var sound_timer = $TypingTimer

enum State {
	READY,
	READING,
	FINISHED,
	OFF
}

var current_state = State.READY
var tween: Tween = null
var text_queue = []

func _ready() -> void:
	print("Starting state: State.READY")
	hide_textbox()

func terminar_dialogo():
	emit_signal("dialogue_finished")
	hide_textbox()
	get_tree().paused = false
	print("Diálogo inteiro terminado")
	change_state(State.OFF)
	get_tree().change_scene_to_file("res://mundo1.tscn")
	
func _process(_delta: float) -> void:
	match current_state:
		State.READY:
			if not text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("LeftClick"):
				text_label.visible_ratio = 1.0
				tween.kill()
				end_symbol.text = "v"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("LeftClick"):
				if text_queue.is_empty():
					terminar_dialogo()
				else:
					change_state(State.READY)
					hide_letters()

func queue_text(next_text):
	text_queue.push_back(next_text)

func hide_textbox():
	end_symbol.text = ""
	text_label.text = ""
	dialoguebox_container.hide()

func hide_letters():
	end_symbol.text = ""
	text_label.text = ""

func show_textbox():
	dialoguebox_container.show()

func display_text():
	var next_text = text_queue.pop_front()
	text_label.text = next_text
	change_state(State.READING)
	text_label.visible_ratio = 0.0
	show_textbox()
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(text_label, "visible_ratio", 1.0, len(next_text) * CHAR_READ_RATE)
	
	sound_timer.start()
	
	tween.finished.connect(on_tween_finished)
	

func on_tween_finished():
	end_symbol.text = "v"
	sound_timer.stop()
	change_state(State.FINISHED)
	print("Animação do texto terminada!")

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing state to: State.READY")
		State.READING:
			print("Changing state to: State.READING")
		State.FINISHED:
			print("Changing state to: State.FINSHED")

func _on_typing_timer_timeout() -> void:
	if text_label.visible_ratio < 1.0:
		sound_player.play()

func get_dialogue_from_file(dialogue_id: String) -> Array:
	var file = FileAccess.open("res://assets/dialogo/cutscene.json", FileAccess.READ)
	if not file:
		print("Erro: Não foi possível abrir o arquivo dialogues.json")
		return []
	
	var content = file.get_as_text()
	var parsed_json = JSON.parse_string(content)
	if typeof(parsed_json) != TYPE_DICTIONARY:
		print("Erro: JSON inválido")
		return []
	
	if not parsed_json.has(dialogue_id):
		print("Erro: ID de diálogo não encontrado no JSON")
		return []
	
	return parsed_json[dialogue_id]

func start_dialogue(dialogue_id: String):
	var dialogue_lines = get_dialogue_from_file(dialogue_id)
	
	if dialogue_lines.is_empty():
		return
	for line in dialogue_lines:
		queue_text(line)
	
	if current_state == State.OFF:
		change_state(State.READY)
		display_text()
	get_tree().paused = true
