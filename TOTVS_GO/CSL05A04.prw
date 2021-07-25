#Include 'Protheus.ch'
#Include "Topconn.ch"
#include 'parmtype.ch'
#DEFINE ENTER Chr(10)+Chr(13)

// #########################################################################################
// Projeto: Casul
// Modulo : Faturamento
// Fonte  : CSL05A04
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 13/05/19	| Ricardo Mendes    | Rotina para Gravação de dados da Receita Agronomica
// 09/12/19 | Chandrer Silva    | Atualizacao com Personalizacoes
// ---------+-------------------+-----------------------------------------------------------

User Function CSL05A04(cRotUsada)
  Local cNota		  := ""
  Local cSerie	  := ""
  Local cCliente	:= ""
  Local cLoja		  := ""
  Local cTecni	  := ""
  Local _aArea	  := GetArea()
  Local _aAreaF2	:= {}
  Local _aAreaC5	:= {}
  Local _aAreaC6	:= {}
  Local _aAreaD2	:= {}
  Local lReceita	:= .F.
  Local lFinPedi	:= Alltrim(SuperGetMV("CS_FINPED",,"N")) == "S" //Verifica se vai validar pedido que gerou financeiro
  Local lAutRece	:= Alltrim(SuperGetMV("CS_AUTREC",,"N")) == "S"
  Local lTransf	  := .F.
  Local lPorItem	:= SuperGetMV( "CS_PORITE",,"N" ) == "S"
  Local nFazItem	:= 0
  Private aListITM	:= {}
	
  Private lEhOracle:= (TCGetDB() == "ORACLE")

  Default cRotUsada := FUNNAME()

  dbSelectArea("SC5")
  _aAreaC5 := GetArea()

  dbSelectArea("SC6")
  _aAreaC6 := GetArea()

  dbSelectArea("SF2")
  _aAreaF2 := GetArea()

  dbSelectArea("SD2")
  _aAreaD2 := GetArea()
  dbSetOrder(3)

  //Verifica se é transferencia entre filiais
  lTransf	:= SC5->C5_XTRFFIL	== "S"

  //Captura o Tecnico Informado no Pedido
  cTecni	:= SC5->C5_XTECNIC

  //Verifica se existe produto que utiliza receituário agronomico
  lReceita:= SC5->C5_XRECEIT == "S"

  //Incluido nova validação para verificar se o pedido gerou financeiro
  If lReceita .AND. lFinPedi
     lReceita := GeraFin(SD2->D2_PEDIDO)
  EndIF

  If lReceita .AND. !lTransf
     dbSelectArea("SF2")
	  cNota	:=SF2->F2_DOC
	  cSerie	:=SF2->F2_SERIE
	  cCliente:=SF2->F2_CLIENTE
	  cLoja	:=SF2->F2_LOJA

	  //Atualizar os itens que estão com a cultura informada no pedido
	  AtualD2(cNota,cSerie, cCliente,cLoja)

	  If lPorItem
        If Len(aListITM) > 0
	        //Atualizar Tabela de Receituário (ZB6)
		     For nFazItem := 1 to Len(aListITM)
		        cItem := aListITM[nFazItem, 2]
			     cProd := aListITM[nFazItem, 3]
			     cNApl := aListITM[nFazItem, 4]
			     cIAdi := aListITM[nFazItem, 5]
			     u_InclZB6(cItem, cProd, cTecni,cNota, cSerie, cCliente, cLoja, cRotUsada, cNApl, cIAdi )
		     Next nFazItem
		  EndIF
	  Else
	     //Atualizar Tabela de Receituário (ZB3)
		  U_IncluiZB3(cTecni,cNota, cSerie, cCliente, cLoja, cRotUsada )
	  EndIF
	  If lAutRece
	     U_CSL05R01(1,cNota, cSerie,cCliente,cLoja,cTecni)
	  Else
	     //Pergunta para o usuário se deseja imprimir a receita agronomica
		  If MSGYESNO("Deseja imprimir a Receita Agronômica?","Atenção")
		     U_CSL05R01(1,cNota, cSerie,cCliente,cLoja,cTecni)
		  EndIf
	  EndIF
 	  dbSelectArea("SF2")
  EndIf
  RestArea(_aAreaD2)
  RestArea(_aAreaF2)
  RestArea(_aAreaC6)
  RestArea(_aAreaC5)
  RestArea(_aArea)
Return .T.

/*Função para validar se o pedido tem TES que gere finceiro*/
Static Function GeraFin(pCodPed)
  Local lRet:= .F.
  Local cQuery1 		:= ""
  Private cAlias1	:= GetNextAlias()     // retorna o próximo alias disponível

  cQuery1:="select Count(C6_TES) CONTADOR "
  cQuery1+="from "+RetSqlName("SC6")+" SC6 "
  cQuery1+="inner join "+RetSqlName("SF4")+" SF4 ON F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ = ' ' AND F4_FILIAL = '"+xfilial("SF4")+"' "
  cQuery1+="where "+ RetSqlCond("SC6")
  cQuery1+=" AND F4_DUPLIC = 'S' "
  cQuery1+=" AND C6_NUM = '"+cValToChar(pCodPed)+"' "

  If Select(cAlias1) <> 0
     (cAlias1)->(dbCloseArea())
  EndIf

  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAlias1,.T.,.T.)

  dbSelectArea(cAlias1)
  (cAlias1)->(dbGoTop())

	lRet:= IIF((cAlias1)->CONTADOR > 0,.T.,.F.)

Return lRet

//Função para atualizar os produtos Do Pedido x Nota
Static Function AtualD2(cDoc, cSer, cCliFor, cLoj)
  Local cQuery6 := ""
  Local cAlias6 := GetNextAlias()

  cQuery6 := "SELECT D2_PEDIDO, D2_ITEM, D2_COD, SD2.R_E_C_N_O_ AS SD2RED "
  cQuery6 += "FROM "+RetSqlName("SD2")+" SD2 "
  cQuery6 += "WHERE SD2.D_E_L_E_T_ = ' ' "
  cQuery6 += "AND D2_DOC     = '"+cDoc+"' "
  cQuery6 += "AND D2_SERIE   = '"+cSer+"' "
  cQuery6 += "AND D2_CLIENTE = '"+cCliFor+"' "
  cQuery6 += "AND D2_LOJA    = '"+cLoj+"' "
  cQuery6 += "AND D2_FILIAL  = '"+xFilial("SD2")+"' "
   
  cQuery6 := ChangeQuery(cQuery6)
  
  If Select(cAlias6) <> 0
     (cAlias6)->(dbCloseArea())
  EndIf

  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery6),cAlias6,.T.,.T.)

  Do While !(cAlias6)->(eof())
     SD2->(dbGoto((cAlias6)->SD2RED))
	  RecLock("SD2",.F.)
	  SD2->D2_XCULTUR := ItemPed((cAlias6)->D2_PEDIDO, (cAlias6)->D2_COD) // Altera para ficar igual ao do pedido.
	  SD2->D2_XDIAGNO := ItemPdD((cAlias6)->D2_PEDIDO, (cAlias6)->D2_COD, SD2->D2_XCULTUR) // Altera para ficar igual ao do pedido.
	  SD2->D2_XEQUIPO := ItemPdE((cAlias6)->D2_PEDIDO, (cAlias6)->D2_COD, SD2->D2_XCULTUR, SD2->D2_XDIAGNO) // Altera para ficar igual ao do pedido.
	  SD2->D2_XNAPLIC := ItemPdN((cAlias6)->D2_PEDIDO, (cAlias6)->D2_COD, SD2->D2_XCULTUR, SD2->D2_XDIAGNO) // Altera para ficar igual ao do pedido.
	  SD2->D2_XOBSERV := ItemPdI((cAlias6)->D2_PEDIDO, (cAlias6)->D2_COD, SD2->D2_XCULTUR, SD2->D2_XDIAGNO) // Altera para ficar igual ao do pedido.
	  SD2->(msUnlock())
     
	  If !Empty(SD2->D2_XCULTUR)
	     aadd(aListITM, {(cAlias6)->SD2RED, (cAlias6)->D2_ITEM, (cAlias6)->D2_COD, SD2->D2_XNAPLIC, SD2->D2_XOBSERV	})
     EndIf
     (cAlias6)->(dbSkip())
  Enddo
  (cAlias6)->(dbCloseArea())
Return .T.

//Função para achar a cultura do item do pedido para colocar item da nota
Static Function ItemPed(cPedido, cCodigo)
  Local cCult   := ""
  Local cQuery7 := ""
  Local cAlias7 := GetNextAlias()

  cQuery7 += "SELECT DISTINCT "+IIF(lEhOracle,"", "TOP 1 ")+" C6_XCULTUR "
  cQuery7 +="FROM "+RetSqlName("SC6")+" SC6 "
  cQuery7 +="WHERE D_E_L_E_T_ <>'*' "
  cQuery7 +="AND C6_NUM = '"+cPedido+"' "
  cQuery7 +="AND C6_PRODUTO = '"+cCodigo+"' "
  cQuery7 +="AND C6_FILIAL ='"+xFilial("SC6")+"' "
  cQuery7 +="AND C6_XCULTUR != ' ' "
  
  If lEhOracle
     cQuery7 +="AND ROWNUM = 1 "
  EndIF
  
  cQuery7 := ChangeQuery(cQuery7)
  
  If Select(cAlias7) <> 0
     (cAlias7)->(dbCloseArea())
  EndIf
  
  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery7),cAlias7,.T.,.T.)
  
  Do While !(cAlias7)->(Eof())
     cCult:= (cAlias7)->C6_XCULTUR
	  (cAlias7)->(dbSkip())
  Enddo
  (cAlias7)->(dbCloseArea())
Return cCult

//Função para achar a Diagnostico do item do pedido para colocar item da nota
Static Function ItemPdD(cPedido, cCodigo, cCultur)
  Local cDiago  := ""
  Local cQuery7 := ""
  Local cAlias7 := GetNextAlias()
  
  cQuery7 += "SELECT DISTINCT "+IIF(lEhOracle,"", "TOP 1 ")+" C6_XDIAGNO "
  cQuery7 += "FROM "+RetSqlName("SC6")+" SC6 "
  cQuery7 += "WHERE D_E_L_E_T_ <> '*' "
  cQuery7 += "AND C6_NUM = '"+cPedido+"' "
  cQuery7 += "AND C6_PRODUTO = '"+cCodigo+"' "
  cQuery7 += "AND C6_XCULTUR = '"+cCultur+"' "
  cQuery7 += "AND C6_FILIAL ='"+xFilial("SC6")+"' "
  cQuery7 += "AND C6_XDIAGNO != ' ' "

  If lEhOracle
     cQuery7 +="AND ROWNUM = 1 "
  EndIF

  cQuery7 := ChangeQuery(cQuery7)

  If Select(cAlias7) <> 0
     (cAlias7)->(dbCloseArea())
  EndIf

  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery7),cAlias7,.T.,.T.)

  Do While !(cAlias7)->(eof())
     cDiago:= (cAlias7)->C6_XDIAGNO
	 (cAlias7)->(dbSkip())
  Enddo
  (cAlias7)->(dbCloseArea())

Return cDiago

//Função para achar a Equipamento do item do pedido para colocar item da nota
Static Function ItemPdE(cPedido, cCodigo, cCultur, cDiag)
  Local cEquipo := ""
  Local cQuery7 := ""
  Local cAlias7 := GetNextAlias()
  
  cQuery7 += "SELECT DISTINCT "+IIF(lEhOracle,"", "TOP 1 ")+" C6_XEQUIPO "
  cQuery7 +="FROM "+RetSqlName("SC6")+" SC6 "
  cQuery7 +="WHERE D_E_L_E_T_ <> '*' "
  cQuery7 +="AND C6_NUM = '"+cPedido+"' "
  cQuery7 +="AND C6_PRODUTO = '"+cCodigo+"' "
  cQuery7 +="AND C6_XCULTUR = '"+cCultur+"' "
  cQuery7 +="AND C6_XDIAGNO = '"+cDiag+"' "
  cQuery7 +="AND C6_FILIAL ='"+xFilial("SC6")+"' "
  cQuery7 +="AND C6_XEQUIPO != ' ' "
   
  If lEhOracle
     cQuery7 +="AND ROWNUM = 1 "
  EndIF

  cQuery7 := ChangeQuery(cQuery7)

  If Select(cAlias7) <> 0
     (cAlias7)->(dbCloseArea())
  EndIf

  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery7),cAlias7,.T.,.T.)

  Do While !(cAlias7)->(eof())
     cEquipo:= (cAlias7)->C6_XEQUIPO
	 (cAlias7)->(dbSkip())
  Enddo
  (cAlias7)->(dbCloseArea())
Return cEquipo

//FunÃ§Ã£o para achar o Equipamento do item do pedido para colocar item da nota
Static Function ItemPdN(cPedido, cCodigo, cCultur, cDiag)
  Local cQuery7 := ""
  Local cAlias7 := GetNextAlias()

  cQuery7 += "SELECT DISTINCT "+IIF(lEhOracle,"", "TOP 1 ")+" C6_XNAPLIC "
  cQuery7 += "FROM "+RetSqlName("SC6")+" SC6 "
  cQuery7 += "WHERE D_E_L_E_T_ <> '*' "
  cQuery7 += "AND C6_NUM = '"+cPedido+"' "
  cQuery7 += "AND C6_PRODUTO = '"+cCodigo+"' "
  cQuery7 += "AND C6_XCULTUR = '"+cCultur+"' "
  cQuery7 += "AND C6_XDIAGNO = '"+cDiag+"' "
  cQuery7 += "AND C6_FILIAL ='"+xFilial("SC6")+"' "
  cQuery7 += "AND C6_XEQUIPO != ' ' "

  If lEhOracle
     cQuery7 +="AND ROWNUM = 1 "
  EndIF

  cQuery7 := ChangeQuery(cQuery7)

  If Select(cAlias7) <> 0
     (cAlias7)->(dbCloseArea())
  EndIf

  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery7),cAlias7,.T.,.T.)

  Do While !(cAlias7)->(eof())
     cNApl := (cAlias7)->C6_XNAPLIC
	  (cAlias7)->(dbSkip())
  Enddo
  (cAlias7)->(dbCloseArea())

Return cNApl

//FunÃ§Ã£o para achar a Equipamento do item do pedido para colocar item da nota
Static Function ItemPdI(cPedido, cCodigo, cCultur, cDiag)
  Local cQuery7 := ""
  Local cAlias7   := GetNextAlias()

  cQuery7 += "SELECT DISTINCT "+IIF(lEhOracle,"", "TOP 1 ")+" C6_XOBSERV "
  cQuery7 += "FROM "+RetSqlName("SC6")+" SC6 "
  cQuery7 += "WHERE D_E_L_E_T_ <> '*' "
  cQuery7 += "AND C6_NUM = '"+cPedido+"' "
  cQuery7 += "AND C6_PRODUTO = '"+cCodigo+"' "
  cQuery7 += "AND C6_XCULTUR = '"+cCultur+"' "
  cQuery7 += "AND C6_XDIAGNO = '"+cDiag+"' "
  cQuery7 += "AND C6_FILIAL ='"+xFilial("SC6")+"' "
  cQuery7 += "AND C6_XEQUIPO != ' ' "

  If lEhOracle
     cQuery7 +="AND ROWNUM = 1 "
  Endif

  cQuery7 := ChangeQuery(cQuery7)

  If Select(cAlias7) <> 0
     (cAlias7)->(dbCloseArea())
  EndIf

  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery7),cAlias7,.T.,.T.)

  Do While !(cAlias7)->(eof())
     cIAdi := (cAlias7)->C6_XOBSERV
	 (cAlias7)->(dbSkip())
  Enddo
  (cAlias7)->(dbCloseArea())
Return cIAdi
