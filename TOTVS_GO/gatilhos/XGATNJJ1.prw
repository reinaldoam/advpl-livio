#INCLUDE "Protheus.ch"

User Function XGATNJJ1()

	Local aArea := getArea()
	Local cAlias := getNextAlias()
	Local nQbt		:= 0
	Local nTotPs	:= Round((M->NJJ_X_PSE1 + M->NJJ_X_PSE2 + M->NJJ_X_PSE3 + M->NJJ_X_PSE4 + M->NJJ_X_PSE5),4)
	Local nIndQbt	:= GetMv('MV_X_QBT')
	Local cTploc1	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC1,'NNR_X_TIPO')
	Local cTploc2	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC2,'NNR_X_TIPO')
	Local cTploc3	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC3,'NNR_X_TIPO')
	Local cTploc4	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC4,'NNR_X_TIPO')
	Local cTploc5	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC5,'NNR_X_TIPO')
	Local xRet		:= 0
	
IF M->NJJ_TIPO = '3'
	
// Calcular quebra tecnica de acordo com tipo do local de armazenagem 
	M->NJJ_X_QBT := 0
	
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
	
	xRet := nQbt

ENDIF	
	
Return xRet
	

