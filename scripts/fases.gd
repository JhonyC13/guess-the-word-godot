extends CanvasLayer

@onready var fase_1 = $VBoxContainer/HBoxContainer/fase1
@onready var fase_2 = $VBoxContainer/HBoxContainer/fase2
@onready var fase_3 = $VBoxContainer/HBoxContainer/fase3
@onready var fase_4 = $VBoxContainer/HBoxContainer/fase4
@onready var fase_5 = $VBoxContainer/HBoxContainer/fase5

# Called when the node enters the scene tree for the first time.
func _ready():
	#match Global.maior_fase_desbloqueada:
		#1:
			#fase_2.disabled = true
			#fase_3.disabled = true
			#fase_4.disabled = true
			#fase_5.disabled = true
		#2:
			#fase_3.disabled = true
			#fase_4.disabled = true
			#fase_5.disabled = true
		#3:
			#fase_4.disabled = true
			#fase_5.disabled = true
		#4:
			#fase_5.disabled = true
	pass

func _on_fase_1_pressed():
	Global.fase_atual = 1
	Global.palavra_fase = ["R", "E", "N", "D", "A"]
	Global.dica_fase = "Dica:  Um imposto em que cada contribuinte, seja ele pessoa física ou jurídica, paga uma certa porcentagem do que recebe ao governo."
	Global.bg_pattern = preload("res://assets/BG_pattern.png")
	TransitionManager.goto_scene("main", "closing")

func _on_fase_2_pressed():
	Global.fase_atual = 2
	Global.palavra_fase = ["V", "E", "I", "C", "U", "L", "O", "S"]
	Global.dica_fase = "Dica:  Imposto sobre a Propriedade de ________ e Automotores"
	Global.bg_pattern = preload("res://assets/BG_pattern2.png")
	TransitionManager.goto_scene("main", "closing")

func _on_fase_3_pressed():
	Global.fase_atual = 3
	Global.palavra_fase = ["T", "E", "R", "R", "I", "T", "O", "R", "I", "A", "L"]
	Global.dica_fase = "Dica:  Imposto Predial e ___________ Urbano"
	Global.bg_pattern = preload("res://assets/BG_pattern.png")
	TransitionManager.goto_scene("main", "closing")


func _on_fase_4_pressed():
	Global.fase_atual = 4
	Global.palavra_fase = ["I", "M", "P", "O", "S", "T", "O"]
	Global.dica_fase = "Dica:  É um tributo obrigatório cobrado pelo governo. É um valor pago pelo contribuinte para custear despesas administrativas do Estado."
	Global.bg_pattern = preload("res://assets/BG_pattern2.png")
	TransitionManager.goto_scene("main", "closing")


func _on_fase_5_pressed():
	Global.fase_atual = 5
	Global.palavra_fase = ["F", "I", "S", "C", "A", "L"]
	Global.dica_fase = "Dica:  *dicas e palavras provisórias. Ainda serão alteradas.*"
	Global.bg_pattern = preload("res://assets/BG_pattern.png")
	TransitionManager.goto_scene("main", "closing")
