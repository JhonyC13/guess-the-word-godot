extends Node

@onready var transition_camera: Camera2D = $transition_camera
var transitioning = false

func transition_camera2D(from: Camera2D, to: Camera2D, continue_in_second_camera: bool = true,  duration: float = 1.0) -> void:
	
	if transitioning: return
	transition_camera.enabled = true
	
	#copia os parametros da primeira camera
	transition_camera.zoom = from.zoom
	transition_camera.offset = from.offset
	transition_camera.light_mask = from.light_mask
	
	#move a camera de transição para a posição da primeira camera
	transition_camera.global_transform = from.global_transform
	
	#faz a camera de transição ser a atual
	transition_camera.make_current()
	transitioning = true
	
	#move para a segunda camera, enquanto também ajusta os parametros para os da segunda camera
	var tween = get_tree().create_tween()
	tween.set_parallel(true) #serve para fazer todas as alterações em paralelo, ao invés de executar uma de cada vez
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(transition_camera, "global_transform", to.global_transform, duration)
	tween.tween_property(transition_camera, "zoom", to.zoom, duration)
	tween.tween_property(transition_camera, "offset", to.offset, duration)
	await tween.finished #espera o tween terminar
	
	if continue_in_second_camera:
		#faz a segunda camera ser a atual
		to.make_current()
	else:
		transition_camera.enabled = false
		
	transitioning = false
	
