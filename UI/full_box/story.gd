extends TextUI

#controla tempo de intervalo entre letras e pontuação
@onready var _timer = $DisplayTimer
@onready var label= $Label
@onready var portrait = $Portrait



#Se o texto terminou, verifica se há clique. Em caso positivo, envia sinal (que será capturado pelo DialogueManager)
func _gui_input(event):
	if event.is_action_pressed("Click") and _line_finished:
			emit_signal('finish_displaying_text')


#Troca imagem do personagem no quadro lateral
func change_portrait(resource):
	portrait.texture = resource


#Exibe texto caractere por caractere
func show_text(text):
	label.text = ''
	_text = text
	_line_finished=false
	_char_index =0
	display_letter()

#Exibe um carctere e espera para exibir o próximo
func display_letter():
	if _char_index == _text.length():
		print('finish line')
		_line_finished = true
	else:
		label.text += _text[_char_index]
		match _text[_char_index]:
			',','!','?','.':
				_timer.start(_ponctuation_time)
			' ':
				_timer.start(_space_time)
			_:
				_timer.start(_char_time)
		_char_index += 1


#Exibe próxima letra após o timer finalizar
func _on_display_timer_timeout():
		display_letter()
