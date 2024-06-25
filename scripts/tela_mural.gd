extends Node2D


func _on_button_pressed():
	Global.ponto_exclamacao_atual = 2
	TransitionManager.goto_scene("cenario_quarto", "rectangle")
	

