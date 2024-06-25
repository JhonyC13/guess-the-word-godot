extends Node2D

@onready var raycast_seta = $seta_roleta/raycast_seta
@onready var label = $texto_pontos/Label
@onready var roleta = $roleta
@onready var botao_girar = $botao_girar
@onready var particulas_moedas = $particulas_moedas
@onready var roleta_sfx = $roleta_sfx
@onready var animation = $animation

var esta_girando := false


func _ready():
	botao_girar.grab_focus()

func _process(delta):
	if esta_girando:
		botao_girar.disabled = true
		
	else:
		botao_girar.disabled = false

func _on_botao_girar_pressed():
	esta_girando = true
	
	var tween_roleta = create_tween()
	tween_roleta.tween_property(roleta, "rotation", (roleta.rotation + randf_range(10.0, 80.0)), 4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween_roleta.finished
	
	if raycast_seta.is_colliding():
		if raycast_seta.get_collider().is_in_group("azul"):
			Global.pontosLetra = 150
			label.text = "+150"
			particulas_moedas.amount = 40
			
		if raycast_seta.get_collider().is_in_group("amarelo"):
			Global.pontosLetra = 100
			label.text = "+100"
			particulas_moedas.amount = 25
			
		if raycast_seta.get_collider().is_in_group("verde"):
			Global.pontosLetra = 250
			label.text = "+250"
			particulas_moedas.amount = 65
			
		if raycast_seta.get_collider().is_in_group("vermelho"):
			Global.pontosLetra = 50
			label.text = "+50"
			particulas_moedas.amount = 10
		#print(raycast_seta.get_collider().get_groups())
	else:
		print("SAIU")
		roleta_sfx.play()
	
	animation.play("ganhou")
	await animation.animation_finished
	
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await fade_tween.finished
	get_tree().get_first_node_in_group("letra_enviada").editable = true
	get_tree().get_first_node_in_group("letra_enviada").grab_focus()
	get_tree().get_first_node_in_group("botao_enviar").disabled = false
	if get_parent().primeira_roleta == true:
		get_tree().get_first_node_in_group("dica").show()
		get_parent().animation.play("mostrar_dica")
		var display_tween = get_tree().create_tween()
		display_tween.tween_property(get_tree().get_first_node_in_group("dica"), "visible_ratio", 1, 2.5)
		get_parent().primeira_roleta = false
	queue_free()


func _on_seta_roleta_area_exited(area):
	roleta_sfx.play()
