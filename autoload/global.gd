extends Node

signal score_changed

var bg_pattern := preload("res://assets/BG_pattern.png") #armazena o padrão de fundo do jogo

var ponto_exclamacao_atual := 1 #para saber por quantos ponto de exclamação o jogador já passou
var maior_fase_desbloqueada := 1 #armazena o numero da maior fase desbloqueada

var fase_atual := 1 #armazena o numero da fase em que o jogador está no momento
var palavra_fase := ["P"] #armazena a palavra da fase atual
var dica_fase := "Insira a dica aqui" #armazena a dica da fase atual

var pontuacao := 0
var chances := 5 #numero de chances para acertar a palavra
var pontosLetra := 20 #qtd de pontos por letra correta

var texto_erro: String
