extends SceneTransition


func get_animation_player():
	return $AnimationPlayer
	
func set_text(txt):
	$Label.text = txt


func _on_animation_player_current_animation_changed(name):
	$Timer.start()


func _on_timer_timeout():
	$AudioStreamPlayer.play()
