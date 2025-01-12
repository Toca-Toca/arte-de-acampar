extends Node

const DIAS_VIRTUAIS = 3

## quanto menor mais rapido
var fator_fome = 250.0   
var fator_sede = 180.0    
var fator_stamina = 50.0  
var fator_recupera_stamina = 70.0

export (float) var segundosRestantes=0.0
export (int) var hora=6
export (int) var minutos=0 
export (int) var dia=1

export (float) var debug=0.0

export (float) var saude=1.0
export (float) var stamina=1.0
export (float) var fome=1.0
export (float) var sede=1.0

# intensidade do esforço é usada para calcular o gasto da stamina constante
export (float) var esforco=0.0

export (NodePath) var path_hud_inventario
onready var hud_inventario=get_node(path_hud_inventario)

export (NodePath) var personagem_path
onready var personagem=get_node(personagem_path)

export (NodePath) var path_hud 
onready var hud=get_node(path_hud)

# o personagem chama essa função aqui.
func recebe_dano(dano:int):
	print("tomou pau:"+str(dano))
	saude-=float(dano)/100.0;
	hud.show_blood();
	#personagem.recebe_dano(dano)

func ataca(alvo):
	if (alvo is Destrutivel) or (alvo is Animal):
		var dano=2;
		var item_equipado=hud_inventario.get_item_equipado();
		if "dano" in item_equipado:	dano=item_equipado["dano"];
		
		print("atacou "+alvo.nome+" e atingiu: "+str(dano))
		personagem.ataca(alvo,dano)


func esforcar(fat):
	stamina-=(1/fator_stamina)*fat

func is_cansado():
	return stamina<0.3
  

func _ready():
	segundosRestantes=Global.tempo_de_jogo*60
	## carrega inventario de acordo com a dificuldade
	hud_inventario=get_node(path_hud_inventario)
	hud_inventario.inventario= Global.INVENTARIOS[Global.dificuldade]
	hud_inventario.atualiza()
	
func atualiza_relogio():
	var minutos_totais=DIAS_VIRTUAIS*24*60
	var fator_minutos_virtuais=minutos_totais/float(Global.tempo_de_jogo)
	var minutos_virtuais_restantes=(segundosRestantes/60.0)*fator_minutos_virtuais
	# offset 360 minutos para começar 6 da manhã 
	var minutos_virtuais_passados=(minutos_totais-minutos_virtuais_restantes)+360.0
	#debug=minutos_virtuais_restantes
	minutos=int(minutos_virtuais_passados)%60
	hora=int(minutos_virtuais_passados/60.0);
	dia=hora/24
	hora=hora%24 
	 
func is_dia(): 
	return hora>=6 and hora<=18

func _process(delta):
	segundosRestantes-=delta
	atualiza_relogio() 
	
	fome-=delta/fator_fome
	sede-=delta/fator_sede
	stamina-=(delta/fator_stamina)*esforco
	stamina+=delta/fator_recupera_stamina

	stamina=clamp(stamina,0.0,1.0) 
	fome=	clamp(fome,0.0,1.0)
	sede=	clamp(sede,0.0,1.0)
	saude=	clamp(saude,0.0,1.0)

	# se alguma variavel desta for menor do que zero é game over
	for v in [saude,fome,sede,segundosRestantes]:
		if v<=0:
			Global.gameover()
			pass
	


func instancia_coletavel(codigo_item:String,quantidade:int,posicao:Vector3):
	var prefab_coletavel = preload("res://prefabs/Coletavel.tscn").instance()
	get_node("..").add_child(prefab_coletavel)
	prefab_coletavel.translation=posicao
	prefab_coletavel.set_item(codigo_item,quantidade)


	
	
