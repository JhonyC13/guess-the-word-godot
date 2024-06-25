class_name LevelInfo extends Resource #Resources are data containers

var level_name:String
var level_resource_path:String
var dialogue_file:String
var level_state:int
var completed:bool = false

func _init(l_name:String,l_resource_path:String,d_file:String='',l_state:int=0,comp:bool=false):
	self.level_name = l_name
	self.level_resource_path = l_resource_path
	self.dialogue_file = d_file
	self.level_state = l_state
	self.completed = comp
