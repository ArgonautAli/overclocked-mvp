extends AnimatedSprite2D


func _ready() -> void:
	ghosting()

func set_property(tx_pos, tx_scale, tx_flip):
	global_position = tx_pos
	scale = tx_scale
	flip_h = tx_flip
	
	
func ghosting():
	var tween_fade = get_tree().create_tween()
	tween_fade.tween_property(self, "self_modulate", Color(1,1,1,0), 0.75)
	await tween_fade.finished
	
	queue_free()
