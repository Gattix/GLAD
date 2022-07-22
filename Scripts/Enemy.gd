extends KinematicBody2D

var health = 5
var knockback_power = 100
onready var knockback_vector = Vector2.ZERO
onready var damageParticles = $AnimatedSprite/Particles2D


func _physics_process(delta):
	if damageParticles.emitting:
		move_and_slide(knockback_vector*knockback_power)
		print(knockback_vector)

func _process(delta):
	if health <= 0:
		$AnimationPlayer.play("Death")

func getHitted():
	damageParticles.emitting = true
	
	move_and_slide(knockback_vector*knockback_power)
	health -= 1


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Death":
		queue_free()
