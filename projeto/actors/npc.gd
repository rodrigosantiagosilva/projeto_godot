extends StaticBody2D
var is_chatting = false

func _on_dialogo_dialogue_finiched():
	is_chatting = false
	print ("terminou")
	Globals.game_paused = false
func _on_prision_npc_libertado():
	if !is_chatting and Input.is_action_just_pressed("teclaE"):
		$dialogo.start()
		is_chatting = true
		print("npc falando")
		Globals.game_paused = true
