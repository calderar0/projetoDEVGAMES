extends PanelContainer
@export var item: Weapon:
	set(value):
		# 1. (Opcional, mas mantido do seu código) Reseta o item ANTIGO antes de trocá-lo.
		# A variável 'item' aqui ainda se refere ao valor antigo, antes da nova atribuição.
		if item != null and item.has_method("reset"):
			item.reset()

		# --- AQUI COMEÇA A CORREÇÃO PRINCIPAL ---

		# 2. Atribui o novo valor à variável de classe.
		item = value
		
		# 3. Agora, verificamos se o item recém-atribuído NÃO é nulo.
		if item != null:
			# O slot está recebendo uma nova arma.
			# Atualiza a UI e a lógica com os dados da nova arma.
			$TextureRect.texture = item.icon
			$Cooldown.wait_time = item.cooldown
			# É uma boa prática (re)iniciar o timer quando uma nova arma é equipada.
			$Cooldown.call_deferred("start")
			item.slot = self
			

		else:
			# O slot está sendo esvaziado (item é nulo).
			# Limpa a UI e para a lógica.
			$TextureRect.texture = null
			$Cooldown.stop() # Para o timer, já que não há mais arma.
			

		
		
func  _physics_process(delta):
	if item != null and item.has_method("update"):
		item.update(delta)

func _on_cooldown_timeout() -> void:
	if item:
		$Cooldown.wait_time = item.cooldown
		item.activate(owner,owner.nead_enemy, get_tree())
		
