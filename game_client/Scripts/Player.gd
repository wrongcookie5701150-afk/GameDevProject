class_name Player extends CharacterBody2D

# กำหนดความเร็วการเคลื่อนที่
@export var speed: float = 125.0

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

func clamp_position_to_map() -> void:
	position.x = clampf(position.x, player_radius.x, MAP_WIDTH - player_radius.x)
	position.y = clampf(position.y, player_radius.y, MAP_HEIGHT - player_radius.y)

# ฟังก์ชันหลักของการเคลื่อนที่
func _physics_process(_delta: float) -> void:
	direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	direction.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	direction = direction.normalized()
	
	velocity =  direction * speed
	move_and_slide()
	clamp_position_to_map()
	
	#print("State: ", state, " Direction: ", AnimatedDirection())
	
	if setState() == true || setDirection() == true:
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
	var new_direction : Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return false
		
	if direction.x == 0:
		new_direction = Vector2.UP if direction.y < 0 else Vector2.DOWN
	if direction.y == 0:
		new_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
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
