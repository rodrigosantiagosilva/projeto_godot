# word2.gd
extends Node2D

# 1. Referência para o nó da Cutscene na sua cena.
#    Certifique-se que o nó Cutscene é filho do nó word2 no editor.
@onready var cutscene_player: Control = $player/Camera2D2/Cutscene

# 2. Aqui você define os diálogos específicos para ESTA cena (o mundo).
@export var dialogue_lines_intro: Array[Dictionary] = [
	{"text": "Em um reino esquecido pelo tempo...", "image": null},
	{"text": "Uma antiga profecia começa a se realizar.", "image": "res://assets/profecia.png"}, # Exemplo de caminho
	{"text": "E apenas um herói pode trazer a luz de volta.", "image": "res://assets/heroi.png"}  # Exemplo de caminho
]

func _ready() -> void:
	start_world_intro()


func start_world_intro():
	cutscene_player.dialogue_lines = dialogue_lines_intro
	cutscene_player.visible = true
	cutscene_player.start_cutscene()
	
	# 5. Conecta o sinal para saber quando a cutscene terminar.
	cutscene_player.cutscene_finished.connect(_on_cutscene_finished)
	
# 6. Esta função será chamada quando o sinal "cutscene_finished" for emitido.
func _on_cutscene_finished():
	print("A cutscene terminou! Agora o jogo pode começar.")
	# Aqui você pode, por exemplo, habilitar o controle do jogador.
	# get_node("Player").set_process(true)
