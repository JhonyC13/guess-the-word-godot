extends CharacterBody2D

@onready var arara = $arara

var speed = 300
var click_position = Vector2()
var target_position = Vector2()


func _ready():
	click_position = position

func _process(delta):
	if Input.is_action_just_pressed("Click"):
		click_position = get_global_mouse_position()
		
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		if target_position.x > 0:
			arara.flip_h = true
		else:
			arara.flip_h = false
		velocity = target_position * speed
		move_and_slide()
