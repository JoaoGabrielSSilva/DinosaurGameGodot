extends Node

#precarregando objetos
var bolaCanhao_cena = preload("res://Scenes/bola_canhao.tscn")
var bolaEspinhos_cena = preload("res://Scenes/bola_espinhos.tscn")
var rocha_cena = preload("res://Scenes/rocha.tscn")
#var mato_cena = preload("res://Scenes/mato.tscn")
var obstaculos_voadores := [bolaCanhao_cena, bolaEspinhos_cena]
var tipos_obstaculo := [rocha_cena]
var obstaculos : Array
var altura_bola := [200, 390]

const PLAYER_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var dificuldade
const DIFICULDADE_MAXIMA : int = 2
var pontuacao : int
const MODIFICADOR_PONTUACAO : int = 10
var pontuacao_maxima : int
var velocidade : float
const MODIFICADOR_VELOCIDADE : int = 5000
const VEL_INICIAl : float = 10.0 

const VEL_MAXIMA : int = 25
var tamanho_tela : Vector2i
var altura_chao : int
var jogo_rodando : bool
var ultimo_obstaculo
# Called when the node enters the scene tree for the first time.
func _ready():
	tamanho_tela = get_window().size
	altura_chao = $Chao.get_node("Sprite2D").texture.get_height()
	$FimDeJogo.get_node("Button").pressed.connect(novo_jogo)
	novo_jogo()

func novo_jogo():
	pontuacao = 0
	mostrar_pontuacao()
	jogo_rodando = false
	get_tree().paused = false
	dificuldade = 0
	
	#deletar todos os obstáculos
	for obs in obstaculos:
		obs.queue_free()
		obstaculos.clear()
	
	#resetar os nodes
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0 , 0)
	$Camera2D.position = CAM_START_POS
	$Chao.position = Vector2i(0, 0)
	
	#resetar o hud e mostrar tela de fim de jogo
	$HUD.get_node("LabelIniciar").text = "PRESSIONE ESPAÇO PARA JOGAR"
	$FimDeJogo.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if jogo_rodando:
		velocidade = VEL_INICIAl + pontuacao / MODIFICADOR_VELOCIDADE
		if velocidade > VEL_MAXIMA:
			velocidade = VEL_MAXIMA
		ajustar_dificuldade()
		
		#gerando obstáculos
		gerar_obstaculo()
		
		#mover o jogador e a câmera
		$Player.position.x += velocidade
		$Camera2D.position.x += velocidade
		
		#atualizar pontuação
		pontuacao += velocidade
		mostrar_pontuacao()
		
		#atualizar posição do chão
		if $Camera2D.position.x - $Chao.position.x > tamanho_tela.x * 1.5:
			$Chao.position.x += tamanho_tela.x
			
		for obs in obstaculos:
			if obs.position.x < ($Camera2D.position.x - tamanho_tela.x):
				remover_obs(obs)
		
	else:
		$Player.get_node("AnimatedSprite2D").play(&"parado", 1)
		if Input.is_action_pressed("pular"):
			jogo_rodando = true
			$HUD.get_node("LabelIniciar").text = ""

func gerar_obstaculo():
	#gerando obstáculos no chão
	if obstaculos.is_empty() or ultimo_obstaculo.position.x < pontuacao + randi_range(300, 500):
		var tipo_obs = tipos_obstaculo[randi() % tipos_obstaculo.size()]
		var obs
		var maximo_obs = dificuldade + 1
		for i in range(randi() % maximo_obs + 1):
			obs = tipo_obs.instantiate()
			var altura_obs = obs.get_node("Sprite2D").texture.get_height()
			var escala_obs = obs.get_node("Sprite2D").scale
			var obs_x : int = tamanho_tela.x + pontuacao + 100 + (i * 100)
			var obs_y : int = tamanho_tela.y - altura_chao - (altura_obs * escala_obs.y / 2) + 5
			ultimo_obstaculo = obs
			adicionar_obstaculo(obs, obs_x, obs_y)
		if dificuldade == DIFICULDADE_MAXIMA:
			var tipo_obs_voador = obstaculos_voadores[randi() % obstaculos_voadores.size()]
			if (randi() % 2) == 0:
				obs = tipo_obs_voador.instantiate()
				var obs_x : int = tamanho_tela.x + pontuacao + 100
				var obs_y : int = altura_bola[randi() % altura_bola.size()]
				adicionar_obstaculo(obs, obs_x, obs_y)

func adicionar_obstaculo(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(acertar_obs)
	add_child(obs)
	obstaculos.append(obs)

func remover_obs(obs):
	obs.queue_free()
	obstaculos.erase(obs)

func acertar_obs(corpo):
	if corpo.name == "Player":
		fim_de_jogo()

func mostrar_pontuacao():
	$HUD.get_node("LabelPontuacao").text = " PONTUAÇÃO: " + str(pontuacao / MODIFICADOR_PONTUACAO)

func checar_pontuacao_maxima():
	if pontuacao > pontuacao_maxima:
			pontuacao_maxima = pontuacao
			$HUD.get_node("LabelPontuacaoMaxima").text = "PONTUAÇÃO MÁXIMA: " + str(pontuacao_maxima / MODIFICADOR_PONTUACAO)

func ajustar_dificuldade():
	dificuldade = pontuacao / MODIFICADOR_VELOCIDADE
	if dificuldade > DIFICULDADE_MAXIMA:
		dificuldade = DIFICULDADE_MAXIMA

func fim_de_jogo():
	checar_pontuacao_maxima()
	$FimDeJogo.show()
	get_tree().paused = true
	jogo_rodando = false
