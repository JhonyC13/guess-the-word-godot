#Gerencia troca de cenas com transição.
#get_animation_player() e(opcionalmente) set_text(txt)
extends Node

#Cena do tipo de Control que será instanciado para executar a animação de fadein e fadeout.
#É obrigatório que a cena possua um AnimationPlayer com uma animação chamada 'fade'
#É obrigatório que a cena possua um método get_animation_player() que retorna o AnimationPlayer responsável pela animação de fade

@onready var levels =  {
		"cenario_quarto" = LevelInfo.new("", "res://scenes/cenario_quarto.tscn"),
		"tela_mural" = LevelInfo.new("", "res://scenes/tela_mural.tscn"),
		"tela_fases" = LevelInfo.new("Computador","res://scenes/fases.tscn"),
		"main" = LevelInfo.new("Complete a Palavra", "res://scenes/main.tscn"),
}


@onready var transitions  = {
		"circle" = preload("res://transitions/scenes/st_hole.tscn"),
		"rectangle" = preload("res://transitions/scenes/st_color_rect.tscn"),
		"sonic" = preload("res://transitions/scenes/st_sonic_like.tscn"),
		"closing" = preload("res://transitions/scenes/st_closing.tscn")
	}


var _st_node:Control
#Path de nova cena a ser carregada. Se vazio, não é para carregar outra cena
var _new_level:LevelInfo = null
#Indica se o _st_node deve ser liberado depois da animação
var _delete_st:bool = false
#Cena atual. Ao mudar de cena, a atual é liberada e a nova torna-se a atual
var current_scene = null


func get_level_info(index:String):
	if levels.has(index):
		return levels[index]
	else:
		push_warning('Idx de Level não cadastrado')
		return null


func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1) #cena atual é o filho atual
	

func goto_scene(levelinfo:String, transition:String="rectangle"):
	_new_level = get_level_info(levelinfo) #indica que deve-se carregar esta cena
	_instantiate_transition(transitions[transition])
	fade_out() #escurece tela e carrega nova level


func fade_out():
	if get_viewport().get_camera_2d() != null:
		_st_node.global_position =  get_viewport().get_camera_2d().get_screen_center_position() - get_tree().root.content_scale_size*0.5
	else:
		_st_node.global_position = Vector2.ZERO
	
	if _st_node.has_method('set_text'): #se for fade_out, limpar texto
		_st_node.set_text('')
	
	_st_node.get_animation_player().play_backwards('fade')	
	await _st_node.get_animation_player().animation_finished
	
	if _new_level != null:
		_load_scene()


func fade_in():
	if get_viewport().get_camera_2d() != null:
		_st_node.global_position =  get_viewport().get_camera_2d().get_screen_center_position() - get_tree().root.content_scale_size*0.5
	else:
		_st_node.global_position = Vector2.ZERO		
	_st_node.get_animation_player().play('fade')
	
	if _st_node.has_method('set_text'):
		_st_node.set_text(_new_level.level_name)
	
	await _st_node.get_animation_player().animation_finished
	_st_node.queue_free()


func _instantiate_transition(transition_ps):
	_st_node = transition_ps.instantiate()
	add_child(_st_node)
	_st_node.z_index = RenderingServer.CANVAS_ITEM_Z_MAX #coloca a trnasição na frente de todos os componentes


func _load_scene():
	
	current_scene.free()
	var s = ResourceLoader.load(_new_level.level_resource_path)
	current_scene = s.instantiate()
	current_scene.ready.connect(fade_in) # no sinal ready() da cena carregada, invoca fadein()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	_new_level = null
