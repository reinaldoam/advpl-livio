#INCLUDE "Protheus.ch"

User Function XGATNJM()

	Local aArea 	:= getArea()
	Local cAlias 	:= getNextAlias()
	Local nRatRom	:= 0
	Local nTotPs	:= 0
	Local nQbt		:= 0
	Local nIndQbt	:= GetMv('MV_X_QBT')
	Local cTploc1	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC1,'NNR_X_TIPO')
	Local cTploc2	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC2,'NNR_X_TIPO')
	Local cTploc3	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC3,'NNR_X_TIPO')
	Local cTploc4	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC4,'NNR_X_TIPO')
	Local cTploc5	:= Posicione('NNR',1,xFilial('NNR')+M->NJJ_X_LOC5,'NNR_X_TIPO')
	Local xRet		:= 0
	
	IF M->NJJ_TIPO = '3'

		IF M->NJM_LOCAL = M->NJJ_X_LOC1
			
			nTotPs	:= M->NJJ_X_PSE1			
			
			IF cTploc1 <> 'X'
				nQbt 	:= Round((M->NJJ_X_PSE1 * nIndQbt),4)
			ENDIF
		
		ENDIF
		
		
		IF M->NJM_LOCAL = M->NJJ_X_LOC2

			nTotPs	+= M->NJJ_X_PSE2
			
			IF cTploc2 <> 'X'
				nQbt 	+= Round((M->NJJ_X_PSE2 * nIndQbt),4)
			ENDIF
			
		ENDIF
		
		
		IF M->NJM_LOCAL = M->NJJ_X_LOC3

			nTotPs	+= M->NJJ_X_PSE3
			
			IF cTploc3 <> 'X'
				nQbt 	+= Round((M->NJJ_X_PSE3 * nIndQbt),4)
			ENDIF
			
		ENDIF
		
		
		IF M->NJM_LOCAL = M->NJJ_X_LOC4

			nTotPs	+= M->NJJ_X_PSE4
		
			IF cTploc4 <> 'X'
				nQbt 	+= Round((M->NJJ_X_PSE4 * nIndQbt),4)
			ENDIF
			
		ENDIF
		
		
		IF M->NJM_LOCAL = M->NJJ_X_LOC5

			nTotPs	+= M->NJJ_X_PSE5
			
			IF cTploc5 <> 'X'
				nQbt 	+= Round((M->NJJ_X_PSE5 * nIndQbt),4)
			ENDIF
			
		ENDIF
		
		nRatRom	:= Round(nTotPs - nQbt,4)
		xRet	:= nRatRom

	ENDIF	
		
Return xRet
	

