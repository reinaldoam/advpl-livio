#INCLUDE "Protheus.ch"

User Function XGATNJJ()

	Local aArea := getArea()
	Local cAlias := getNextAlias()
	Local nTotPs	:= 0
	Local nTotPs	:= Round((M->NJJ_X_PSE1 + M->NJJ_X_PSE2 + M->NJJ_X_PSE3 + M->NJJ_X_PSE4 + M->NJJ_X_PSE5),4)
	Local nTotGr	:= 0
	Local nTotGr	:= Round((M->NJJ_X_PGR1 + M->NJJ_X_PGR2 + M->NJJ_X_PGR3 + M->NJJ_X_PGR4 + M->NJJ_X_PGR5),4)
	Local nIndQbt	:= GetMv('MV_X_QBT')
	Local nIndGrd	:= GetMv('MV_X_DGR')
	Local cTploc1	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC1,'NNR_X_TIPO')
	Local cTploc2	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC2,'NNR_X_TIPO')
	Local cTploc3	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC3,'NNR_X_TIPO')
	Local cTploc4	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC4,'NNR_X_TIPO')
	Local cTploc5	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC5,'NNR_X_TIPO')
	Private nQbt	:= 0
	Private nGrd	:= 0
	Private nDesExt	:= 0
	
	

// Zerar campos 
	M->NJJ_X_QBT 	:= 0
	M->NJJ_X_GRD 	:= 0
	M->NJJ_PSEXTR	:= 0
	
// Calcular quebra tecnica de acordo com tipo do local de armazenagem 
	IF cTploc1 <> 'X'
		nQbt := Round((M->NJJ_X_PSE1 * nIndQbt),4)
	ENDIF
	
	IF cTploc2 <> 'X'
		nQbt += Round((M->NJJ_X_PSE2 * nIndQbt),4)
	ENDIF
	
	IF cTploc3 <> 'X'
		nQbt += Round((M->NJJ_X_PSE3 * nIndQbt),4)
	ENDIF
	
	IF cTploc4 <> 'X'
		nQbt += Round((M->NJJ_X_PSE4 * nIndQbt),4)
	ENDIF
	
	IF cTploc5 <> 'X'
		nQbt += Round((M->NJJ_X_PSE5 * nIndQbt),4)
	ENDIF
	
	M->NJJ_X_QBT := nQbt
	
	
	
// Calcular desconto de qualidade do grao de roca
	nGrd := Round((nTotGr * nIndGrd),4)
	
	M->NJJ_X_GRD := nGrd

	
// Calcular desconto extra NJJ_PSEXTR
	nDesExt := M->NJJ_PSSUBT - (nTotPs - nQbt) 
	

	
Return ({nQbt,nGrd,nDesExt})
