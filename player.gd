extends CharacterBody2D

var grass_layer : TileMapLayer  # Camada de grama
var wall_layer : TileMapLayer   # Camada de paredes
var tile_size = Vector2(16, 16)  # Tamanho do tile

var caminho = []  # Lista com as posições do caminho
var velocidade = 200  # Velocidade de movimento do personagem
var proximo_ponto_index = 0  # Índice do próximo ponto no caminho

@export var friend: CharacterBody2D

func _ready():
	grass_layer = get_node("/root/Maze/Grass")  # Referência para a camada de grama
	wall_layer = get_node("/root/Maze/Walls")    # Referência para a camada de paredes
	
	var friend_pos_global = friend.global_position

	# Converte a posição global para coordenadas do tile
	var friend_pos_tile = friend_pos_global / tile_size
	friend_pos_tile = friend_pos_tile.floor() # Converte para inteiro
	
	# Inicia a busca pelo caminho
	var start = Vector2(6, 7)  # Ponto de partida 

	var goal = friend_pos_tile   # Ponto de destino
	caminho = busca_em_largura(start, goal)
	
func busca_em_largura(start: Vector2, goal: Vector2) -> Array:
	var queue = []  # Fila para os pontos a serem visitados
	var visited = {}  # Dicionário para os pontos visitados
	var came_from = {}  # Para reconstruir o caminho

	# Adiciona o ponto de partida à fila
	queue.append(start)
	visited[start] = true

	while queue.size() > 0:
		var current = queue.pop_front()  # Remove o primeiro elemento da fila
		
		# Verifica se chegou ao objetivo
		if current == goal:
			return reconstruir_caminho(came_from, current)

		# Verifica as células adjacentes (cima, baixo, esquerda, direita)
		for direction in [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]:
			var neighbor = current + direction
			
			# Verifica se o vizinho é um caminho válido
			if is_walkable(neighbor) and not visited.has(neighbor):
				queue.append(neighbor)
				visited[neighbor] = true
				came_from[neighbor] = current  # Registra de onde veio

	return []  # Retorna uma lista vazia se não encontrar o caminho

func reconstruir_caminho(came_from: Dictionary, current: Vector2) -> Array:
	var path = []
	while current in came_from:
		path.append(current)
		current = came_from[current]
	path.reverse()  # Inverte o caminho para do início ao fim
	return path

func _physics_process(delta):
	if proximo_ponto_index < caminho.size():
		var celula = caminho[proximo_ponto_index]
		
		# Converte a célula para a posição do mundo manualmente
		var proximo_ponto = celula * tile_size

		# Calcula a direção do movimento
		var direcao = (proximo_ponto - global_position).normalized()
		velocity = direcao * velocidade  # Atualiza a velocidade do personagem
		
		# Movimenta o personagem
		move_and_slide()

		# Verifica se o personagem chegou perto o suficiente do próximo ponto
		if global_position.distance_to(proximo_ponto) < 5:  # Tolerância de 5 pixels
			proximo_ponto_index += 1  # Avança para o próximo ponto
	else:
		velocity = Vector2.ZERO  # Para o movimento quando chega ao destino
		move_and_slide()  # Chama move_and_slide() com velocidade zero para parar

# Função para verificar se a posição atual é um caminho válido
func is_walkable(pos: Vector2) -> bool:
	var grass_id = grass_layer.get_cell_source_id(pos)
	var wall_id = wall_layer.get_cell_source_id(pos)
	
	# Verifica se a célula na camada de grama é válida e se não é uma parede
	return (grass_id != -1) and (wall_id == -1)
