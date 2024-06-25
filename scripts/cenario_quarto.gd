extends Node2D

@onready var player = $player
@onready var area_quadro = $area_quadro
@onready var area_pc = $area_pc
@onready var colisao_pc = $area_pc/colisao_pc
@onready var exclamacao_quadro = $exclamacao_quadro
@onready var exclamacao_pc = $exclamacao_pc


func _ready():
	DialogueManager.connect("dialogue_ended", _on_dialogue_ended)
	if Global.ponto_exclamacao_atual == 1:
		colisao_pc.disabled = true
		return
	elif Global.ponto_exclamacao_atual == 2:
		area_quadro.queue_free()
		exclamacao_quadro.queue_free()
		colisao_pc.disabled = false
		player.set_process(false)
		start_dialogue()


func _on_area_pc_body_entered(body):
	if body.is_in_group("player"):
		TransitionManager.goto_scene("tela_fases", "rectangle")


func _on_area_quadro_body_entered(body):
	if body.is_in_group("player"):
		TransitionManager.goto_scene("tela_mural", "rectangle")
	

func start_dialogue():
	var figs = [
		preload("res://assets/arara_desenho.png"), 
		]
	DialogueManager.dialogue_box_scene = preload("res://UI/dialogue_box/dialogue_control.tscn")
	DialogueManager.start_dialogue("res://dialogues/arara_dialogue.json", figs , 'Start')
	

func _on_dialogue_ended():
	player.set_process(true)
	await get_tree().create_timer(0.2).timeout
	exclamacao_pc.show()
	var pop_in_tween = get_tree().create_tween()
	pop_in_tween.tween_property(exclamacao_pc, "scale", Vector2(1,1), 0.2)
	await pop_in_tween.finished
	var pop_out_tween = get_tree().create_tween()
	pop_out_tween.tween_property(exclamacao_pc, "scale", Vector2(0.5,0.5), 0.25)
	
	
	
