extends Position3D


onready var meshhelper = get_node("MeshInstance")
onready var faceinghelper = get_node("facing/MeshInstance")

func _ready():
	meshhelper.hide()
	faceinghelper.hide()

