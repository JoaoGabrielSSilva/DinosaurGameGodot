extends CharacterBody2D

const GRAVIDADE : int = 4200
const VELOCIDADE_PULO : int = -1800

func _physics_process(delta):
	velocity.y += GRAVIDADE * delta 
	
	if is_on_floor():
		$CorrendoColisao.disabled = false
		if Input.is_action_pressed("pular"):
			velocity.y = VELOCIDADE_PULO
		elif Input.is_action_pressed("agachar"):
			$AnimatedSprite2D.play("agachar")
			$CorrendoColisao.disabled = true
		else: 
			$AnimatedSprite2D.play("correr")
	else:
		$AnimatedSprite2D.play("pular")
	move_and_slide()
