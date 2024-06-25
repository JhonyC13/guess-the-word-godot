extends CanvasLayer

@onready var label_pontuacao = $Control/VBoxContainer/label_pontuacao

func _ready():
	label_pontuacao.text = "Sua pontuação final: " + str(Global.pontuacao)


func _on_botao_voltar_pressed():
	TransitionManager.goto_scene("tela_fases", "rectangle")
