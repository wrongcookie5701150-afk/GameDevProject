class_name Player extends CharacterBody2D

# กำหนดความเร็วการเคลื่อนที่
@export var speed: float = 150.0

# using name space
@onready var _animated_sprite = $AnimatedSprite2D

# กำหนดตัวแปรเรื่มต้นสำหรับเทียบ state
var cardinal_direction : Vector2 = Vector2.DOWN #(0,1)
var direction : Vector2 = Vector2.ZERO #(0,0)
var state: String = "Idle" 

# Declare at the top level (outside any func)
@export var player_radius: Vector2 = Vector2(8, 8)

const MAP_WIDTH: float = 480.0
const MAP_HEIGHT: float = 240.0

func _ready() -> void:
	if _animated_sprite:
		_animated_sprite.play(state + "_" + AnimatedDirection())

func clamp_position_to_map() -> void:
	position.x = clampf(position.x, player_radius.x, MAP_WIDTH - player_radius.x)
	position.y = clampf(position.y, player_radius.y, MAP_HEIGHT - player_radius.y)

# ฟังก์ชันหลักของการเคลื่อนที่
func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("Left", "Right", "Up", "Down")
	if direction == Vector2.ZERO:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = direction * speed
	move_and_slide()
	clamp_position_to_map()
	
	#print("State: ", state, " Direction: ", AnimatedDirection())
	
	var state_changed: bool = setState()
	var dir_changed: bool = setDirection()
	if (state_changed or dir_changed) and _animated_sprite:
		_animated_sprite.play(state + "_" + AnimatedDirection())
		
# ส่ง flag "Walk" or "Idle"
func setState() -> bool:
	var new_state: String = "Idle" if direction == Vector2.ZERO else "Walk" #อ่านทิศทาง
	if new_state == state:
		return false
	state = new_state
	return true

# ส่ง flag Direction
func setDirection() -> bool:
	if direction == Vector2.ZERO:
		return false
		
	var new_direction : Vector2 = cardinal_direction
	if abs(direction.x) > abs(direction.y):
		new_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif abs(direction.y) > abs(direction.x):
		new_direction = Vector2.UP if direction.y < 0 else Vector2.DOWN
	else:
		if direction.x != 0:
			new_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
		elif direction.y != 0:
			new_direction = Vector2.UP if direction.y < 0 else Vector2.DOWN

	if new_direction == cardinal_direction:
		return false
	cardinal_direction = new_direction
	return true

# ส่งทิศทางจริง
func AnimatedDirection() -> String:
	if cardinal_direction == Vector2.UP:
		return "Up"
	elif cardinal_direction == Vector2.LEFT:
		return "Left"
	elif cardinal_direction == Vector2.RIGHT:
		return "Right"
	return "Down"
