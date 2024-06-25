class_name TextUI extends Control

#caracter atual da frase
var _char_index:int = 0
#frase
var _text = ''
#tempo de espera depois de um espaço
const _space_time = 0.01
#tempo de espera depois de um caractere qualquer
const _char_time = 0.03
#tempo de espera depois de pontuação
const _ponctuation_time = 0.01
#flag indicando se o texto da linha já terminou. Usado para permitir avanço do texto com clique
var _line_finished = false

#sinal emitido depois de terminar de mostrar todo o texto de uma linha.
signal finish_displaying_text()
#sinal emitido depois da seleção de uma opção, passando o índice selecionado
signal finish_selecting_option(index:int)


#Troca imagem do personagem no quadro lateral
func change_portrait(_resource):
	pass

#Exibe texto caractere por caractere
func show_text(_text):
	pass

#Exibe opções que vieram no paramêtro options
func show_options(_options):
	pass
