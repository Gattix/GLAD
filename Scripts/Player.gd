extends KinematicBody2D

var speed = 10
var runSpeed = 10
var facing = directions.RIGHT
var knockback_vector
onready var animatedSprite = $PlayerSprite
onready var animationPlayer = $AnimationPlayer

enum directions {
	RIGHT,
	LEFT
}

enum states {
	IDLE,
	WALK,
	ATTACK,
	DEFEND
}
var state = states.IDLE

func _ready():
	$Hitbox/HitboxCollider.disabled = true

func _physics_process(delta):
	# Это типа свитч кейса, тут перебираются состояния персонажа, и от
	# состояния, зависит какая анимация будет, потом напишу функцию для
	# каждого состояния, что бы и системы атаки/защиты там реализовать
	match (state):
		states.IDLE:
			animatedSprite.play("idle")
		states.WALK:
			animatedSprite.play("walk")
		states.ATTACK:
			animatedSprite.play("attack")
			if facing == directions.RIGHT:
				animationPlayer.play("HitRight")
			elif facing == directions.LEFT:
				animationPlayer.play("HitLeft")
		states.DEFEND:
			animatedSprite.play("defend")
	
	# Вызываю функцию которая отвечает за передвижение что бы не писать 
	# тонну говнокода в _physics_process (FixedUpdate из Unity)
	playerMovement()

# Тут разбираю передвижение персонажа
func playerMovement():
	# получаем сторону куда жмёт игрок Инпутами
	var direction = Vector2(
		Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down")-Input.get_action_strength("move_up")
	)
	# нормализуем, что бы по диагонали не двигался имбово быстро, баг такой был бы
	direction = direction.normalized()
	var velocity = direction * speed
	# само движение
	velocity = move_and_slide(velocity)
	
	# Поворот спрайта за мышкой, флип
	if get_global_mouse_position() < position:
		animatedSprite.flip_h = false
		facing = directions.LEFT
		knockback_vector = Vector2(-1, 0)
	elif get_global_mouse_position() > position:
		animatedSprite.flip_h = true
		facing = directions.RIGHT
		knockback_vector = Vector2(1, 0)
	
	# Когда персонаж не атакует, играется анимация ходьбы или Идле, чекается
	# движение, если нулевое, идле. Чек на атаку нужен что бы анимация атаку
	# не перебивала
	if direction != Vector2.ZERO and state != states.ATTACK:
		state = states.WALK
	elif direction == Vector2.ZERO and state != states.ATTACK:
		state = states.IDLE
	
	# Вызываются функции атаки и дефенда
	attack()
	defend()

# Функция атаки, тут чекается нажал ли кнопку и вызывается состояние
func attack():
	if Input.is_action_just_released("attack"):
		state = states.ATTACK
		

# Функция защиты, делает тоже самое что и атака, но если отпустить кнопку
# убирает анимацию защиты
func defend():
	if Input.is_key_pressed(KEY_SHIFT):
		state = states.DEFEND
	if !Input.is_key_pressed(KEY_SHIFT) and state == states.DEFEND:
		state = states.IDLE

# Ивент на окончание анимации
func _on_PlayerSprite_animation_finished():
	# Проверяем было ли последним состоянием Атака, что бы заменить на Идле
	# при окончании анимации
	if state == states.ATTACK:
		state = states.IDLE

# Вызывается когда враг попадает в хитбокс игрока
func _on_Hitbox_body_entered(body):
	body.knockback_vector = knockback_vector
	body.getHitted()
