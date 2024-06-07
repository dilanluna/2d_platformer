extends ParallaxBackground


@export var background_speed = 25

func _process(delta):
	scroll_offset.y += background_speed * delta
