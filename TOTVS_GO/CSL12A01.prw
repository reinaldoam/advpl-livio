// #########################################################################################
// Projeto: Casul
// Modulo : Loja
// Fonte  : CSL12A01
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 17/05/19 | Ricardo Mendes    | Rotina para Gravação de dados da Receita Agronomica - Loja
// 09/12/19 | Chandrer Silva    | Atualizacao com Personalizacoes
// ---------+-------------------+-----------------------------------------------------------

#Include "Protheus.ch"
#Include "Topconn.ch"
#include 'Parmtype.ch'
#DEFINE ENTER Chr(10)+Chr(13)

User Function CSL12A01(cRotUsada)
	Local cItem		:= ""
	Local cProd		:= ""
	Local cNota		:=""
	Local cSerie	:=""
	Local cCliente	:=""
	Local cLoja		:=""
	Local cTecni	:= ""
	Local _aArea	:= GetArea()
	Local lReceita	:= .F.
	//Local lAutRece	:= Alltrim(SuperGetMV("CS_AUTREC",,"N")) == "S"
	Local lPorItem	:= SuperGetMV( "CS_PORITE",,"N" ) == "S"
	Local nFazItem	:= 0
	Private aListITM	:= {}

	Private lEhOracle:= (TCGetDB() == "ORACLE")

	Default cRotUsada := FUNNAME()

	//Captura o Tecnico Informado no Pedido
	cTecni	:= SL1->L1_XTECNIC

	//Verifica se existe produto que utiliza receita
	lReceita:= SL1->L1_XRECEIT == "S"

	If lReceita

		cNota	:= SL1->L1_DOC
		cSerie	:= SL1->L1_SERIE
		cCliente:= SL1->L1_CLIENTE
		cLoja	:= SL1->L1_LOJA

		IF !Empty(cNota) .AND. !Empty(cSerie) .AND. !Empty(cCliente) .AND. !Empty(cLoja) .AND. !Empty(cTecni)
			//Atualizar os itens que estão com a cultura informada no pedido
			AtualD2(cNota,cSerie, cCliente,cLoja)
			
			IF lPorItem
				//Atualizar Tabela de Receituário (ZB6)
				IF Len(aListITM) > 0
					//Atualizar Tabela de Receituário (ZB6)
					for nFazItem := 1 to Len(aListITM)
						cItem := aListITM[nFazItem, 2]
						cProd := aListITM[nFazItem, 3]
						cNApl := aListITM[nFazItem, 4]
						cIAdi := aListITM[nFazItem, 5]
						//u_InclZB6(cItem, cProd, cTecni,cNota, cSerie, cCliente, cLoja, cRotUsada )
						u_InclZB6(cItem, cProd, cTecni,cNota, cSerie, cCliente, cLoja, cRotUsada, cNApl, cIAdi )
					next nFazItem
				EndIF
			Else
				//Atualizar Tabela de Receituário (ZB3)
				U_IncluiZB3(cTecni,cNota, cSerie, cCliente, cLoja, cRotUsada )
			EndIF

		EndIF

	EndIf

	RestArea(_aArea)

Return .T.

//Função para atualizar os produtos Do Pedido x Nota
Static Function AtualD2(cDoc, cSer, cCliFor, cLoj)
	Local cQuery6	:= ""
	Local cAlias6   := GetNextAlias()
	Local aRetSD2	:= {}

	//cQuery6:= "select D2_ITEMPV, D2_COD, SD2.R_E_C_N_O_ AS SD2RED, D2_ITEM "
	cQuery6:= "select D2_ITEMPV, D2_COD, SD2.R_E_C_N_O_ AS SD2RED, D2_ITEM, D2_XNAPLIC, D2_XOBSERV"
	cQuery6 +="FROM "+RetSqlName("SD2")+" SD2 "
	cQuery6	+="WHERE SD2.D_E_L_E_T_ = ' ' "
	cQuery6 +="AND D2_DOC     = '"+cDoc+"' "
	cQuery6 +="AND D2_SERIE   = '"+cSer+"' "
	cQuery6 +="AND D2_CLIENTE = '"+cCliFor+"' "
	cQuery6 +="AND D2_LOJA    = '"+cLoj+"' "
	cQuery6 +="and D2_filial  = '"+xFilial("SD2")+"' "

	cQuery6 := ChangeQuery(cQuery6)

	If Select(cAlias6) <> 0
		(cAlias6)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery6),cAlias6,.T.,.T.)

	While !(cAlias6)->(eof())
		SD2->(dbGoto((cAlias6)->SD2RED))

		aRetSD2	:= ItemPed(cDoc, cSer, (cAlias6)->D2_ITEMPV, (cAlias6)->D2_COD)

		IF Len(aRetSD2) > 0
			RecLock("SD2",.F.)
 			SD2->D2_XCULTUR := aRetSD2[1]
	 		SD2->D2_XDIAGNO := aRetSD2[2]
		 	SD2->D2_XEQUIPO	:= aRetSD2[3]
		 	//SD2->D2_XNAPLIC	:= aRetSD2[4]
		 	//SD2->D2_XOBSERV	:= aRetSD2[5]
			SD2->(msUnlock())
			
			If !Empty(SD2->D2_XCULTUR)
			 //aadd(aListITM, {(cAlias6)->SD2RED, (cAlias6)->D2_ITEM, (cAlias6)->D2_COD})
			 aadd(aListITM, {(cAlias6)->SD2RED, (cAlias6)->D2_ITEM, (cAlias6)->D2_COD, aRetSD2[4], aRetSD2[5]})
   EndIf
		EndIF

		(cAlias6)->(dbSkip())
	Enddo
	(cAlias6)->(dbCloseArea())

Return .T.

//Função para achar a cultura, diagnostico e equipamento do item do cupom para colocar item da nota
Static Function ItemPed(cDoc, cSer, cItemPV, cCodigo)
	Local aRetSL2	:= {}
	Local cQuery7	:= ""
	Local cAlias7   := GetNextAlias()

	//cQuery7:= "select distinct "+IIF(lEhOracle,"", "TOP 1 ")+" L2_XCULTUR, L2_XDIAGNO, L2_XEQUIPO "
	cQuery7:= "select distinct "+IIF(lEhOracle,"", "TOP 1 ")+" L2_XCULTUR, L2_XDIAGNO, L2_XEQUIPO, L2_XNAPLIC, L2_XOBSERV "
	cQuery7 +="FROM "+RetSqlName("SL2")+" SL2 "
	cQuery7 +="where SL2.d_e_l_e_t_ = ' ' "
	cQuery7 +="and L2_FILIAL	='"+xFilial("SL2")+"' "
	cQuery7 +="and L2_DOC 		= '"+cDoc+"' "
	cQuery7 +="and L2_SERIE 	= '"+cSer+"' "
	cQuery7 +="and L2_ITEM 		= '"+cItemPV+"' "
	cQuery7 +="AND L2_PRODUTO 	= '"+cCodigo+"' "

	If lEhOracle
		cQuery7 +="AND ROWNUM = 1 "
	EndIF

	cQuery7 := ChangeQuery(cQuery7)

	If Select(cAlias7) <> 0
		(cAlias7)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery7),cAlias7,.T.,.T.)

	While !(cAlias7)->(eof())

		aadd(aRetSL2, (cAlias7)->L2_XCULTUR)
		aadd(aRetSL2, (cAlias7)->L2_XDIAGNO)
		aadd(aRetSL2, (cAlias7)->L2_XEQUIPO)
		aadd(aRetSL2, (cAlias7)->L2_XNAPLIC)
		aadd(aRetSL2, (cAlias7)->L2_XOBSERV)

		(cAlias7)->(dbSkip())
	Enddo
	(cAlias7)->(dbCloseArea())

Return aRetSL2

