extends Area2D
var entrou = false
func _physics_process(delta):
	if entrou and Input.is_action_just_pressed("ui_up"):
		$animacaoporta.play("animacao")
func _on_body_entered(body: CharacterBody2D):
	entrou  = true
	print("entrou")
func _on_body_exited(body: CharacterBody2D):
	entrou = false
	print("saiu")
func _on_animation_player_animation_finished(animacao):
	get_tree().change_scene_to_file("res://mundo2.tscn")
