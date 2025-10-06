extends Area2D
signal npc_libertado
var entra = false

func _on_body_entered(body: CharacterBody2D):
	entra = true
func _on_body_exited(body: CharacterBody2D):
	entra = false
func _process(delta):
	if entra and Input.is_action_just_pressed("teclaE"):
		emit_signal("npc_libertado")
		print("npc libertado")
		queue_free()
