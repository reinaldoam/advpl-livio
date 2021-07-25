#INCLUDE "Protheus.ch"


User Function XGATNJJ4()

	Local aArea 	:= getArea()
	Local cAlias 	:= getNextAlias()
	Local cTipRom	:= M->NJJ_TIPO		// 6=Devolucao de deposito
	Local cRom		:= M->NJJ_TIPENT	// 0=Com Pesagem e 2=Sem Pesagem
	Local xRet


	IF cTipRom = '6'
	
		IF cRom = '0'
			xRet := Posicione('NJR',1,xFilial('NJR')+M->NJJ_CODCTR,'NJR_TESQTE')
		ENDIF
	
		IF cRom = '2'
			xRet := Posicione('NJR',1,xFilial('NJR')+M->NJJ_CODCTR,'NJR_TESRSI')
		ENDIF
	
	ELSE
	
		xRet := Posicione('NJR',1,xFilial('NJR')+M->NJJ_CODCTR,'NJR_TESEST')
	
	ENDIF

Return xRet
