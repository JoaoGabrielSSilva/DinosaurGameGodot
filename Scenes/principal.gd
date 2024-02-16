extends Node

const PLAYER_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var velocidade : float
const START_SPEED : float = 10.0

const MAX_SPEED : int = 25
# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func new_game():
	#resetar os nodes
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0 , 0)
	$Camera2D.position = CAM_START_POS
	$Chao.position = Vector2i(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocidade = START_SPEED

	#mover o jogador e a câmera
	$Player.position.x += velocidade
	$Camera2D.position.x += velocidade
