extends CanvasLayer

@onready var button = $Control/VBoxContainer/Button


func _ready():
	button.grab_focus()

func _on_button_pressed():
	TransitionManager.goto_scene("main", "closing")
