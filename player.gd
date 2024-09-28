extends CharacterBody2D

@export var speed = 400 # Velocidade do jogador (pixels/sec).
var screen_size # Tamanho da janela do jogo.

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	var velocity = Vector2.ZERO # O vetor de movimento do jogador.
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Use move_and_slide com a velocidade
	position += velocity * delta

	# Limitar a posição do jogador na tela
	position = position.clamp(Vector2.ZERO, screen_size)
	move_and_slide()
