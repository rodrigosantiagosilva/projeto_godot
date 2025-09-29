extends StaticBody2D
var is_chatting = false

func _on_dialogo_dialogue_finiched():
	is_chatting = false
	print ("terminou")

func _on_prision_npc_libertado():
	if !is_chatting:
		$dialogo.start()
		is_chatting = true
		print("npc falando")
