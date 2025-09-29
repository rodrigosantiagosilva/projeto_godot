extends Area2D

var entrou = false

func _on_body_entered(body: CharacterBody2D):
	entrou = true

func _on_body_exited(body: CharacterBody2D):
	entrou = false

func _physics_process(delta):
	if entrou and Input.is_action_just_pressed("ui_down"):
		$AnimationPlayer.play("abreu")
func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://mundo1.tscn")
