extends CanvasLayer

@onready var fase_1 = $VBoxContainer/HBoxContainer/fase1
@onready var fase_2 = $VBoxContainer/HBoxContainer/fase2
@onready var fase_3 = $VBoxContainer/HBoxContainer/fase3
@onready var fase_4 = $VBoxContainer/HBoxContainer/fase4
@onready var fase_5 = $VBoxContainer/HBoxContainer/fase5

# Called when the node enters the scene tree for the first time.
func _ready():
	match Global.maior_fase_desbloqueada:
		1:
			fase_2.disabled = true
			fase_3.disabled = true
			fase_4.disabled = true
			fase_5.disabled = true
		2:
			fase_3.disabled = true
			fase_4.disabled = true
			fase_5.disabled = true
		3:
			fase_4.disabled = true
			fase_5.disabled = true
		4:
			fase_5.disabled = true


func _on_fase_1_pressed():
	Global.fase_atual = 1
	Global.palavra_fase = ["T", "E", "S", "T", "E"]
	Global.bg_pattern = preload("res://assets/BG_pattern.png")
	TransitionManager.goto_scene("main", "closing")

func _on_fase_2_pressed():
	Global.fase_atual = 2
	Global.palavra_fase = ["V", "E", "I", "C", "U", "L", "O", "S"]
	Global.bg_pattern = preload("res://assets/BG_pattern2.png")
	TransitionManager.goto_scene("main", "closing")

func _on_fase_3_pressed():
	Global.fase_atual = 3
	Global.palavra_fase = ["T", "E", "R", "R", "I", "T", "O", "R", "I", "A", "L"]
	Global.bg_pattern = preload("res://assets/BG_pattern.png")
	TransitionManager.goto_scene("main", "closing")
