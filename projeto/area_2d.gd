extends Area2D

var entered = false
@onready var text_label = $"../Label"

func _ready() -> void:
	if not entered:
		text_label.visible = false

func _on_body_entered(body: CharacterBody2D):
	entered = true
	text_label.visible = true
	
func _on_body_exited(body: CharacterBody2D):
	entered = false
	text_label.visible = false
	
func _physics_process(delta):
	if entered and Input.is_action_just_pressed("ui_up"):
		get_tree().change_scene_to_file("res://doicod.tscn")
