extends Control
#(used quite a bit of ai for this cuz we were running out of time :isob:)
# title screen, everything is built in code so the scene stays empty

func _ready():
	# background first so the rest sits on top of it
	var background = TextureRect.new()
	background.texture = load("res://assets/Home Page.jpg")
	background.size = Vector2(960, 600)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background)

	var title = Label.new()
	title.text = "G-B"
	title.position = Vector2(330, 70)
	title.size = Vector2(300, 120)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 96)
	title.add_theme_color_override("font_color", Color("4f8a5b"))
	title.add_theme_color_override("font_outline_color", Color("1d2b22"))
	title.add_theme_constant_override("outline_size", 6)
	add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Giggly Bonk"
	subtitle.position = Vector2(260, 200)
	subtitle.size = Vector2(440, 70)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 52)
	subtitle.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	subtitle.add_theme_constant_override("outline_size", 5)
	add_child(subtitle)

	var box = StyleBoxFlat.new()
	box.bg_color = Color("5b7f4a")
	box.border_color = Color("1f2a1a")
	box.set_border_width_all(5)
	box.set_corner_radius_all(6)

	var start_button = Button.new()
	start_button.text = "START"
	start_button.position = Vector2(380, 330)
	start_button.size = Vector2(200, 70)
	start_button.add_theme_font_size_override("font_size", 38)
	# same box on every state, otherwise it jumps around when you hover it
	start_button.add_theme_stylebox_override("normal", box)
	start_button.add_theme_stylebox_override("hover", box)
	start_button.add_theme_stylebox_override("pressed", box)
	start_button.add_theme_stylebox_override("focus", box)
	start_button.pressed.connect(start_game)
	add_child(start_button)

func start_game():
	get_tree().change_scene_to_file("res://game.tscn")
