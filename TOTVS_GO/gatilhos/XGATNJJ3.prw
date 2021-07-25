#INCLUDE "Protheus.ch"

User Function XGATNJJ3()

	Local aArea 	:= getArea()
	Local cAlias 	:= getNextAlias()
	Local nTotGr	:= Round((M->NJJ_X_PGR1 + M->NJJ_X_PGR2 + M->NJJ_X_PGR3 + M->NJJ_X_PGR4 + M->NJJ_X_PGR5),4)
	Local nIndGrd	:= GetMv('MV_X_DGR')
	Local nGrd		:= 0
	Local xRet
	
	

// Calcular desconto de qualidade do grao de roca
	nGrd 	:= Round((nTotGr * nIndGrd),4)
	xRet	:= nGrd

	
Return xRet
