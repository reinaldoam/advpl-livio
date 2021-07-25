#INCLUDE "Protheus.ch"

User Function XGATNJJ2()

	Local aArea 	:= getArea()
	Local cAlias 	:= getNextAlias()
	Local nTotPs	:= 0
	Local nTotPs	:= Round((M->NJJ_X_PSE1 + M->NJJ_X_PSE2 + M->NJJ_X_PSE3 + M->NJJ_X_PSE4 + M->NJJ_X_PSE5),4)
	Local nQbt		:= M->NJJ_X_QBT
	Local nDesExt	:= 0
	Local xRet
	
	
// Calcular desconto extra NJJ_PSEXTR
	nDesExt := M->NJJ_PSSUBT - (nTotPs - nQbt) 
	xRet	:= nDesExt
	

Return xRet
