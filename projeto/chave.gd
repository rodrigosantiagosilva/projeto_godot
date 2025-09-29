extends Area2D

signal abrir_porta
signal super_chave
@onready var texto = $textochave
var perto_porta = false

func _on_movel_gaveta_aberta():
	visible = true

func _on_super_chave():
	if visible:
		Globals.esta_perto = true
		print("perto da chave")

func _physics_process(delta):
	if Globals.esta_perto and Input.is_action_just_pressed("") and visible:
		Globals.tem_chave = true
		print("chave coletada")
		$colision_chave.disabled = true
		visible = false
		Globals.esta_perto = false

	var chave_rects = get_viewport_rect()
	var player_rects = $"../player".get_viewport_rect()
	if chave_rects.intersects(player_rects) and !Globals.esta_perto:
		super_chave.emit()
		texto.visible = true
		Globals.esta_perto = true

func _on_movel2_body_entered(body: CharacterBody2D):
	print("perto da porta")
	perto_porta = true
	
func _process(delta):
	if Globals.tem_chave and perto_porta and Input.is_action_just_pressed("ui_up"):
		emit_signal("abrir_porta")
		print("porta foi abrida")
