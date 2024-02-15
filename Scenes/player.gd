extends CharacterBody2D

const GRAVIDADE : int = 4200
const VELOCIDADE_PULO : int = -1800

func _physics_process(delta):
	velocity.y += GRAVIDADE * delta 
	
	if is_on_floor():
		
		if Input.is_action_pressed("ui_accept"):
			velocity.y = VELOCIDADE_PULO
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("agachar")
		else: 
			$AnimatedSprite2D.play("correr")
	else:
		$AnimatedSprite2D.play("pular")
	move_and_slide()
