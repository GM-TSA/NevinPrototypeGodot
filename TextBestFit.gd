extends Label

var rect
var font

func _ready():
	rect = get_rect()
	font = get_font("font")

func _process(_delta):
	#print(rect.size)
	font.size = rect.size.y
