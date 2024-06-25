extends TextUI

@export var options_pointer:Resource = null

#controla tempo de intervalo entre letras e pontuação
@onready var _timer = $DisplayTimer
#retrato do personagem (geralmente modificado via comando de dialogo)
@onready var node_retrato = $PanelContainer/MarginContainer/HBoxContainer2/Retrato
#texto 
@onready var node_labeltext = $PanelContainer/MarginContainer/HBoxContainer2/HBoxContainer/LabelText
#botão que aparece para seleção de opções
@onready var node_advance_button = $PanelContainer/MarginContainer/HBoxContainer2/HBoxContainer/TextureButton
#lista de opções
@onready var node_item_list = $PanelContainer/MarginContainer/HBoxContainer2/HBoxContainer/ItemList
#caracter atual da frase
@onready var text_next = $PanelContainer/MarginContainer/HBoxContainer2/HBoxContainer/LabelText/TextNext

#Troca imagem do personagem no quadro lateral
func change_portrait(resource):
	node_retrato.texture = resource

#Exibe texto caractere por caractere
func show_text(text):
	text_next.visible = false
	node_labeltext.visible = true
	node_item_list.visible = false
	node_advance_button.visible = false
	node_labeltext.text = ''
	_text = text
	_line_finished=false
	_char_index =0
	display_letter()


#Exibe opções que vieram no paramêtro options
func show_options(options):
	node_item_list.clear()
	node_labeltext.visible = false
	node_item_list.visible = true
	node_advance_button.visible = false
	
	var image = options_pointer
	for opt in options:
		var id = node_item_list.add_item(opt,image)
		node_item_list.set_item_icon_modulate(id, Color(0,0,0,0.5))


#Exibe um carctere e espera para exibir o próximo
func display_letter():
	if _char_index == _text.length():
		print('finish line')
		_line_finished = true
		text_next.visible = true
		$TalkAudioStreamPlayer.stop()
	else:
		node_labeltext.text += _text[_char_index]
		match _text[_char_index]:
			',','!','?','.':
				_timer.start(_ponctuation_time)
			' ':
				_timer.start(_space_time)
			_:
				if !$TalkAudioStreamPlayer.is_playing():
					$TalkAudioStreamPlayer.play()
				_timer.start(_char_time)
		_char_index += 1


#Exibe próxima letra após o timer finalizar
func _on_display_timer_timeout():
		display_letter()


#Ao clicar no botão de seleção de opções, emite sinal com a opção que estava selecionada
func _on_texture_button_pressed():
	emit_signal('finish_selecting_option', node_item_list.get_selected_items()[0])


#Ao mudar seleção das opções, muda gráfico dos ícones
func _on_item_list_item_selected(index):
	$OptionAudioStreamPlayer.play()
	node_advance_button.visible = true
		
	for idx in range(node_item_list.get_item_count()):
		node_item_list.set_item_icon_modulate(idx,Color.TRANSPARENT)
	
	node_item_list.set_item_icon_modulate(index,Color.WHITE)


func _on_panel_container_gui_input(event):
	if event.is_action_pressed("Click") and _line_finished:
			emit_signal('finish_displaying_text')
