extends CharacterBody2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tap") and mouse_entered:
		$Sprite.play("puff")
		await $Sprite.animation_finished
		queue_free()
