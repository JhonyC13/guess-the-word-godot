extends CanvasLayer

@onready var mensagem_erro_label = $mensagem_erro_label

func _ready():
	mensagem_erro_label.text = Global.texto_erro
