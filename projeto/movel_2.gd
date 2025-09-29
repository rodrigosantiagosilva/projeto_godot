extends Area2D 
var entra = false
signal porta_aberta
@onready var texto2 = $"textomovel2"
@onready var aberta = $"porta_aberta"
@onready var fechada = $"porta_fechada"

func _ready() -> void:
	if not entra and !Globals.tem_chave:
		texto2.visible = false
func _on_body_entered(body: CharacterBody2D):
	if Globals.tem_chave:
		print("bundinha2")
		texto2.visible = true
		entra = true
func _on_body_exited(body: CharacterBody2D):
	print("sembundinha2")
	texto2.visible = false
	entra = false
func _physics_process(delta):
	if Globals.tem_chave and Input.is_action_just_pressed("ui_down") and entra:
		fechada.visible = false
		aberta.visible = true 
		texto2.visible = false
	if !Globals.tem_chave and aberta.visible and Input.is_action_just_pressed("ui_up") and entra:
		get_tree().change_scene_to_file("res://mundo2.tscn")
