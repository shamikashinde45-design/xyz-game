extends Node2D

# giggly bonk
# tap puff = +1 point and it shoots off somewhere else
# every few seconds it turns into a bomb, tap that and you lose a heart
# sometimes a normal tap gives a heart back. no hearts left = game over
# todo: bomb should flash or something before it goes off

#stuff to touch
const START_HEARTS = 3
const MAX_HEARTS = 3
const HEART_CHANCE = 0.30
const SPEED = 700.0
const BOMB_WAIT_MIN = 0.5
const BOMB_WAIT_MAX = 4.0
const BOMB_SECONDS = 2.0
const EXPLOSION_SECONDS = 0.5
const PUFF_SCALE = 0.8
const TAP_RADIUS = 50.0
const EDGE = 80.0
const SCREEN = Vector2(960, 600)

# stuff to NOT touch (learnt the hard way)
var points = 0
var hearts = START_HEARTS
var direction = Vector2.ZERO
var is_bomb = false
var is_puffing = false
var is_game_over = false
var bomb_timer = 0.0
var bomb_time_left = 0.0

var puff
var points_label
var hearts_box
var hud
var heart_image

func _ready():
	# stretch the stars until they cover the screen
	var background = Sprite2D.new()
	background.texture = load("res://assets/download (50).jpg")
	var image_size = background.texture.get_size()
	var cover = maxf(SCREEN.x / image_size.x, SCREEN.y / image_size.y)
	background.scale = Vector2(cover, cover)
	background.position = SCREEN / 2
	add_child(background)

	puff = load("res://player.tscn").instantiate()
	puff.scale = Vector2(PUFF_SCALE, PUFF_SCALE)
	puff.position = SCREEN / 2
	add_child(puff)

	direction = Vector2.from_angle(randf() * TAU)
	bomb_timer = randf_range(BOMB_WAIT_MIN, BOMB_WAIT_MAX)

	# the heart is one slice
	heart_image = AtlasTexture.new()
	heart_image.atlas = load("res://assets/pixidraw (1).png")
	heart_image.region = Rect2(184, 0, 104, 96)

	hud = CanvasLayer.new()
	add_child(hud)
	build_hud()
	update_hud()

func make_box_style(color):
	# chunky rounded box
	# both use the same
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = Color("2b2b1f")
	box.set_border_width_all(3)
	box.set_corner_radius_all(18)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	return box

func build_hud():
	var points_box = PanelContainer.new()
	points_box.add_theme_stylebox_override("panel", make_box_style(Color("b79a76")))
	points_box.position = Vector2(18, 14)
	points_label = Label.new()
	points_label.add_theme_font_size_override("font_size", 22)
	points_label.add_theme_color_override("font_color", Color("2b1d10"))
	points_box.add_child(points_label)
	hud.add_child(points_box)

	# anchors so the hearts stay on the right even if the window changes
	var hearts_panel = PanelContainer.new()
	hearts_panel.add_theme_stylebox_override("panel", make_box_style(Color("6fb85a")))
	hearts_panel.anchor_left = 1.0
	hearts_panel.anchor_right = 1.0
	hearts_panel.offset_right = -18
	hearts_panel.offset_top = 14
	hearts_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hearts_box = HBoxContainer.new()
	hearts_panel.add_child(hearts_box)
	hud.add_child(hearts_panel)

func update_hud():
	points_label.text = "POINTS : " + str(points)

	# clear the old hearts first or they just keep stacking up
	for old_heart in hearts_box.get_children():
		old_heart.queue_free()
	for i in hearts:
		var heart = TextureRect.new()
		heart.texture = heart_image
		heart.custom_minimum_size = Vector2(30, 28)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hearts_box.add_child(heart)

func _process(delta):
	# nothing moves while the puff animation plays or after game over
	if is_game_over or is_puffing:
		return

	puff.position += direction * SPEED * delta

	# bounce off the edges, absf keeps the speed the same
	if puff.position.x < EDGE:
		direction.x = absf(direction.x)
	if puff.position.x > SCREEN.x - EDGE:
		direction.x = -absf(direction.x)
	if puff.position.y < EDGE:
		direction.y = absf(direction.y)
	if puff.position.y > SCREEN.y - EDGE:
		direction.y = -absf(direction.y)

	if is_bomb:
		bomb_time_left -= delta
		if bomb_time_left <= 0:
			turn_back_to_puff()  # nobody tapped it
	else:
		bomb_timer -= delta
		if bomb_timer <= 0:
			is_bomb = true
			bomb_time_left = BOMB_SECONDS
			puff.show_bomb(true)

func turn_back_to_puff():
	is_bomb = false
	puff.show_bomb(false)
	bomb_timer = randf_range(BOMB_WAIT_MIN, BOMB_WAIT_MAX)

func _input(event):
	if is_game_over or is_puffing:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if event.position.distance_to(puff.position) > TAP_RADIUS:
			return  # tapped empty space, nothing happens
		if is_bomb:
			tap_bomb()
		else:
			tap_puff()

func tap_puff():
	points += 1
	if hearts < MAX_HEARTS and randf() < HEART_CHANCE:
		hearts += 1
	update_hud()

	# the animated puff is much bigger than the idle one, keep it on screen
	puff.position = puff.position.clamp(Vector2(150, 150), SCREEN - Vector2(150, 150))

	is_puffing = true
	await puff.play_puff()  # no taps until its done animating
	is_puffing = false

	direction = Vector2.from_angle(randf() * TAU)
	bomb_timer = randf_range(BOMB_WAIT_MIN, BOMB_WAIT_MAX)

func tap_bomb():
	hearts -= 1
	update_hud()

	is_puffing = true  # reusing this so it stops moving and ignores taps while it explodes
	await puff.explode(EXPLOSION_SECONDS)
	is_puffing = false
	turn_back_to_puff()

	if hearts == 0:
		show_game_over()

func show_game_over():
	is_game_over = true

	# pink behind the picture so the whole screen is covered
	var pink = ColorRect.new()
	pink.color = Color("fce6fb")
	pink.size = SCREEN
	hud.add_child(pink)

	# game over picture from the assets, the edges have blue figma marks, so we crop a few pixels off
	var picture = TextureRect.new()
	var picture_image = AtlasTexture.new()
	picture_image.atlas = load("res://assets/Screenshot 2026-11-15 033203.png")
	picture_image.region = Rect2(9, 7, 435, 222)
	picture.texture = picture_image
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.size = Vector2(SCREEN.x, 222 * SCREEN.x / 435)
	hud.add_child(picture)

	var title = Label.new()
	title.text = "Points: " + str(points)
	title.position = Vector2(180, 430)
	title.size = Vector2(600, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color("2b1d10"))
	hud.add_child(title)

	var again_button = Button.new()
	again_button.text = "PLAY AGAIN"
	again_button.position = Vector2(300, 510)
	again_button.size = Vector2(170, 52)
	again_button.pressed.connect(get_tree().reload_current_scene)
	hud.add_child(again_button)

	var home_button = Button.new()
	home_button.text = "HOME"
	home_button.position = Vector2(490, 510)
	home_button.size = Vector2(170, 52)
	home_button.pressed.connect(get_tree().change_scene_to_file.bind("res://home.tscn"))
	hud.add_child(home_button)
