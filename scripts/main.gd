extends Node2D

@onready var bg_pattern = $jogo/BG_pattern
@onready var letra_enviada = $jogo/Control/container_jogo/HBoxContainer/letra_enviada
@onready var botao_enviar = $jogo/Control/container_jogo/HBoxContainer/botao_enviar
@onready var label_dica = $jogo/Control/container_jogo/label_dica
@onready var container_letras_vazias = $jogo/Control/container_jogo/container_letras_vazias
@onready var container_letras_usadas = $jogo/Control/container_letras_usadas
@onready var label_letras_usadas = $jogo/Control/container_letras_usadas/VBoxContainer/label_letras_usadas
@onready var label_fala_personagem = $jogo/Control/label_fala_personagem
@onready var label_pontuacao_aumentou = $jogo/label_pontuacao_aumentou
@onready var animation = $animation
@onready var cenario_guarda = $cenario_guarda
@onready var jogo = $jogo
@onready var hud = $HUD
@onready var imagem_camera = $imagem_camera

@onready var letras_vazias = [] #esse vetor armazena as linhas vazias onde as letras serão colocadas

@onready var palavra = [] #esse vetor receber o vetor global que armazena as letras da palavra

@onready var animacoes = [ #vetor para armazenar as animações do fiscal se aproximando
	"aproximando",
	"aproximando_2",
	"aproximando_3",
	"aproximando_4"
]

@onready var frases_acertou = [
	"Boa! É isso aí!",
	"Tá quase lá!",
	"Mais uma pra conta!",
]

@onready var frases_errou = [
	"Ai não!",
	"Ele ta chegando perto!",
	"Putz!",
]

@onready var letras_usadas = [] #armazena as letras que o jogador utilizou

@onready var cena_letra_vazia = preload("res://scenes/letra_vazia.tscn")
@onready var cena_roleta = preload("res://scenes/roleta_teste.tscn")
@onready var mensagem_erro_cena = preload("res://scenes/mensagem_erro.tscn")
@onready var cena_fim_de_jogo = preload("res://scenes/fim_de_jogo.tscn")
@onready var cena_tela_ganhador = preload("res://scenes/tela_ganhador.tscn")

var esta_certa := false #serve para saber se a letra enviada estava correta
var cont_anim := 0 #contador para saber qual animação do fiscal se aproximando é para rodar
var cont_acertos = 0 #contador que armazena o número de acertos
var primeira_roleta = true #serve para saber se essa é a primeira roleta que apareceu
var pontuacao_fase := 0 #armazena a pontuação que ele fez nessa fase, para, caso o jogador esgote todas as chances, esse número ser subtraido da pontuação global.

signal letras_usadas_aumentou #sinal para saber quando o jogador usa uma letra nova


func _ready():
	
		#adiciona as informações principais que variam em cada fase
		palavra = Global.palavra_fase
		label_dica.text = Global.dica_fase
		bg_pattern.texture = Global.bg_pattern
		
		if bg_pattern.texture == preload("res://assets/BG_pattern.png"):
			bg_pattern.material.set_shader_parameter("speed", 0.1)
		elif bg_pattern.texture == preload("res://assets/BG_pattern2.png"):
			bg_pattern.material.set_shader_parameter("speed", 0.05)
		
		#for para adicionar as linhas da palavra que serão preenchidas pelo jogador
		for i in palavra.size():
			var nova_letra_vazia = cena_letra_vazia.instantiate()
			container_letras_vazias.add_child(nova_letra_vazia)
			
			if Global.maior_fase_desbloqueada > Global.fase_atual: #verifica se o jogador já passou dessa fase antes
				nova_letra_vazia.text = palavra[i] #completa as linhas com as letras da palavra automaticamente
			else:
				letras_vazias.append(nova_letra_vazia)
				
			
		if Global.maior_fase_desbloqueada <= Global.fase_atual: #verifica se o jogador ainda não passou dessa fase
			Global.chances = 5 #reseta o número de chances
			letras_usadas_aumentou.connect(_on_letras_usadas_aumentou) #conecta o sinal letras_usadas_aumentou na função _on_letras_usadas_aumentou
			letra_enviada.editable = false
			botao_enviar.disabled = true
			
			var nova_roleta = cena_roleta.instantiate() #instancia a cena da roleta
			add_child(nova_roleta)
		else:
			imagem_camera.hide()
			container_letras_usadas.hide()
			letra_enviada.editable = false
			botao_enviar.disabled = true
			label_dica.show()
			animation.play("mostrar_dica")
			var display_tween = get_tree().create_tween()
			display_tween.tween_property(label_dica, "visible_ratio", 1, 2.5)

# esse input estava servindo de teste para tentar encontrar como detectar o enter do teclado virtual de celular
#func _input(event):
	#if event is InputEventKey:
		#if event.pressed and event.keycode == 4194321:
			#print("ENVIOU")
	
	
func _on_botao_voltar_pressed():
	TransitionManager.goto_scene("tela_fases", "rectangle") #muda para a cena da tela de fases

func _on_botao_enviar_pressed():
	enviar_letra()

func _on_letra_enviada_text_submitted(new_text):
	enviar_letra()

#função para deixar a letra maiúscula e colocar o cursor de texto na frente da letra sempre que o jogador inserir uma letra quando o espaço estiver vazio
func _on_letra_enviada_text_changed(new_text):
	letra_enviada.text = letra_enviada.text.to_upper()
	letra_enviada.caret_column = 1

#função para deixar a letra maiúscula e colocar o cursor de texto na frente da letra sempre que o jogador inserir uma letra quando o espaço já estiver cheio
func _on_letra_enviada_text_change_rejected(rejected_substring):
	letra_enviada.text = rejected_substring.to_upper()
	letra_enviada.caret_column = 1

#função para adicionar uma letra nova na label de letras usadas toda vez que o jogador enviar uma letra nova
func _on_letras_usadas_aumentou():
	label_letras_usadas.text = ""
	for i in letras_usadas.size():
		label_letras_usadas.text += letras_usadas[i] + "  "

#função que envia a letra e verifica todas as condições necessárias com a letra
func enviar_letra():
	#print(letra_enviada.text.unicode_at(0))
	#letra_enviada.grab_focus()
	var mensagem_erro = mensagem_erro_cena.instantiate()
	
	# esse if é para limitar o usuário a enviar apenas letras
	if letra_enviada.text == "" or letra_enviada.text.unicode_at(0) < 65 or letra_enviada.text.unicode_at(0) > 90:
		letra_enviada.text = ""
		Global.texto_erro = "Insira uma LETRA"
		add_child(mensagem_erro)
		return
	
	# esse for é para verificar se essa letra já foi utilizada
	for i in letras_usadas.size():
		
		if letra_enviada.text == letras_usadas[i]:
			
			Global.texto_erro = "Essa letra ja foi usada"
			add_child(mensagem_erro)
			return
	letras_usadas.append(letra_enviada.text)
	letras_usadas_aumentou.emit()
	
	# esse for é para verificar se a letra enviada está na palavra
	for i in palavra.size():
		if letra_enviada.text.to_upper() == palavra[i]:
			cont_acertos += 1
			letras_vazias[i].text = palavra[i]
			esta_certa = true
			
			letra_enviada.editable = false
			botao_enviar.disabled = true
			
			label_fala_personagem.text = frases_acertou[randi_range(0, frases_acertou.size()-1)]
			var balao_fala_fadein = get_tree().create_tween()
			balao_fala_fadein.tween_property(label_fala_personagem, "modulate:a", 1, 0.5)
			await get_tree().create_timer(1.5).timeout
			var balao_fala_fadeout = get_tree().create_tween()
			balao_fala_fadeout.tween_property(label_fala_personagem, "modulate:a", 0, 0.5)
			label_pontuacao_aumentou.text = "+" + str(Global.pontosLetra)
			label_pontuacao_aumentou.global_position = letras_vazias[i].global_position
			animation.play("pontuacao_aumentou")
			await animation.animation_finished
			Global.pontuacao += Global.pontosLetra
			pontuacao_fase += Global.pontosLetra
			Global.score_changed.emit()
			await hud.moedas_particulas.get_animation_player().animation_finished
	
	if !esta_certa: #if para verificar se a letra está errada
		Global.chances -= 1
		
		if cont_anim <= animacoes.size() - 1: #if para verificar se ainda tem mais animações disponíveis
			letra_enviada.editable = false
			letra_enviada.release_focus()
			botao_enviar.disabled = true
			var fade_tween = get_tree().create_tween() #tween para fazer um fade in na cena do guarda/fiscal
			fade_tween.tween_property(cenario_guarda, "modulate:a", 1, 0.7)
			await fade_tween.finished
			
			cenario_guarda.animation_player.play(animacoes[cont_anim])#roda a animação atual
			await cenario_guarda.animation_player.animation_finished
			
			var fadeout_tween = get_tree().create_tween() #tween para fazer um fade out na cena do guarda/fiscal
			fadeout_tween.tween_property(cenario_guarda, "modulate:a", 0, 0.5)
			await fadeout_tween.finished
			
			label_fala_personagem.text = frases_errou[randi_range(0, frases_errou.size()-1)]
			var balao_fala_fadein = get_tree().create_tween()
			balao_fala_fadein.tween_property(label_fala_personagem, "modulate:a", 1, 0.5)
			await get_tree().create_timer(1.5).timeout
			var balao_fala_fadeout = get_tree().create_tween()
			balao_fala_fadeout.tween_property(label_fala_personagem, "modulate:a", 0, 0.5)
			
			imagem_camera.chances_gastas += 1
			imagem_camera.atualizar_posicao() #atualiza a posição do fiscal na imagem da camera
			
			cont_anim += 1
			botao_enviar.disabled = false
			letra_enviada.editable = true
			letra_enviada.grab_focus()
			
	elif esta_certa: #if para verificar se a letra esta certa
		if cont_acertos >= palavra.size(): #if para verificar se o jogador já acertou todas as letras da palavra
			Global.maior_fase_desbloqueada = Global.fase_atual + 1
			
			letra_enviada.editable = false
			letra_enviada.release_focus()
			botao_enviar.disabled = true
			
			var tela_ganhador = cena_tela_ganhador.instantiate() #instancia a tela de ganhador
			add_child(tela_ganhador)
		else:
			var nova_roleta = cena_roleta.instantiate() #instancia a cena da roleta
			add_child(nova_roleta)
		
		esta_certa = false #reseta a varivel para falsa
		
	if Global.chances <= 0: #verifica se o jogador já usou todas as chances disponíveis
		
		cenario_guarda.show()
		var fade_tween = get_tree().create_tween()
		fade_tween.tween_property(cenario_guarda, "modulate:a", 1, 1.0)
		await fade_tween.finished
		cenario_guarda.animation_player.play("fim_de_jogo") #roda a animação de fim de jogo
		await cenario_guarda.animation_player.animation_finished
		
		var fim_de_jogo = cena_fim_de_jogo.instantiate() #instancia a tela de fim de jogo
		add_child(fim_de_jogo)
		
		Global.pontuacao -= pontuacao_fase
		
	letra_enviada.text = ""
	
