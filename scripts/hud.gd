extends CanvasLayer

@onready var label_pontuacao = $Control/VBoxContainer/Panel/HBoxContainer/label_pontuacao
@onready var moedas_particulas = $moedas_particulas
@onready var money_sfx = $money_sfx

func _ready():
	Global.connect("score_changed", _on_score_changed)
	label_pontuacao.text = str(Global.pontuacao)

func _on_score_changed():
	money_sfx.play()
	moedas_particulas.get_animation_player().play("emitir")
	await moedas_particulas.get_animation_player().animation_finished
	label_pontuacao.text = str(Global.pontuacao)
