extends Node2D

@onready var fiscal = $fiscal

var chances_gastas := 0

func atualizar_posicao():
	if chances_gastas == 1:
		fiscal.position = Vector2(-54, 40)
		
	elif chances_gastas == 2:
		fiscal.position = Vector2(10, 40)
		
	elif chances_gastas == 3:
		fiscal.position = Vector2(66, 40)
		
	elif chances_gastas == 4:
		fiscal.flip_h = false
		fiscal.position = Vector2(-2, -14)
	
