extends Node2D
@export var difficulty = 2
@export var MainMenu : Control
@export var LetterContainer : PanelContainer
@export var LetterLabel : Label
@export var cam : Camera2D
@export var NewLetterDelayTimer : Timer
@export var Congregation : Node
@export var ShamanDead1 : Sprite2D
@export var ShamanDead2 : Sprite2D
@export var ShamanDead3 : Sprite2D
@export var Shaman1 : AnimatedSprite2D
@export var Shaman2 : AnimatedSprite2D
@export var Shaman3 : AnimatedSprite2D
@export var EndScreen : Control
@export var EndLabel : Label
@export var Moon : Sprite2D
var camoffx = 160
var camoffy = 200
var camzoom = 2
var t = 0.0
var gameRunning = false
var alphabet : Array
var currentLetter : String
var AmountOfLetters = 10
var LetterInterval = 0.6
var LettersLeft : int 
var awaitingLetter = true
var health = 3
#PanelColors
var initial_color = Color.from_string("#21181e",Color.DARK_SLATE_BLUE) 
# Called when the node enters the scene tree for the first time.
func _ready():
	health = 3
	LetterContainer.get_theme_stylebox("Panel").set("bg_color", initial_color)
	NewLetterDelayTimer.wait_time = LetterInterval
	for i in range(26):
		alphabet.append(String(String.chr(65 + i)))
	print(alphabet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if(!gameRunning):
		return
	if(alphabet.has(event.as_text()) and event.is_released()):
		await input_check(event.as_text())
	pass
func _NewLetterDelayTimer_timeout():
	await incorrect_letter(true)
	pass
func input_check(letter : String):
	if(!awaitingLetter):
		return
	NewLetterDelayTimer.stop()
	play_dance()
	LettersLeft -= 1
	if(letter == currentLetter):
		await correct_letter()
	else:
		await incorrect_letter(false)
	

func incorrect_letter(timeout : bool):
	awaitingLetter = false
	if(timeout):
		print("took too long to press letter")
	else:
		print("incorrect letter")
	await _change_panel_color_and_fade(Color.FIREBRICK, 0.25)
	await damage_health()

func damage_health():
	match health:
		3:
			Shaman3.visible = false
			ShamanDead3.visible = true
		2:
			Shaman2.visible = false
			ShamanDead2.visible = true
		1:
			Shaman1.visible = false
			ShamanDead1.visible = true
	health -= 1
	if(health == 0):
		end_game(false)
	else:
		await _generate_next_letter()
	
func correct_letter():
	awaitingLetter = false
	await _change_panel_color_and_fade(Color.CHARTREUSE, 0.25)
	print("correct letter")
	if(LettersLeft == 0):
		end_game(true)
	else:
		_generate_next_letter()
	pass
		
func _change_panel_color_and_fade(target_color: Color, duration: float):
	var style_box = LetterContainer.get_theme_stylebox("panel") as StyleBoxFlat
	if not style_box:
		style_box = StyleBoxFlat.new()
		LetterContainer.add_theme_stylebox_override("panel", style_box)
	var tween = get_tree().create_tween()
	tween.tween_property(style_box, "bg_color", target_color, duration)
	await(tween.finished)
	await get_tree().create_timer(LetterInterval).timeout
	tween = get_tree().create_tween()
	tween.tween_property(LetterContainer, "modulate", Color(1,1,1,0), 0.25)
	await(tween.finished)
func _begin_game():
	match difficulty:
		1:
			print("Easy difficulty")
			AmountOfLetters = 10
			LetterInterval = 1
		2: 
			print("Normal difficulty")
			AmountOfLetters = 15
			LetterInterval = 0.6
		3: 
			print("Hard Difficulty")
			AmountOfLetters = 20
			LetterInterval = 0.45
	LettersLeft = AmountOfLetters
	health = 3
	Moon.visible = false
	var duration = 0.45
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(MainMenu, "modulate", Color(1,1,1,0), duration)
	tween.tween_property(cam, "offset", Vector2(camoffx, camoffy), duration)
	tween.tween_property(cam, "zoom", Vector2(camzoom, camzoom), duration)
	await(tween.finished)
	MainMenu.visible = false
	await get_tree().create_timer(1).timeout
	gameRunning = true
	await _generate_next_letter()
	pass
func end_game(victory : bool):
	print("game ended")
	
	if(victory):
		print("victory")
		Moon.visible = true
		EndLabel.text = "RITUAL COMPLETE!"
		
	else:
		print("defeat")
		Moon.visible = false
		EndLabel.text = "RITUAL FAILED!"
	gameRunning = false
	NewLetterDelayTimer.stop()
	EndScreen.visible = true
	var duration = 0.45
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(cam, "offset", Vector2(0, 0), duration)
	tween.tween_property(cam, "zoom", Vector2(1, 1), duration)
	await(tween.finished)
	tween = get_tree().create_tween()
	tween.tween_property(EndScreen, "modulate", Color(1,1,1,1), duration)
	
func return_menu():
	Shaman1.visible = true
	Shaman2.visible = true
	Shaman3.visible = true
	ShamanDead1.visible = false
	ShamanDead2.visible = false
	ShamanDead3.visible = false
	var duration = 0.45
	var tween = get_tree().create_tween()
	tween.tween_property(EndScreen, "modulate", Color(1,1,1,0), duration)
	await(tween.finished)
	EndScreen.visible = false
	MainMenu.visible = true
	tween = get_tree().create_tween()
	tween.tween_property(MainMenu, "modulate", Color(1,1,1,1), duration)
func _on_hard_button_toggled(toggled_on : bool):
	if(toggled_on):
		difficulty = 3
func _on_normal_button_toggled(toggled_on : bool):
	if(toggled_on):
		difficulty = 2
func _on_easy_button_toggled(toggled_on : bool):
	if(toggled_on):
		difficulty = 1
func _generate_next_letter():
	print("Generating new letter")
	var style_box = LetterContainer.get_theme_stylebox("panel") as StyleBoxFlat
	style_box.set("bg_color", initial_color)
	LetterContainer.get_parent().set("position", Vector2(285,140))
	currentLetter = alphabet.pick_random()
	LetterLabel.text = currentLetter
	awaitingLetter = true
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(LetterContainer.get_parent(), "position",Vector2(285, 120) , 0.25)
	tween.tween_property(LetterContainer, "modulate", Color(1,1,1,1), 0.25)
	await(tween.finished)
	NewLetterDelayTimer.start(LetterInterval)
func play_dance():
	for child in Congregation.get_children():
		if child is AnimatedSprite2D:
			var timer = get_tree().create_timer(randf()*0.1).timeout.connect(child.play)
