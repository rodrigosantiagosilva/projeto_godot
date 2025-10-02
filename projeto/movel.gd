extends Area2D 
var entra = false
signal gaveta_aberta
@onready var texto = $"textomovel1"

func _ready() -> void:
	if not entra:
		texto.visible = false

func _on_body_entered(bpdy: CharacterBody2D):
	print("bundinha")
	texto.visible = true
	entra = true

func _on_body_exited(body: CharacterBody2D):
	entra = false
	texto.visible = false

func _process(delta):
	if entra and Input.is_action_just_pressed("teclaE"):
		emit_signal("gaveta_aberta")
		entra = false
		texto.visible = false
		$colision_movel.queue_free()
