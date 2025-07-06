extends PanelContainer

@export var item: PassiveItem:
	set(value):
		# 1. Atribui o novo valor à variável de classe.
		item = value

		# 2. Agora, verificamos se o item recém-atribuído NÃO é nulo.
		if item != null:
			# O slot está recebendo um novo item passivo.
			# Atualiza a UI e a lógica com os dados do novo item.
			$TextureRect.texture = item.texture
			item.passiveslot = self
			
			# Também é uma boa ideia já atribuir a referência do jogador aqui,
			# pois isso funciona tanto no início quanto durante o jogo.
			if player_refe != null:
				item.player_ref = player_refe
			
		else:
			# O slot está sendo esvaziado (item é nulo).
			# Limpa a UI.
			$TextureRect.texture = null
			

@export var player_refe: CharacterBody2D

func _ready() -> void:
	if item != null:
		item.player_ref = player_refe  # Atribua o player_ref ao item
		
