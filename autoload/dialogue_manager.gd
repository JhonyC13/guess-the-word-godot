#A classe da DialogueManager (ou DManager) foi criada para desempenhar o papel de um singleton para gerenciar textos de um  jogo, i.e. diálogos, informações, quadros de história, dentre outros. Esse singleton não possui interface gráfica própria. Existe um atributo chaamdo dialogue_box_scene que deve informar uma cena que representa a GUI onde o texto será exibido. Tal GUI deve possuir alguns métodos obrigatórios, implementados para finalização do texto e seleção de opções, além de dois sinais para informar tais ações.
#
#Para utilização, basta invocar o método start_dialogue que recebe um arquivo de JSON (com diálogos no formato do yarn classic), um vetor com imagens que serão exibidas durante o diálogo, e opcionalmente o título do nóinicial (default = Start) e a posição onde a GUI será exibida (default Vector2.ZERO)
#
#Seguindo a ideia do yarn, temos três tipos de informações:
#- texto: o programa apenas exibe o texto descrito
#- opções: quando há uma única opção, o programa automaticamente navega para este próximo nó. Quando há mais de uma opção, o programa automaticamente pede para que o usuário selecione uma das opções e então somente após a seleção ele navega para o nó selecionado. 
#- comando: o comando executado será um comando do próprio GD script. Ao invocar um comando passamos uma referência para o nó do DialogueManager (gd) para que seja possível acessar variáveis já criadas ou mesmo outros nós dentro da mesma área. Há alguns métodos comuns já implementados em gd: get_var, set_var, change_portrait, write, end_dialogue, e change_node.
extends Node

#UI da caixa de diálogo. Pode ser qualquer GUI, contanto que implemente os métodos: change_portrait(id), show_text(line) e show_options(line).
#A GUI também deve emitir os sinais  finish_displaying_text e finish_selecting_option para indicar que o texto já foi exibido ou uma opção já foi selecionada
#Recomendamos que a GUI seja derivada da classe TextUI (UI/text_ui.gd) que já declara os métodos e sinais obrigatórios
var dialogue_box_scene:PackedScene# = preload("res://UI/caixa_dialogo/dialogue_control.tscn")

#armazenará a instância da GUI de diálogo
var _dialogue_box:Control 
#se a caixa de diálogo está ativa (em execução)
var _is_active = false 
#armazena os diálogos
var _json:Array = [] 
#temporário para montar opções de escolha quando necessário
var _options = {} 
#temporário para montar comandos quando necessário
var _commands:String = '' 
#vetor com retratos dos personagens que participarão do diálogo ativo
var _retratos:Array 
#nó do yarn atualmente sendo processado
var current_node = {}
#índice do nó yarn atualmente sendo processado
var current_line:int = 0
#Variáveis criadas dinamicamente e disponíveis para o diálogo
var _vars = {}

#sinal enviado à caixa de diálogo quando os nós do Yarn são encerrados (diálogo acabou)
signal dialogue_ended(data)


#Obtém o valor de uma variável criada dinamicamente. 
#Essa função é invocada geralmente dentro dos comandos << >> do Yarn
func get_var(vname):
	if _vars.has(vname):
		return _vars[vname]
	else:
		return null


#Cria ou seta uma variável criada dinamicamente. 
#Essa função é invocada geralmente dentro dos comandos << >> do Yarn
func set_var(vname,value):
	_vars[vname] = value


#Muda a figura do personagem exibida ao lado do diálogo
#Essa função é invocada geralmente dentro dos comandos << >> do Yarn
func change_portrait(index):
	_dialogue_box.change_portrait(_retratos[index])
	
func set_portrait(index):
	change_portrait(index)


#Transforma um comando << write >> vindo Yarn em um comando de texto e reprocessa a linha atual do nó.
#Isso é útil para criar textos dinâmicos ou que utilizam o valor das variáveis do diálogo em sua composição
func write(ctext):
	print(ctext)
	current_node.body[current_line] = ctext
	current_line -= 1 #porque o proximo process_node avalia o proximo comando, mas queremos reavaliar o atual novamente


#Termina o diálogo todo e emite um sinal avisando.
#É invocada dentro de um comando << >> do Yarn ou ao terminar todas a linhas de um nó e não houver mudança de nó
func end_dialogue(data='end'):
	if _is_active:
		_is_active =false
		_vars.clear()
		_dialogue_box.queue_free()
		emit_signal('dialogue_ended', data)
		dialogue_ended.emit()


#Inicia um diálogo.
#json_file_path: Arquivo json do Yarn com o diálogo
#retratos: vetor com figuras da cara dos personagens que participam do diálogo
#starting_node: nome do nó inicial por onde o diálogo iniciará
#position: posição da caixa de diálogo (opcional)
func start_dialogue(json_file_path:String, retratos:Array, starting_node:String= 'Start', position:Vector2 = Vector2.ZERO):
	if dialogue_box_scene ==null:
		push_error('Control UI not defined: dialogue_box_scene')
		return
	_retratos = retratos
	_json = _open_json_dialogue_file(json_file_path)
	_instantiate_dialogue_box(position)
	await _dialogue_box.ready
	_is_active = true
	change_node(starting_node)


#Muda do nó atual para o nó com o nome (title) indicado
func change_node(node_name:String):
	_options = {}
	current_line = 0
	current_node = null
	_commands = ''
	
	for j in _json: #find node by title
		if j.get('title') == node_name:
			current_node = j
			break
	if current_node != null:
		_split_current_node_dialogues()
		_process_node()
	else:
		push_error('Node not found')


#Função invocada após o usuário selecionar um item de uma lista de options
func finish_selecting_option_callback(index):
	print(_options[ _options.keys()[index] ])
	current_line += 1
	change_node(_options[ _options.keys()[index] ])


#Função invocada após o termino do processamento de uma olha de texto
func _on_text_ended_callback():
	current_line += 1
	_process_node()


#Classifica e processa nó atual de acordo com seu tipo.
#O tipo pode ser: comando, opções ou texto.
#Caso a última linha já tenha sido processada e não haja mais linhas para processar, encerra o diálogo
func _process_node():
	if current_line < current_node.body.size():
		var linha = current_node.body[current_line]
		if linha.find('<<')!=-1:
			_process_command(linha)
		elif linha.find('[[')!=-1:
			_process_options(linha)
		else:
			_process_text(linha)
	else:
		end_dialogue('end')
		
		
#Joga a linha de texto para exibição na caixa de diálogo.
#A exibição é responsabilidade da GUI invocada, ao final da exibição do texto a GUI emite um sinal para indica que a próxima linha pode ser processada.
func _process_text(line:String):
	_dialogue_box.show_text(line)


#Processa uma linha do tipo opção.
#Ao encontrar uma opção, no caso de não haver outras (i.e. existe apenas uma) já troca automaticamente para o próximo nó indicado na opção
#Ao encontrar mais de uma opção, é montada uma lista (em _options) com todas as opções seguidas. 
#Tais opções são passadas à caixa de diálogo para que o usuário selecione a desejada. Neste caso, a mudança para o nó escolido é realizada através da recepção de um sinal enviado pela GUI
func _process_options(linha:String):
	linha = linha.substr(2,linha.length()-4) # [[OPTION_TEXT | OPTION_NEW_NODE ]]   - remove [[ e ]]\n
	var text = linha.get_slice('|',0)
	var new_node_name = linha.get_slice('|',1)
	#Esse option utilizaremos apenas para exibir o fluxo do diálogo, mas ele não será processado. O processamento será por comandos
	if text == 'skip':
		current_line +=1
		_process_node() #avança sem fazer nada
		return 
	
	_options[text] = new_node_name
	print(_options)
	if (current_line == current_node.body.size()-1): #ultimo option
		if _options.size() == 1: # só um option
			current_line +=1
			change_node(new_node_name)
		else: #varios
			_dialogue_box.show_options(_options)
			await _dialogue_box.finish_selecting_option
	else: #há mais options, chamar recursivamente. Consideramos que os options estão sempre no final do nó
		current_line += 1
		_process_options(current_node.body[current_line])


#Processa uma linha do tipo comando.
#Ao encontrar um comando << >>, verifica se as linhas seguintes ainda sçao comandos. Em caso positivo, o comando é atualizado adicionando as sentenças seguintes (em _commands).
#Terminado o comando (ou quando há apenas uma linha de << >>), é invocado o método _run_commands()
func _process_command(linha:String):
	linha = linha.substr(2,linha.length()-4)# << comando  >>    - Um comando por linha, com identação do GDscript
	_commands += '\t'+ linha + '\n' # adiciona comando aos já processados
		
	if(current_line == current_node.body.size()-1): #ultima linha
		_run_commands()
	else:
		
		linha = current_node.body[current_line+1]
		if linha.find('<<')!=-1: #proxima linha continua o comando
			current_line += 1
			_process_command(linha)
		else: #ja terminou a montagem do comando, pode executar e avançar
			_run_commands()


#Executa comandos armazenados na variável _commands. 
#Para isso, cria um novo script, insere os comandos dentro de uma função e a executa passando esse DManager como referência.
#Após a execução dos comandos, avança para apróxima linha do nó. O avanço é executdo dentro do script de comandos para evitar assincronia entre o próximo comando e o comando executado
func _run_commands():
	var script = GDScript.new()
	script.set_source_code("func eval(gd):\n" + _commands + '\n\tgd.current_line +=1\n\tgd._process_node()')
	script.reload()
	_commands = ''
	print(script.source_code)
	var obj = script.new()
	obj.call('eval', self)


#Lê arquivo json do Yarn e retorna o conteúdo em uma variável
func _open_json_dialogue_file(file:String):
	var data = FileAccess.open(file,FileAccess.READ)
	var json = JSON.parse_string(data.get_as_text())
	return json


#Cria GUI da caixa de diálogo e liga sinais obrigatórios
func _instantiate_dialogue_box(position:Vector2):
	_dialogue_box = dialogue_box_scene.instantiate()
	get_tree().root.add_child.call_deferred(_dialogue_box)
	_dialogue_box.finish_displaying_text.connect(_on_text_ended_callback)
	_dialogue_box.finish_selecting_option.connect(finish_selecting_option_callback)
	_dialogue_box.global_position = position


#Separa os textos do Yarn em várias linhas baseando-se no caracter \n
func _split_current_node_dialogues():
	if typeof(current_node.body) == TYPE_STRING:
		current_node.body = current_node.body.split('\n') #quebra comandos por \n
