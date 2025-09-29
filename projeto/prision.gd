extends Area2D
signal npc_libertado

func _on_chave_jaula_aberta():
	emit_signal("npc_libertado")
	print("npc libertado")
	queue_free()



	
