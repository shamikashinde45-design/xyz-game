extends CharacterBody2D

# the character itself, both animations live in player.tscn

var bomb_pic
var explosion_pic

func _ready():
	$Sprite.sprite_frames.set_animation_loop("puff", false)
	$Sprite.play("default")

	# bomb is a plain sprite we show instead of the animation
	bomb_pic = Sprite2D.new()
	bomb_pic.texture = load("res://assets/asset1.png")
	bomb_pic.scale = Vector2(0.5, 0.5)
	bomb_pic.visible = false
	add_child(bomb_pic)

	# explosion pic, only shows when the bomb gets tapped
	explosion_pic = Sprite2D.new()
	explosion_pic.texture = load("res://assets/bomb_explosion-removebg-preview.png")
	explosion_pic.scale = Vector2(0.4, 0.4)
	explosion_pic.visible = false
	add_child(explosion_pic)

func show_bomb(on):
	bomb_pic.visible = on
	$Sprite.visible = not on

func play_puff():
	$Sprite.play("puff")
	await $Sprite.animation_finished
	$Sprite.play("default")

func explode(seconds):
	# just show the explosion pic for a bit, no animation
	bomb_pic.visible = false
	explosion_pic.visible = true
	await get_tree().create_timer(seconds).timeout
	explosion_pic.visible = false
