// Projeto: CASUL
// Modulo : GENERICO
// ----------+------------------------+-----------------------------------------------------
// 13/05/19  | Ricardo Mendes   	  |- Funções genericas para apoio e auxilio receituario
// 09/12/19  | Chandrer Silva    	  |- Atualizacao com Personalizacoes
// 03/03/2020| Chandrer               |- Atualizacao referente a impressao do receituario agronomico
//           |                        |trazendo a Data da NF e nao mais a database.
// Maio/2020 | Chandrer               |Atualização referente a verificação se caberá os itens digitados
//           |                        |nos receituários disponiveis;
// ----------+------------------------+-----------------------------------------------------

#Include 'Protheus.ch'
#Include "Topconn.ch"
#include 'parmtype.ch'

//Constantes
#DEFINE ENTER Chr(10)+Chr(13)  

/*Inicio das funções que fazem a validação do ponto de entrada M460FIM*/
//Função para validar o ponto de entrada M460FIM
User Function Fn460Fim()
   	Begin Transaction
		U_CSL05A04("M460FIM")//Função para preparar o uso da Receita Agronômica
	End Transaction
Return .T.

User Function CSL00G01(cQuery)
  Local aRet    := {}
  Local aRet1   := {}
  Local nRegAtu := 0
  Local x       := 0

  cQuery := ChangeQuery(cQuery)
  TCQUERY cQuery NEW ALIAS "_TRB"

  dbSelectArea("_TRB")
  aRet1   := Array(Fcount())
  nRegAtu := 1

  Do While !Eof()
     For x := 1 To Fcount()
	    aRet1[x] := FieldGet(x)
	 Next
	 Aadd(aRet,aclone(aRet1))
	 dbSkip()
	 nRegAtu += 1
  Enddo
  dbSelectArea("_TRB")
  _TRB->(DbCloseArea())
Return(aRet)

//Função somente numeros
//cTexto	-> Texto que será passado pela função
//cChar		-> Caracter que será ignorado na remoção
User function SomNumer(cTexto, cChar)
	Local nCount	:= 0
	Local cRet		:= ""
	Local cTxtTemp	:= Alltrim(cTexto)
	Local cCaract	:= ""
	Default cChar	:= ""

	for nCount := 1 TO LEN(cTxtTemp)
		ProcessMessages()
		cCaract:= SUBSTR(cTxtTemp,nCount,1)

		If !Empty(cChar)
			IF (cCaract $ "0123456789" .OR. cCaract $ cChar )
				cRet+= cCaract
			EndIF
		Else
			IF cCaract $ "0123456789"
				cRet+= cCaract
			EndIF
		EndIF

	NEXT nCount

Return cRet

/*
Programa: 	FCliFor
Autor:		Tamara Freire
Descrição:	Inicializador padrão para o nome do cliente/fornecedor do pedido de venda
*/
User Function FCliFor(cTipo, cCliente, cLoja, cOpc, cPedido)
	Local cNome := ''
	Local cTab := ''

	Default cOpc 	:= 'PV'
	Default cPedido	:= ""

	IF !Empty(cPedido) .AND. Empty(cTipo)
		cTipo:= Posicione("SC5", 1, xFilial("SC5")+cPedido,"C5_TIPO")  
	EndIF
	
	cOpc := Upper(AllTrim(cOpc))
	
	If cOpc $ 'PV|NF' // Pedido de Venda / Nota Fiscal de Saida

		If cTipo $ "BD"
			cTab := "SA2"
		Else
			cTab := "SA1"
		EndIf

	ElseIf cOpc == 'DE' // Documento de Entrada

		If cTipo $ "BD"
			cTab := "SA1"
		Else
			cTab := "SA2"
		EndIf
	EndIf

	If !Empty(cTab)
		cNome := Posicione(cTab,1,xFilial(cTab)+cCliente+cLoja, SubStr(cTab,2,2)+"_NOME")
	EndIf

	If Empty(cNome)
		cNome := Space(TamSx3("A1_NOME")[1])
	EndIf

Return(cNome)

//Função para validar duplicidade de registro de produto pelo codigo de barra
User Function VldBarra(cProdu, cCdBarra)
	Local lRet		:= .T.
	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local aReg		:= {}
	Local cMsg		:= ""
	Local lVldBar	:= SuperGetMv("CS_VLDBAR",.F.,.F.)	

	IF lVldBar .AND. !Empty(cCdBarra)
		cQuery := "SELECT B1_COD, B1_DESC "
		cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
		cQuery += "WHERE " + RetSqlCond("SB1")+" "
		cQuery += "AND (B1_COD != '"+cProdu+"' AND B1_COD != ' ') "
		cQuery += "AND (B1_CODBAR = '"+cCdBarra+"' OR B1_CODBAR = '"+Alltrim(cCdBarra)+eandigito(Alltrim(cCdBarra))+"' )"

		aReg	:= U_CSL00G01(cQuery)

		IF Len(aReg) > 0
			cMsg:=	"Produto: "+Alltrim(aReg[1,1])+"-"+Alltrim(aReg[1,2])
			//MsgAlert("Código de Barra já existente"+ENTER+cMsg)
			U_MsgHelp(,"Código de Barra já existente"+ENTER+cMsg)
			lRet		:= .F.
		EndIf

		RestArea(aArea)
	EndIF

Return lRet

//Função para gerar um inputbox
/*Exemplo para Uso
cTmpCTR	:= InPBox("Informe Centro de Custo do Contrato","Centro de Custo x Contrato",TamSx3("CTT_CUSTO")[1],"", "CTT")
*/
User Function InpBox(cTitle,cText,nTamEdi,cPict, cF3)
	Local lOK		:= .T.
	Private cDescri	:= Space(nTamEdi)
	Default cText	:= "Informe a Descrição"
	Default cTitle	:= "Atenção"
	Default cPict	:= ""
	Default cF3		:= ""

	SetPrvt("oJanInput","oDescri","oBtn1","oBtn2")

	oJanInput  := MSDialog():New( 092,232,180,603,cTitle,,,.F.,,,,,,.T.,,,.T. )
	oDescri    := TGet():New( 004,003,{|u| If(PCount()>0,cDescri:=u,cDescri)},oJanInput,176,008,cPict,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,cF3,"cDescri",,,,,, .T. ,cText, 1 )
	oBtn1      := TButton():New( 024,103,"&Confirmar"	,oJanInput,{||oJanInput:End()}				,037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 024,142,"&Sair"		,oJanInput,{||lOK:= .F., oJanInput:End()}	,037,012,,,,.T.,,"",,,,.F. )

	oJanInput:lEscClose	:= .F. //Nao permite sair ao se pressionar a tecla ESC.
	oJanInput:lCentered	:= .T.
	oJanInput:Activate(,,,.T.)

	If !lOK
		cDescri:= ""
	EndIF

Return Alltrim(cDescri)

//Função para gerar um inputComboBox
/*Exemplo de Uso
aOpcao:= {"RODOVIARIO","FERROVIRIO"}
cTexto:= InpComb("Tipo de Importação",aOpcao,0,.F.,1)
*/
User Function InpComb(cTitle,aLisIten,nItemSel, lArray, nCampo)
	Local oJanComb
	Local oConfir
	Local oCancel
	Local oCombo
	Local cCombo
	Local Itens			:= aLisIten
	Local nCount		:= 0
	Local lOK			:= .T.
	Default nItemSel	:= 0
	Default lArray		:= .F.
	Default nCampo		:= 1

	IF lArray
		IF Len(aLisIten) > 0
			Itens:= {}
			For nCount:=1 to Len(aLisIten)
				aAdd(Itens,aLisIten[nCount,nCampo])
			Next nCount
		EndIF
	EndIF

	cCombo:= IIF(nItemSel = 0, "", Itens[nItemSel])
	Define MsDialog oJanComb From 10, 20 To 14, 60 Title cTitle Of GetWndDefault()

	oCombo:= tComboBox():New(2.2,04,{|u|if(PCount()>0,cCombo:=u,cCombo)},Itens,150,11,oJanComb,,/*{||MsgStop('Mudou item')}*/,,,,.T.,,,,,,,,,'cCombo')

	// Botão para fechar a janela
	oConfir:=tButton():New(15.2,82,'&Ok'		,oJanComb,{||oJanComb:End()  }			,35,12,,,,.T.)
	oCancel:=tButton():New(15.2,120,'&Cancela'	,oJanComb,{||lOK:= .F., oJanComb:End() }	,35,12,,,,.T.)

	ACTIVATE MSDIALOG oJanComb CENTERED

	If !lOK
		cCombo:= ""
	EndIF

Return cCombo

/*Inicio das funções que fazem a validação do ponto de entrada M410LOK*/ 
//Função para validar informações no ponto de entrada M410LOK
User Function Fn410LOK()
	Local lRet    :=     .T.
	Local nPosDel := Len(aHeader)+1
	Local cTES    := aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == "C6_TES" })]
	Local posCFOP := aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == IIF(FunName()=="LOJA701","LR_CF","C6_CF") })]  // Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CF"})  //aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == "C6_CF" })]
	Local cCFOP	  := IIF(!Empty(posCFOP),aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == "C6_CF" })],"") 
	Local lTransf := Alltrim(Posicione("SF4",1,xFilial("SF4")+cTES,"F4_TRANFIL")) == "1" //Verificar se TES está como transferência
	Local cCFRAG  := SuperGetMV("MV_X_CFRAG")		// Os CFOP's inclusos nesse parametro são os que tem que Emitir Receituario Agronomico. (Solicitacao em 04/03/2020 email)
 	Public lCFRAG := Alltrim(cCFOP) $ cCFRAG

	//Ajustar Campo informando que é transferência
	IF lTransf
		M->C5_XTRFFIL	:= "S"
	Else
		M->C5_XTRFFIL	:= "N"
	EndIF

 // Chands
	// IF utilizado para verificar se for NF de Complemento tambem nao pode emitir o Receituario
	// Entao, eu verifico se C5_TIPO esta selecionado "complemento" e ai utilizo o Frag do cfpo pra nao pedir o receituario;
	IF M->C5_TIPO == "C" .OR. M->C5_TIPO == "I" .OR. M->C5_TIPO == "P" 
		lCFRAG := .F.
	ENDIF

	//Validação se o produto precisa de receita agronomica
	IF lRet .AND. !lTransf .AND. M->C5_TIPO == "N" .AND. !aCols[N,nPosDel] .AND. lCFRAG // Devido a um Pedido da Casul NF Compl nao sera mais emitido Receituario para os itens.
		Processa({|| lRet:= VldRecei(.F.) }, "Validando Produto x Receita", "Processando...", .T.)
		iF !u_ConfReceit(ZB1->ZB1_TECNIC)
			lRet := .F.
		Endif
 EndIF	
Return lRet

// Função para validar se o campo precisa de receita agronomica
Static Function VldRecei(lLoja)
	Local lRet		:= .T.
	Local cProduto	:= aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == IIF(lLoja,"L2_PRODUTO", "C6_PRODUTO") })]
	Local cCultura	:= aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == IIF(lLoja,"L2_XCULTUR", "C6_XCULTUR") })]
	Local cDiagnos	:= aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == IIF(lLoja,"L2_XDIAGNO", "C6_XDIAGNO") })]
	Local cEquipa	:= aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == IIF(lLoja,"L2_XEQUIPO", "C6_XEQUIPO") })]
	Local cNAplic	:= aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == IIF(lLoja,"L2_XNAPLIC", "C6_XNAPLIC") })]
	Local cIAdic	:= aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == IIF(lLoja,"L2_XOBSERV", "C6_XOBSERV") })]

	
	Local cTamPrd1	:= TamSX3("B1_COD")[1]
	Local cTamPrd2	:= TamSX3("ZB0_PRODUT")[1]
	Local cNomePro	:= Alltrim(POSICIONE("SB1", 1, xFilial("SB1") + Substr(cProduto,1,cTamPrd1), "B1_DESC") )
	Local lReceita	:= !Empty( POSICIONE("ZB0", 1,xFilial("ZB0")+ Substr(cProduto,1,cTamPrd2), "ZB0_PRODUT"))
	Local cTmpTec   := ""
	
	IF lReceita .AND. lRet 
		IF lLoja
			M->L1_XRECEIT:= "S"
		Else
			M->C5_XRECEIT:= "S"
		EndIF
	EndIF

	If FunName()=="MATA410"
		If !empty(cCultura)
			Return (.T.)
		EndIf
	EndIf
	
	
	If lReceita = .T.
		//lRet := ItemLoja(cProduto, cTmpTec, cCultura, cDiagnos, cEquipa)
		lRet := ItemLoja(cProduto, cTmpTec, cCultura, cDiagnos, cEquipa, cNAplic, cIAdic)
	Endif
	
	If lLoja
		IF lReceita .AND. lRet .AND. Empty(cCultura)
			//Alert("É obrigatório o preenchimento do tipo de cultura utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de cultura utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Cultura informada.")
			lRet:= .F.
		EndIF
		IF lReceita .AND. lRet .AND. Empty(cDiagnos)
			//Alert("É obrigatório o preenchimento do tipo de diagnostico utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de diagnostico utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Diagnostico informada.")
			lRet:= .F.
		EndIF
		IF lReceita .AND. lRet .AND. Empty(cEquipa)
			//Alert("É obrigatório o preenchimento do tipo de Equipamento utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de Equipamento utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Equipamento informada.")
			lRet:= .F.
		EndIF
		IF lReceita .AND. lRet .AND. !Empty(cCultura) .AND. !Empty(cDiagnos) .AND. !Empty(cEquipa)
			If !(ValRecAg(cProduto, cCultura, cDiagnos, cEquipa))
				//Alert("Produto: "+Alltrim(cProduto) + '-'+Alltrim(cNomePro)+" não tem receita agronômica cadastrada." )
				U_MsgHelp(,"Produto: "+Alltrim(cProduto) + '-'+Alltrim(cNomePro)+" não tem receita agronômica cadastrada.", "Verifique o Cadastro de Produto x Cultura.")
				lRet:= .F.
			EndIF
		EndIF

	Else
		IF lReceita .AND. lRet .AND. Empty(ZB0->ZB0_CULTUR)
			//Alert("É obrigatório o preenchimento do tipo de cultura utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de cultura utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Cultura informada.")
			lRet:= .F.
		EndIF
		IF lReceita .AND. lRet .AND. Empty(ZB0->ZB0_DIAGNO)
			//Alert("É obrigatório o preenchimento do tipo de diagnostico utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de diagnostico utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Diagnostico informada.")
			lRet:= .F.
		EndIF
		IF lReceita .AND. lRet .AND. Empty(ZB0->ZB0_EQUIPA)
			//Alert("É obrigatório o preenchimento do tipo de Equipamento utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de Equipamento utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Equipamento informada.")
			lRet:= .F.
		EndIF
		IF lReceita .AND. lRet .AND. !Empty(ZB0->ZB0_CULTUR) .AND. !Empty(ZB0->ZB0_DIAGNO) .AND. !Empty(ZB0->ZB0_EQUIPA)
			If !(ValRecAg(cProduto, ZB0->ZB0_CULTUR, ZB0->ZB0_DIAGNO, ZB0->ZB0_EQUIPA))
				//Alert("Produto: "+Alltrim(cProduto) + '-'+Alltrim(cNomePro)+" não tem receita agronômica cadastrada." )
				U_MsgHelp(,"Produto: "+Alltrim(cProduto) + '-'+Alltrim(cNomePro)+" não tem receita agronômica cadastrada.", "Verifique o Cadastro de Produto x Cultura.")
				lRet:= .F.
			EndIF
		EndIF

	EndIf
Return lRet

//Função para validar se o campo de cultura informada corresponde ao cadastrado na tabela
Static Function ValRecAg(cProduto, cCultura, cDiagnos, cEquipam)
	Local lRet		:= .T.
	Local nTamProd	:= TamSX3("ZB0_PRODUT")[1]
	Local nTamCult	:= TamSX3("C6_XCULTUR")[1]
	Local nTamDiag	:= TamSX3("C6_XDIAGNO")[1]
	Local nTamEqui	:= TamSX3("C6_XEQUIPO")[1]

	dbSelectArea("ZB0")
	ZB0->(dbSetOrder(1))
	ZB0->(dbGoTop())
	If ZB0->(dbSeek(xFilial("ZB0")+Substr(cProduto,1,nTamProd)+Substr(cCultura,1,nTamCult)+Substr(cDiagnos,1,nTamDiag)+Substr(cEquipam,1,nTamEqui)))
		lRet:= .T.
	Else
		lRet:= .F.
	Endif

Return lRet


/*Inicio das funções que fazem a validação do ponto de entrada MTA410*/
//Função para validar o ponto de entrada MTA410
user function FnM410()
	Local lRet     	:=     .T.
	Local lTransf	:= M->C5_XTRFFIL	== "S"
	
	IF IsInCallStack("MATA410")

		//Verificar se Pedido de Venda precisa de Receita Agrônimica
		IF (Inclui .Or. Altera) .AND.  M->C5_TIPO = "N" .AND. M->C5_XRECEIT == "S" .AND. Empty(M->C5_XTECNIC) .AND. !lTransf .AND. lRet .AND. lCFRAG 
			//Alert("É necessário informar o técnico responsável.")
			U_MsgHelp(,"Técnico responsável não informado.", "Informe o Técnico que está responsável")
			lRet:= .F.
		Endif

		//Função para validar autorização de receita do tecnico
		IF (Inclui .Or. Altera) .AND.  M->C5_TIPO = "N" .AND. M->C5_XRECEIT == "S" .AND. !Empty(M->C5_XTECNIC) .AND. !lTransf .AND. lRet  .AND. lCFRAG 
			Processa({|| lRet:= VldART(.F.) }, "Validando Autorização Receita Agronomica", "Processando...", .T.)
		EndIF
		
	EndIF

return lRet

//Função para validar se tecnico infomado tem autorização
Static Function VldART(lLoja)
	Local cQuery1	:= ""
	Local aRet		:= {}
	Local lRet		:= .T.

	cQuery1:="select Coalesce(COUNT(ZB2_PRXREC),0) CONTADOR "
	cQuery1+="from "+RetSqlName("ZB2")+" ZB2 "
	cQuery1+="where "+ RetSqlCond("ZB2")+ " "
	cQuery1+="AND ZB2_ATIVO = 'S' AND ZB2_FINAL = 'N' "
	IF lLoja
		cQuery1+="AND ZB2_TECNIC = '"+cValToChar(M->LQ_XTECNIC)+"' "
	Else
		cQuery1+="AND ZB2_TECNIC = '"+cValToChar(M->C5_XTECNIC)+"' "
	EndIF

	//MemoWrite("C:\TEMP\BuscSld.sql",cQuery)
	aRet	:= U_CSL00G01(cQuery1)

	IF aRet[1,1] = 0
		//Alert("Técnico não tem autorização disponivel para utilização, favor verificar as ART.")
		IF lLoja
			MSGSTOP("Técnico não tem autorização disponivel para utilização, favor verificar as ART.")
		Else
			U_MsgHelp(,"Técnico não tem autorização disponivel para utilização, favor verificar as ART.", "Verifique o Cadastro do Técnico.")
		EndIF
		lRet:= .F.
	EndIF

Return lRet


/*Inicio das funções que fazem a validação do ponto de entrada M410PVNF*/
//Função para validar o ponto de entrada M410PVNF
user function FnPVNF()
	Local lRet		:= .T.
	Local lLibera	:=  (!Empty(SC5->C5_LIBEROK) .and. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ) )
	Local lPorItem	:= SuperGetMV( "CS_PORITE",,"N" ) == "S"
	LOCAL cAlias1   := GETNEXTALIAS()
	
	IF IsInCallStack("MATA410")

		//Verificação se o pedido está bloqueado para emissão de NF.
		IF lRet .AND. !lLibera
			//Alert("Pedido não está liberado para emissão de NF.")
			U_MsgHelp(,"Pedido não está liberado para emissão de NF.", "Efetue a Liberação do Pedido de Venda.")
			lRet := .F.
		EndIF

		//Verificação se o tecnico do pedido tem autorização
		IF lRet .AND. lLibera
			Processa({|| lRet:= VldRct(.F.) }, "Validando Tecnico x Autorização x Receita", "Processando...", .T.)
		EndIF
		
		//Verificação se o tecnico do pedido tem autorização para todos os itens
//		IF lRet .AND. lLibera .AND. lPorItem
//			Processa({|| lRet:= u_VldRctIt(.F.) }, "Validando Tecnico x Autorização x Receita x Produto", "Processando...", .T.)
//		EndIF
		//Verificação se o tecnico do pedido tem autorização para todos os itens
		IF lRet .AND. lLibera .AND. lPorItem
			cQuery1:="Select  Coalesce(COUNT(C6_NUM),0) CONTADOR "
			cQuery1+= "from "+RetSqlName("SC6")+" SC6 "
			cQuery1+= "WHERE "+RetSqlCond("SC6")
			cQuery1+= " AND C6_NUM = '" + SC5->C5_NUM + "' "
			cQuery1+= " AND C6_XCULTUR <> ''"
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAlias1,.T.,.T.)
			NQTDITENS	:= (cAlias1)->CONTADOR

			Processa({|| lRet:= u_VldRctIt(.F.) }, "Validando Tecnico x Autorização x Receita x Produto", "Processando...", .T.)
			(cAlias1)->(dbCloseArea())

		EndIF
		
	EndIF

return lRet

//Função para validar se existe autorização para ser utilizada
Static Function VldRct(lLoja)
  Local lRet	:= .T.
  Local cTmpCmp	:= SC5->C5_XTECNIC

  //- Verificar se o tecnico tem receita a liberada para ser utilizada.
  If !Empty(cTmpCmp)
     cQuery1:="SELECT Coalesce(COUNT(ZB2_PRXREC),0) CONTADOR "
	 cQuery1+= "FROM "+RetSqlName("ZB2")+" ZB2 "
	 cQuery1+= "WHERE "+RetSqlCond("ZB2")
	 cQuery1+= " AND ZB2_PRXREC <= ZB2_RECFIM "
	 cQuery1+= " AND ZB2_TECNIC = '"+cValToChar(cTmpCmp)+"' "
	 cQuery1+= " AND ZB2_ATIVO = 'S' AND ZB2_FINAL = 'N' "

     TCQUERY cQuery1 NEW ALIAS "_TRB"

     dbSelectArea("_TRB")
      
	 If _TRB->CONTADOR = 0 
	    U_MsgHelp(,"Técnico informado está sem receita para uso.", "Cadastre uma nova autorização para o Técnico")
        lRet := .F.
     Endif
     _TRB->(DbCloseArea())
  Endif
Return lRet


//- Função para validar se o tecnico tem receita suficiente para atender o pedido
User Function VldRctIt(lLoja)
  Local lRet	:= .T.
  Local cTmpCmp	:= IIF(lLoja,M->LQ_XTECNIC,SC5->C5_XTECNIC) //SLQ=Orçamento(Loja) X SC5=Pedido de Venda(Faturamento)
  Local cAlias1	:= GetNextAlias()     // retorna o próximo alias disponível
  Local nQtdRCT := 0
  Local nConta  := 0

  //- Verificar se o tecnico tem receita a liberada para ser utilizada.
  If !Empty(cTmpCmp)
     // Query para verificar a quantidade de itens que foram digitados nas duas grids para comparar com o total
	 // de Receituário, pra deixar ou não seguir fazendo...
 	 cQuery1:="SELECT Coalesce(COUNT(ZB2_PRXREC),0) CONTADOR "
	 cQuery1+= "FROM "+RetSqlName("ZB2")+" ZB2 "
	 cQuery1+= "WHERE "+RetSqlCond("ZB2")
	 cQuery1+= " AND ZB2_PRXREC <= ZB2_RECFIM "
	 cQuery1+= " AND ZB2_TECNIC = '"+cValToChar(cTmpCmp)+"' "
	 cQuery1+= " AND ZB2_ATIVO = 'S' AND ZB2_FINAL = 'N' "
	 //aRet	:= U_CSL00G01(cQuery1)
     
   	 dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAlias1,.T.,.T.)
	 dbSelectArea(cAlias1)
     nConta := (cAlias1)->CONTADOR 
     (cAlias1)->(dbCloseArea())
     
	 // Verificando se existe Receituario para todos os itens
	 cQuery1:="SELECT ZB2_PRXREC, ZB2_RECFIM "
	 cQuery1+= "FROM "+RetSqlName("ZB2")+" ZB2 "
	 cQuery1+= "WHERE "+RetSqlCond("ZB2")
	 cQuery1+= " AND ZB2_PRXREC <= ZB2_RECFIM "
	 cQuery1+= " AND ZB2_TECNIC = '"+cValToChar(cTmpCmp)+"' "
	 cQuery1+= " AND ZB2_ATIVO = 'S' AND ZB2_FINAL = 'N' "
	  
	 dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAlias1,.T.,.T.)
	 dbSelectArea(cAlias1)
	 (cAlias1)->(dbGoTop())
	
	 //nQtdRCT := ((cAlias1)->ZB2_RECFIM) - ((cAlias1)->ZB2_PRXREC)
	 Do While (cAlias1)->(!EOF()) // Verifico todos receituarios do tecnico que esteja ativo pra ver se os itens cabe no receituário;
	    nQtdRCT += ((cAlias1)->ZB2_RECFIM) - ((cAlias1)->ZB2_PRXREC) 
		(cAlias1)->(dBSkip())
	 Enddo
     
	 If NQTDITENS > nQtdRCT
	    MsgStop("- Não será possível gerar os receituarios necessários para este Pedido, os itens ultrapassam a Numeração do Receituario!"+chr(13)+"Numeros disponivels..: "+ str(nQtdRCT))
		lRet:=.F.
	 EndIf
	 (cAlias1)->(dbCloseArea())

	 If nConta = 0
	    //Alert("Técnico informado está sem receita para uso.")
		If lLoja
		   MSGSTOP("Técnico informado está sem receita para uso.")
		Else
		   U_MsgHelp(,"Técnico informado está sem receita para uso.", "Cadastre uma nova autorização para o Técnico")
		Endif
		lRet := .F.
	 EndIf
  Endif	 
Return lRet

/*Inicio das funções que fazem a validação do ponto de entrada LJ7001*/
//ponto de entrada é chamado antes do início da gravação do orçamento. Utilizado para validações no final da venda.
User Function Fn7001()
	Local lRet		:= .T.
	Local nTpOper	:= ParamIXB[1]	//Tipo da operação: 1 - Orçamento / 2 - Venda / 3 - Pedido
	Local aDdDevo	
	Local nTpDoc	
	Local cCliPadr	:= Alltrim(SuperGetMV( "MV_CLIPAD",,"000001" ))
	aDdDevo := ParamIXB[2]	//Array com os dados da devolução
	nTpDoc  := ParamIXB[3]	//Tipo de documento impresso pela venda: 1 - Cupom fiscal / 2 - Nota fiscal

	IF nTpOper == 2 .OR. nTpOper == 3
		IF  M->LQ_XRECEIT == "S" .AND. Empty(M->LQ_XTECNIC) .AND. lRet .AND. cCliPadr == Alltrim(M->LQ_CLIENTE)
			//U_MsgHelp(,"Venda com emissão de Receita Agronômica não pode ser para Cliente Padrão.", "Verifique o Código do Cliente informado.")
			MSGSTOP("Venda com emissão de Receita Agronômica não pode ser para Cliente Padrão.")	
			lRet:= .F.
			RETURN(LRET)
		EndIF

		//Verificar se Pedido de Venda precisa de Receita Agrônimica

  		IF  M->LQ_XRECEIT == "S" .AND. Empty(M->LQ_XTECNIC) .AND. lRet
			//Alert("É necessário informar o técnico responsável.")
			//U_MsgHelp(,"Técnico responsável não informado.", "Informe o Técnico que está responsável")
			MSGSTOP("Técnico responsável não informado.")
			lRet:= .F.
			RETURN(LRET)
		Endif

		//Função para validar autorização de receita do tecnico
		IF M->LQ_XRECEIT == "S" .AND. !Empty(M->LQ_XTECNIC) .AND. lRet
			//LjMsgRun("Processando...","Validando Autorização Receita Agronomica",{|| lRet:= VldART(.T.) } )
			Processa({|| lRet:= VldART(.T.) }, "Validando Autorização Receita Agronomica", "Processando...", .T.)
			IF !lRet
				RETURN(LRET)
			EndIF
		EndIF

		//Verificação se o tecnico do pedido tem autorização
		IF M->LQ_XRECEIT == "S" .AND. !Empty(M->LQ_XTECNIC) .AND. lRet 
			//LjMsgRun("Processando...","Validando Tecnico x Autorização x Receita",{|| lRet:= VldRct(.T.) } )
			Processa({||  lRet:= VldRct(.T.)  }, "Validando Tecnico x Autorização x Receita", "Processando...", .T.)
			IF !lRet
				RETURN(LRET)
			EndIF
		EndIF
	EndIF

Return lRet

/*Inicio das funções que fazem a validação do ponto de entrada LJ7030*/
//ponto de entrada é chamado antes do início da gravação do orçamento. Utilizado para validações no final da venda.
User Function Fn7030()
	Local lRet		:= .T.
	Local nTpVld	:= ParamIxb[1]    //1- LinhaOk e 2- TudoOk
	Local nTpOpc	
	Local nPosDel 	:= Len(aHeader)+1

	Local cTmpProd	:= aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_PRODUTO"})] 
	Local cTmpTec	:= ""
	Local cTmpCult	:= ""
	Local cTmpDiag	:= ""
	Local cTmpEqui	:= ""

	Local nTamPrd2	:= TamSX3("ZB0_PRODUT")[1]
	Local lReceita	:= .F.

 	Local nPosCFOP := IIF(FUNNAME() == "LOJA701",Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CF"}), Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "C6_CF"}))
	Local cCFRAG   := SuperGetMV("MV_X_CFRAG")		// Os CFOP's inclusos nesse parametro irao Emitir Receituario Agronomico. (Solicitacao em 03/03/2020 email Local lCFRAG   := Alltrim(cCFOP) $ cCFRAG
 	Local cCFOP	   := ""
 	Local lCFRAG   := .F.

	IF nPosCFOP>0  //SL2->L2_CF //aCols[N, Ascan(aHeader, {|X|Upper(Alltrim(X[2])) == "C6_CF" })]
		IF LEN(aColsDet) >= n
			cCFOP := aColsDet[n][nPosCFOP]
		else
			cCFOP := ""
		ENDIF
	else
		cCFOP := ""
	ENDIF

	nTpOpc := ParamIxb[2]    //1- Orçamento, 2- Venda e 3- Pedido	
 	lCFRAG   := IIF(nPosCFOP>0,Alltrim(cCFOP) $ cCFRAG,.F.)

	If nTpVld == 1

		IF lRet .AND. !aCols[N,nPosDel] .AND. lCFRAG
			cTmpProd	:= aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_PRODUTO"})]
			lReceita	:= !Empty(POSICIONE("ZB0", 1,xFilial("ZB0")+ Substr(cTmpProd,1,nTamPrd2), "ZB0_PRODUT"))

			IF lReceita
				cTmpTec		:= M->LQ_XTECNIC

				cTmpCult	:= aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_XCULTUR"})]
				cTmpDiag	:= aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_XDIAGNO"})]
				cTmpEqui	:= aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_XEQUIPO"})]
				cNApl   	:= aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_XNAPLIC"})]
				cIAdic	    := aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_XOBSERV"})]

				M->LQ_XRECEIT:= "S"
				//lRet := ItemLoja(cProduto, cTmpTec, cCultura, cDiagnos, cEquipa, cNAplic, cIAdic)
				lRet := ItemLoja(cTmpProd, cTmpTec, cTmpCult, cTmpDiag, cTmpEqui, cNApl, cIAdic)
				If !u_ConfReceit(cTmpTec)
					lRet := .F.
				EndIf
			Else 
//				M->LQ_XRECEIT:= "N"
				cTmpCult	:= ""
				cTmpDiag	:= ""
				cTmpEqui	:= ""
			EndIF
		EndIF	
	EndIF

Return lRet

/*Inicio das funções que fazem a validação do ponto de entrada LJ70101*/
//ponto de entrada permite realizar ações antes ou depois de registrar o item da venda através do
//campo (LQ_PRODUTO) que fica localizado na parte superior da tela da rotina Venda Assistida .
User Function Fn70101()
	Local lRet		:= .T.
	Local nTpOpc	:= PARAMIXB[1]//1 - Antes de Incluir Item e 2 - Apos Incluir Item

	Local cTmpProd	:= M->LQ_PRODUTO
	Local cTmpTec	:= M->LQ_XTECNIC

	Local nTamPrd2	:= TamSX3("ZB0_PRODUT")[1]
	Local lReceita	:= !Empty(POSICIONE("ZB0", 1,xFilial("ZB0")+ Substr(cTmpProd,1,nTamPrd2), "ZB0_PRODUT"))

	//Valida apenas se for usar receita agronomica
	IF lReceita .AND. nTpOpc == "1" //.and. lCFRAG
		M->L1_XRECEIT:= "S"
		;;lRet := ItemLoja(cTmpProd, cTmpTec, "", "", "")
		lRet := ItemLoja(cTmpProd, cTmpTec, "", "", "", "", "")
	EndIF

/*
	If !lReceita
		M->L1_XRECEIT:="N"
 EndIf
*/

Return lRet

User Function Fn7002()
	Begin Transaction
		U_CSL12A01("LOJA701")//Função para preparar o uso da Receita Agronômica
	End Transaction
Return .T.

User Function Fn7033()
	Local lRet := .T.
	Local lGrava := ParamIXB[1]
	Local nOpcao := ParamIXB[2]
	Local lAutRece	:= Alltrim(SuperGetMV("CS_AUTREC",,"N")) == "S"

	Local cNota		:=""
	Local cSerie	:=""
	Local cCliente	:=""
	Local cLoja		:=""
	Local cTecni	:= ""

	Local lReceita	:= .F.

	If (nOpcao == 3 .OR. nOpcao == 4) .And. lGrava

		lReceita:= SL1->L1_XRECEIT == "S"
		cNota	  := SL1->L1_DOC
		cSerie	 := SL1->L1_SERIE
		cCliente:= SL1->L1_CLIENTE
		cLoja	  := SL1->L1_LOJA
		cTecni 	:= SL1->L1_XTECNIC

		IF lReceita .AND. !Empty(cNota) .AND. !Empty(cSerie) .AND. !Empty(cCliente) .AND. !Empty(cLoja) .AND. !Empty(cTecni)
			IF lAutRece
				U_CSL05R01(1,cNota, cSerie,cCliente,cLoja,cTecni)
			Else
				//Pergunta para o usuário se deseja imprimir a receita agronomica
				If MSGYESNO("Deseja imprimir a Receita Agronômica?","Atenção")
					U_CSL05R01(1,cNota, cSerie,cCliente,cLoja,cTecni)
				EndIf
			EndIF
		EndIF

	EndIF

Return lRet

/*Inicio das funções que fazem a validação do ponto de entrada MS520VLD*/
//Função para validar o ponto de entrada MS520VLD
user function Fn520VLD()
	Local 	lRet 		:= .T.

	Begin Transaction
		If	lRet .AND. !Empty(SF2->F2_XRECEIT) //Verificar se a nota excluida possui receita agronomica
			ExcRect(.F.) //Excluir utilização da receita em NF (ZB3)
		EndIF	
	End Transaction

return lRet

/*Inicio das funções que fazem a validação do ponto de entrada LJ140EXC*/
//Função para validar o ponto de entrada LJ140EXC
user function FnLJ140()
	Local lRet 		:= .T.

	Begin Transaction
		If	lRet .AND. !Empty(SL1->L1_XRECEIT) .AND. !Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_SERIE) .AND. !Empty(SL1->L1_CLIENTE) .AND. !Empty(SL1->L1_LOJA) .AND. !Empty(SL1->L1_XTECNIC) //Verificar se a nota excluida possui receita agronomica
			ExcRect(.T.) //Excluir utilização da receita em NF (ZB3)
		EndIF	
	End Transaction

return lRet


//Função para excluir a validação de uso da receita
Static Function ExcRect(lLoja)
	Local nTamTecn	:= TamSX3("ZB3_TECNIC")[1]
	Local nTamNota	:= TamSX3("ZB3_NTFISC")[1]
	Local nTamSeri	:= TamSX3("ZB3_SERNTA")[1]
	Local nTamClie	:= TamSX3("ZB3_CLIENT")[1]
	Local nTamLoja	:= TamSX3("ZB3_LOJA")[1]

	Local 	cTecni 		:= PADR(IIF(lLoja,SL1->L1_XTECNIC 	,SF2->F2_XTECNIC	)	,nTamTecn)
	Local 	cNrNota		:= PADR(IIF(lLoja,SL1->L1_DOC 		,SF2->F2_DOC		)	,nTamNota)
	Local 	cSerie		:= PADR(IIF(lLoja,SL1->L1_SERIE 	,SF2->F2_SERIE		)	,nTamSeri)
	Local 	cCliente	:= PADR(IIF(lLoja,SL1->L1_CLIENTE 	,SF2->F2_CLIENTE	)	,nTamClie)
	Local 	cLoja		:= PADR(IIF(lLoja,SL1->L1_LOJA 		,SF2->F2_LOJA		)	,nTamLoja)

	DbSelectArea("ZB3")
	DbSetOrder(3) //ZB3_FILIAL+ZB3_TECNIC+ZB3_NTFISC+ZB3_SERNTA+ZB3_CLIENT+ZB3_LOJA+ZB3_XFILUS
	ZB3->(dbGoTop())
	If ZB3->(dbSeek(xFilial("ZB3")+cTecni+cNrNota+cSerie+cCliente+cLoja))
		RecLock("ZB3",.F.) // Define que será realizada uma alteração no registro posicionado
		ZB3->ZB3_NTEXCL:= 'S'

		IF ZB3->(FieldPos("ZB3_DTEXCL"))> 0 
			ZB3->ZB3_DTEXCL	:= dDataBase
		EndIF

		ZB3->(MsUnLock()) // Confirma e finaliza a operação
	EndIF

Return .T.

//Função para incluir Receita na tabela ZB3
User Function IncluiZB3(cTecni,cNota, cSerie, cCliente, cLoja, cRotUsada )
	Local aProxRec := PrxRecZB2 (cTecni)

	//ChkFile("ZB3",.F.)
	//Gravar a utilização da receita
	DbSelectArea("ZB3")
	RecLock("ZB3",.T.)
	ZB3->ZB3_FILIAL:= xFilial("ZB3")
	ZB3->ZB3_TECNIC:= cValTochar(cTecni)
	ZB3->ZB3_NMTECN:= Posicione("ZB1",1,xFilial("ZB1")+cValTochar(cTecni),"ZB1_NMTECN")
	ZB3->ZB3_RECEIT:= IIF(Valtype(aProxRec[1]) == "C", Val(aProxRec[1]),aProxRec[1] )
	ZB3->ZB3_SERART:= cValTochar(aProxRec[2])
	ZB3->ZB3_NUMART:= cValTochar(aProxRec[3])
	ZB3->ZB3_NTFISC:= cNota
	ZB3->ZB3_SERNTA:= cSerie
	ZB3->ZB3_CLIENT:= cCliente
	ZB3->ZB3_LOJA  := cLoja
	ZB3->ZB3_NTEXCL:= "N"
	ZB3->ZB3_XTECFI:= Posicione("ZB1",1,xFilial("ZB1")+cValTochar(cTecni),"ZB1_FILTEC")
	ZB3->ZB3_XFILUS:= cFilAnt
	ZB3->ZB3_ROTINA:= cRotUsada
	ZB3->(MsUnlock())
	
	IF UPPER(cRotUsada) == "M460FIM"
		//Atualiza a nota fiscal com os dados da receita
		RecLock("SF2",.F.)
		SF2->F2_XTECNIC	:= cValTochar(cTecni)
		SF2->F2_XRECEIT	:= IIF(Valtype(aProxRec[1]) == "C", Val(aProxRec[1]),str(aProxRec[1],6) )
		SF2->F2_XSERREC	:= cValTochar(aProxRec[2])
		SF2->F2_XNUMART	:= cValTochar(aProxRec[3])
		SF2->(MsUnlock())

	ElseIF UPPER(cRotUsada) == "LOJA701"

		RecLock("SF2",.F.)
		SF2->F2_XTECNIC	:= cValTochar(cTecni)
		SF2->F2_XRECEIT	:= IIF(Valtype(aProxRec[1]) == "C", Val(aProxRec[1]),aProxRec[1] )
		SF2->F2_XSERREC	:= cValTochar(aProxRec[2])
		SF2->F2_XNUMART	:= cValTochar(aProxRec[3])
		SF2->(MsUnlock())

		RecLock("SL1",.F.)
		SL1->L1_XNMTECN	:= Posicione("ZB1",1,xFilial("ZB1")+cValTochar(cTecni),"ZB1_NMTECN")
		SL1->L1_XTECFIL	:= Posicione("ZB1",1,xFilial("ZB1")+cValTochar(cTecni),"ZB1_FILTEC")
		SL1->L1_XFILAUT	:= cFilAnt
		SL1->(MsUnlock())

	EndIF

	//Atualiza a receita utilizada
	AtuRecZB2(cTecni,aProxRec[5])

Return .T.

//Função para incluir receita por item
User Function InclZB6(cItem, cProd, cTecni,cNota, cSerie, cCliente, cLoja, cRotUsada, cNAplic, cIAdic)
  Local aProxRec := PrxRecZB2 (cTecni)
	
  //ChkFile("ZB6",.F.)
  DbSelectArea("ZB6")
  RecLock("ZB6",.T.)
  ZB6->ZB6_FILIAL:= xFilial("ZB6")
  ZB6->ZB6_TECNIC:= cTecni
  ZB6->ZB6_NMTECN:= Posicione("ZB1",1,xFilial("ZB1")+cTecni,"ZB1_NMTECN")
  ZB6->ZB6_XTECFI:= Posicione("ZB1",1,xFilial("ZB1")+cTecni,"ZB1_FILTEC")
  ZB6->ZB6_RECEIT:= StrZero(aProxRec[1],4)
  ZB6->ZB6_NUMART:= aProxRec[3]
  ZB6->ZB6_SERART:= aProxRec[2]
  ZB6->ZB6_XFILUS:= cFilAnt
  ZB6->ZB6_ITEMPR:= cItem
  ZB6->ZB6_PRODUT:= cProd
  ZB6->ZB6_NTFISC:= cNota
  ZB6->ZB6_SERNTA:= cSerie
  ZB6->ZB6_CLIENT:= cCliente
  ZB6->ZB6_LOJA  := cLoja
  ZB6->ZB6_NTEXCL:= "N"
  ZB6->ZB6_ROTINA:= cRotUsada
  ZB6->ZB6_NAPLIC:= cNAplic
  ZB6->ZB6_OBSERV:= cIAdic
  ZB6->(MsUnlock())

  //Atualiza a receita utilizada
  AtuRecZB2(cTecni,aProxRec[5])

Return .T.

/*Função para retornar um array com os dados da ultima receita tecnica
aRetorno - Código do Tecnico responsavel*/
Static Function PrxRecZB2 (cCodTec)
  Local aRetorno:={}
  Local cQuery1 		:= ""
  
  Private cAlias1	:= GetNextAlias()     // retorna o próximo alias disponível
  Private cAlias2	:= GetNextAlias()     // retorna o próximo alias disponível
	
  cQuery1 := "SELECT "+IIF(lEhOracle,"", "TOP 1 ")+" ZB2_PRXREC, ZB2_NUMART, ZB2_SERIE, ZB2_RECINI, ZB2.R_E_C_N_O_ RECNOZB2 "
  cQuery1 += "FROM "+RetSqlName("ZB2")+" ZB2 "
  cQuery1 += "WHERE "+ RetSqlCond("ZB2")
  cQuery1 += " AND ZB2_ATIVO = 'S' AND ZB2_FINAL = 'N' "
  cQuery1 += " AND ZB2_TECNIC = '"+cValToChar(cCodTec)+"' "
  cQuery1 += " AND ZB2_FILIAL = '"+xFilial("ZB2")+"' AND ZB2.D_E_L_E_T_ <> '*' "
  cQuery1 += IIF(lEhOracle," AND ROWNUM = 1 ", "")
  cQuery1 +=" ORDER BY ZB2_RECINI, ZB2_SERIE "

  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAlias1,.T.,.T.)

  dbSelectArea(cAlias1)
  (cAlias1)->(dbGoTop())

  aRetorno:= {}
  
  Do While !(cAlias1)->(EOF())
     Aadd( aRetorno, (cAlias1)->ZB2_PRXREC )      //Proxima Receita
	 Aadd( aRetorno, (cAlias1)->ZB2_SERIE )       //Serie da Receita
	 Aadd( aRetorno, (cAlias1)->ZB2_NUMART )      //Nr. Autorização da Receita
	 Aadd( aRetorno, (cAlias1)->ZB2_RECINI )      //Receita Inicial
	 Aadd( aRetorno, (cAlias1)->RECNOZB2 )        //Recno
	 (cAlias1)->(dbSkip())
  Enddo
  (cAlias1)->(dbCloseArea())
Return aRetorno

/*Função para atualizar a numeração da receita que está em uso
cCodTec - Código do Tecnico responsavel
cRecIni - Receita Inicial*/
Static Function AtuRecZB2 (cCodTec, nRecZB2)

// Pra garantir que vai atualizar o Registro correto.
 DbSelectArea("ZB2")
	DbGoTo(nRecZB2)
	//ZB2->(DBGOTOP())

	If ZB2->(EOF())
		msgInfo("Houve um erro inesperado na geracao do Numero do Receituario...")
		Return(.F.)
	EndIf
	
	RecLock("ZB2",.F.) // Define que será realizada uma alteração no registro posicionado
		IF(ZB2->ZB2_PRXREC +1 = ZB2->ZB2_RECFIM)
			ZB2->ZB2_PRXREC:= ZB2->ZB2_PRXREC +1
		ELSEIF(ZB2->ZB2_PRXREC +1 > ZB2->ZB2_RECFIM)
			ZB2->ZB2_FINAL := 'S'
		ELSEIF(ZB2->ZB2_PRXREC < ZB2->ZB2_RECFIM)
			ZB2->ZB2_PRXREC:= ZB2->ZB2_PRXREC +1
		ELSE
			msgInfo("Nao passou em nenhuma das Condicoes na Geracao do No.Receituario...")
			ZB2->ZB2_PRXREC:= ZB2->ZB2_PRXREC +1
		EndIF
	MsUnLock()// Confirma e finaliza a operação

	Return .T.

//Função para Criar Tela de Help Reduzida
User Function MsgHelp(cRotina, cTexto, cSolucao)
	Default cRotina 	:= Alltrim(ProcName(1))
	Default cTexto		:= ""
	Default cSolucao	:= ""

	If Substr(UPPER(cRotina),1,2) == "U_"
		cRotina := Substr(UPPER(cRotina),3,Len(cRotina))
	EndIF

	IF Empty(cSolucao)
		Help(,, 'Help ['+Alltrim(cRotina)+']',, Alltrim(cTexto),1,0)
	Else
		Help(,, 'Help ['+Alltrim(cRotina)+']',, Alltrim(cTexto), 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
	EndIF

Return .T.

//Função para Informações Adicionais da Receita Agronomica para o Loja
//Static Function ItemLoja(cTmpProd, cTmpTec, cTmpCult, cTmpDiag, cTmpEqui) 
Static Function ItemLoja(cTmpProd, cTmpTec, cTmpCult, cTmpDiag, cTmpEqui, cNApl, cIAdic)
	Local lRetGrv		:= .F.

	Private cEdtProd	:= Space(TamSX3("B1_COD")[1])
	Private cEdtNProd	:= Space(TamSX3("B1_DESC")[1])
	Private cEdtTec		:= Space(TamSX3("ZB1_TECNIC")[1])
	Private cEdtNTec	:= Space(TamSX3("ZB1_NMTECN")[1])
	Private cEdtCult	:= Space(TamSX3("NP3_CODIGO")[1])
	Private cEdtNCul	:= Space(TamSX3("NP3_DESCRI")[1])
	Private cEdtDiag	:= Space(TamSX3("ZB0_DIAGNO")[1])
	Private cEdtNDiag	:= Space(TamSX3("ZB0_NMDIAG")[1])
	Private cEdtEqui	:= Space(TamSX3("ZB0_EQUIPA")[1])
	Private cEdtNEqui	:= Space(TamSX3("ZB0_NMEQUI")[1])
	Private cEdtNApl	:= Space(TamSX3("ZB0_NAPLIC")[1])
	Private cEdtIAdic	:= Space(TamSX3("ZB0_OBSERV")[1])

	IF !Empty(cTmpProd)	
		cEdtProd	:= cTmpProd	
		cEdtNProd	:= Posicione("SB1",1,xFilial("SB1") + cTmpProd,"B1_DESC")
	EndIF
	IF !Empty(cTmpTec)	
		cEdtTec		:= cTmpTec
		cEdtNTec	:= Posicione("ZB1",1,xFilial("ZB1") + cTmpTec,"ZB1_NMTECN")
	EndIF
	IF !Empty(cTmpCult)	
		cEdtCult	:= cTmpCult
		cEdtNCul	:= Posicione("NP3",1,xFilial("NP3") + Substr(cTmpCult,1,TamSX3("NP3_CODIGO")[1]),"NP3_DESCRI")
	EndIF
	IF !Empty(cTmpDiag)
		cEdtDiag	:= cTmpDiag
		cEdtNDiag	:= Posicione("ZB4",1,xFilial("ZB4") + cTmpDiag,"ZB4_DESCRI")
	EndIF
	IF !Empty(cTmpEqui)
		cEdtEqui	:= cTmpEqui
		cEdtNEqui	:= Posicione("ZB5",1,xFilial("ZB5") + cTmpEqui,"ZB5_DESCRI")
	EndIF

	If !empty(cEdtNApl)
		If Empty(Alltrim(cEdtNApl))
			cEdtNApl  := Posicione("ZB0",1,xFilial("ZB0") + cTmpProd + cTmpCult + cTmpDiag + cTmpEqui,"ZB0_NAPLIC" )
		EndIf
		If Empty(Alltrim(cEdtIAdic))
			cEdtIAdic := Posicione("ZB0",1,xFilial("ZB0") + cTmpProd + cTmpCult + cTmpDiag + cTmpEqui,"ZB0_OBSERV" )
			If Len(cEdtIAdic) < 250
				cEdtIAdic := cEdtIAdic+space(250-len(cEdtIAdic))
			EndIf
		EndIf
	EndIf

//	IF !GravaLoja(cTmpProd, cTmpTec, cTmpCult, cTmpDiag, cTmpEqui, .F.)
IF !GravaLoja(cTmpProd, cTmpTec, cTmpCult, cTmpDiag, cTmpEqui, cNApl, cIAdic, .F.)
  cNApl  := "" // CH
  cIAdic := "" // CH 

		SetPrvt("oJanReceit","oGrpProd","oEdtProd","oEdtNProd","oGrpAdic","oEdtNTec","oEdtTec","oEdtNCul","oEdtCult",)
		SetPrvt("oEdtDiag","oEdtNEqui","oEdtEqui","oEdtNApl","oEdtIAdic","oBtnGravar")
 
		oJanReceit := MSDialog():New( 072,225,456,826," Dados Complementares  - Receita Agronômica ",,,.F.,,,,,,.T.,,,.T. )
		oGrpProd   := TGroup():New( 000,000,028,296," Dados do Produto ",oJanReceit,CLR_BLACK,CLR_WHITE,.T.,.F. )
		oGrpAdic   := TGroup():New( 028,000,160,296," Informações Adicionais ",oJanReceit,CLR_BLACK,CLR_WHITE,.T.,.F. )
		
		oEdtProd   := TGet():New( 008,004,{|u| If(PCount()>0,cEdtProd:=u,cEdtProd)}		,oGrpProd,060,008,'',{||VldTab("SB1",cEdtProd )}	,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||TrcTab("SB1",cEdtProd )}	,.F.,.F.,"SB1"		,"cEdtProd"		,	,	,	, .F.	, .F.	, .F.	, "Produto:"		, 1 ,,,,,.T.)
		oEdtProd:Disable()
		oEdtNProd  := TGet():New( 008,064,{|u| If(PCount()>0,cEdtNProd:=u,cEdtNProd)}	,oGrpProd,228,008,'',								,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,								,.F.,.F.,""			,"cEdtNProd"	,	,	,	, .F.	, .F.	, .F.	, "Descrição:"		, 1 ,,,,,.T.)
		oEdtNProd:Disable()
		oEdtTec    := TGet():New( 037,004,{|u| If(PCount()>0,cEdtTec:=u,cEdtTec)}		,oGrpAdic,054,008,'',{||VldTab("ZB1",cEdtTec )}		,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||TrcTab("ZB1",cEdtTec )}		,.F.,.F.,"ZB1TEC"	,"cEdtTec"		,	,	,	, .F.	, .F.	, .F.	, "TÃ©cnico:"		, 1 ,,,,,.T.)
		oEdtNTec   := TGet():New( 037,064,{|u| If(PCount()>0,cEdtNTec:=u,cEdtNTec)}		,oGrpAdic,228,008,'',								,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,								,.F.,.F.,""			,"cEdtNTec"		,	,	,	, .F.	, .F.	, .F.	, "Técnico:"		, 1 ,,,,,.T.)
		oEdtNTec:Disable()
		IF !Empty(cTmpTec)
			oEdtNTec:Disable()
		EndIF
		oEdtCult   := TGet():New( 055,004,{|u| If(PCount()>0,cEdtCult:=u,cEdtCult)}		,oGrpAdic,054,008,'',{||VldTab("NP3",cEdtCult )}	,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||TrcTab("NP3",cEdtCult )}	,.F.,.F.,"ZB0CUL"	,"cEdtCult"		,	,	,	, .F.	, .F.	, .F.	, "Cultura:"		, 1 ,,,,,.T.)
		oEdtNCul   := TGet():New( 055,064,{|u| If(PCount()>0,cEdtNCul:=u,cEdtNCul)}		,oGrpAdic,228,008,'',								,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,								,.F.,.F.,""			,"cEdtNCul"		,	,	,	, .F.	, .F.	, .F.	, "Descrição:"		, 1 ,,,,,.T.)
		oEdtNCul:Disable()

		oEdtDiag   := TGet():New( 074,004,{|u| If(PCount()>0,cEdtDiag:=u,cEdtDiag)}		,oGrpAdic,054,008,'',{||VldTab("ZB4",cEdtDiag )}	,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||TrcTab("ZB4",cEdtDiag )}	,.F.,.F.,"ZB0DIA"	,"cEdtDiag"		,	,	,	, .F.	, .F.	, .F.	, "Diagnostico:"	, 1 ,,,,,.T.)
		oEdtNDiag  := TGet():New( 074,064,{|u| If(PCount()>0,cEdtNDiag:=u,cEdtNDiag)}	,oGrpAdic,228,008,'',								,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,								,.F.,.F.,""			,"cEdtNDiag"	,	,	,	, .F.	, .F.	, .F.	, "Descrição:"		, 1 ,,,,,.T.)
		oEdtNDiag:Disable()

		oEdtEqui   := TGet():New( 094,004,{|u| If(PCount()>0,cEdtEqui:=u,cEdtEqui)}		,oGrpAdic,054,008,'',{||VldTab("ZB5",cEdtEqui )}	,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||TrcTab("ZB5",cEdtEqui )}	,.F.,.F.,"ZB0EQU"	,"cEdtEqui"		,	,	,	, .F.	, .F.	, .F.	, "Equipamento:"	, 1 ,,,,,.T.)
		oEdtNEqui  := TGet():New( 094,064,{|u| If(PCount()>0,cEdtNEqui:=u,cEdtNEqui)}	,oGrpAdic,228,008,'',								,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,								,.F.,.F.,""			,"cEdtNEqui"	,	,	,	, .F.	, .F.	, .F.	, "Descrição:"		, 1 ,,,,,.T.)
		oEdtNEqui:Disable()

		//TGet():New( [ L ], [ C ], [ bSetGet ], [ oWnd ], [ nWidth ], [ nHeight ], [ cPict ], [ bValid ], [ nClrFore ], [ nClrBack ], [ oFont ], [ uParam12 ], [ uParam13 ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ bWhen ], [ uParam18 ], [ uParam19 ], [ bChange ], [ lReadOnly ], [ lPassword ], [ uParam23 ], [ cReadVar ], [ uParam25 ], [ uParam26 ], [ uParam27 ], [ lHasButton ], [ lNoButton ], [ uParam30 ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ], [ cPlaceHold ], [ lPicturePriority ], [ lFocSel ] )
		oEdtNApl   := TGet():New( 118,004,{|u| If(PCount()>0,cEdtNApl:=u,cEdtNApl)}	  	,oGrpAdic,110,008,'',/*{||VldTab("ZB0",cEdtNApl )}*/ , CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||TrcTab("ZB0",cEdtProd+cEdtCult+cEdtDiag+cEdtDiag)},.F.,.F.,,,	,	,	, .F.	, .F.	, .F.	, "No.Aplicação:"		   , 1 ,,,,,.T.)
		oEdtIAdic  := TGet():New( 140,004,{|u| If(PCount()>0,cEdtIAdic:=u,cEdtIAdic)}		,oGrpAdic,286,008,'',/*{||VldTab("ZB0",cEdtIAdic )}*/, CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||TrcTab("ZB0",cEdtProd+cEdtCult+cEdtDiag+cEdtDiag )},.F.,.F.,,,	,	,	, .F.	, .F.	, .F.	, "Informações Adic.:"	, 1 ,,,,,.T.)
			
		oBtnGravar := TButton():New( 168,258,"&Gravar",oJanReceit,{||lRetGrv := GravaLoja(cEdtProd,cEdtTec,cEdtCult,cEdtDiag,cEdtEqui,cEdtNApl,cEdtIAdic) },037,012,,,,.T.,,"",,,,.F. )
		oJanReceit:lEscClose	:= .F. //Nao permite sair ao se pressionar a tecla ESC.  
		oJanReceit:lCentered	:= .T.
		oJanReceit:Activate(,,,.T.)
	
	 If FunName()=="LOJA701"
			M->LQ_XTECNIC := cEdtTec
			M->LQ_XNMTECN := cEdtNTec
		else
			M->C5_XTECNIC := cEdtTec
			M->C5_XNMTECN := cEdtNTec
		Endif
	Else
		lRetGrv := .T.
	EndIF

Return lRetGrv

//Função para gravar as informações no Loja
//Static Function GravaLoja(cTmpProd, cTmpTec, cTmpCult, cTmpDiag, cTmpEqui, lComTela)
Static Function GravaLoja(cTmpProd, cTmpTec, cTmpCult, cTmpDiag, cTmpEqui, cNApl, cIAdic, lComTela)
	Local lRet 		:= .T.
	Local cNomePro	:= Posicione("SB1",1,xFilial("SB1") + cTmpProd,"B1_DESC")
	Default lComTela := .T.
	Public NQTDITENS := IIF(empty(NQTDITENS),NQTDITENS:=0,NQTDITENS)

	IF lRet .AND. Empty(cTmpTec)
		//Alert("É obrigatório o preenchimento do tipo de cultura utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
		IF lComTela
			U_MsgHelp(,"É obrigatório o preenchimento do Técnico utilizado para emissão da Receita.", "Verifique o Técnico para emissão da receita.")
		EndIF

		lRet:= .F.
	EndIF
	IF lRet .AND. Empty(cTmpCult)
		//Alert("É obrigatório o preenchimento do tipo de cultura utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
		IF lComTela
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de cultura utilizada para o produto: "+ENTER+Alltrim(cTmpProd) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Cultura informada.")
		EndIF
		lRet:= .F.
	EndIF
	IF lRet .AND. Empty(cTmpDiag)
		//Alert("É obrigatório o preenchimento do tipo de diagnostico utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
		IF lComTela
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de diagnostico utilizada para o produto: "+ENTER+Alltrim(cTmpProd) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Diagnostico informada.")
		EndIF
		lRet:= .F.
	EndIF
	IF lRet .AND. Empty(cTmpEqui)
		//Alert("É obrigatório o preenchimento do tipo de Equipamento utilizada para o produto: "+ENTER+Alltrim(cProduto) + '-'+Alltrim(cNomePro))
		IF lComTela
			U_MsgHelp(,"É obrigatório o preenchimento do tipo de Equipamento utilizada para o produto: "+ENTER+Alltrim(cTmpProd) + '-'+Alltrim(cNomePro), "Verifique o Item mencionado que está sem Equipamento informada.")
		EndIF
		lRet:= .F.
	EndIF
	IF lRet .AND. !Empty(cTmpCult) .AND. !Empty(cTmpDiag) .AND. !Empty(cTmpEqui)
		If !(ValRecAg(cTmpProd, cTmpCult, cTmpDiag, cTmpEqui))
			//Alert("Produto: "+Alltrim(cProduto) + '-'+Alltrim(cNomePro)+" não tem receita agronômica cadastrada." )
			IF lComTela
				U_MsgHelp(,"Produto: "+Alltrim(cTmpProd) + '-'+Alltrim(cNomePro)+" não tem receita agronômica cadastrada.", "Verifique o Cadastro de Produto x Cultura.")
			EndIF
			lRet:= .F.
		EndIF
	EndIF
	
	IF lRet .AND. lComTela
		M->LQ_XRECEIT	:= "S"
		M->LQ_XTECNIC	:= cTmpTec
		M->LQ_XNMTECN	:= Posicione("ZB1",1,xFilial("ZB1")+cValTochar(cTmpTec),"ZB1_NMTECN")
		M->LQ_XTECFIL	:= Posicione("ZB1",1,xFilial("ZB1")+cValTochar(cTmpTec),"ZB1_FILTEC")	
		M->LQ_XFILAUT	:= cFilAnt
		SYSREFRESH()
		
		//cDaOnde := FunName() //MATA410 //LOJA701
		// "LR_XCULTUR"
		aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(FunName()=="LOJA701","LR_XCULTUR", "C6_XCULTUR")})] := cTmpCult 
		aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(FunName()=="LOJA701","LR_XDIAGNO", "C6_XDIAGNO")})] := cTmpDiag 
		aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(FunName()=="LOJA701","LR_XEQUIPO", "C6_XEQUIPO")})] := cTmpEqui 
		aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(FunName()=="LOJA701","LR_XNAPLIC", "C6_XNAPLIC")})] := cNApl 
		aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(FunName()=="LOJA701","LR_XOBSERV", "C6_XOBSERV")})] := cIAdic 
		oJanReceit:End()
    	NQTDITENS++ // Contar quantos item precisa de Receituario Agronomico;

//	Else
//			M->LQ_XRECEIT	:= "N"
//			aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(FunName()=="LOJA701","LR_XCULTUR", "C6_XCULTUR")})] := "" 
//			aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(FunName()=="LOJA701","LR_XDIAGNO", "C6_XDIAGNO")})] := "" 
//			aCols[N,Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(FunName()=="LOJA701","LR_XEQUIPO", "C6_XEQUIPO")})] := "" 
	EndIF

Return lRet

//Função para validar os dados da tabela
Static Function VldTab(cTab, cContem)
	Local lRet	:= .F.
	IF !Empty(cContem)
		Do Case
			Case cTab == "SB1"
			lRet := !Empty(Posicione("SB1",1,xFilial("SB1") + cContem,"B1_DESC"))
			Case cTab == "ZB1"
			lRet := !Empty(Posicione("ZB1",1,xFilial("ZB1") + cContem,"ZB1_NMTECN"))
			Case cTab == "NP3"
			lRet := !Empty(Posicione("NP3",1,xFilial("NP3") + Substr(cContem,1,TamSX3("NP3_CODIGO")[1]),"NP3_DESCRI"))
			Case cTab == "ZB4"	
			lRet := !Empty(Posicione("ZB4",1,xFilial("ZB4") + cContem,"ZB4_DESCRI"))
			Case cTab == "ZB5"
			lRet := !Empty(Posicione("ZB5",1,xFilial("ZB5") + cContem,"ZB5_DESCRI"))
			OtherWise
			lRet	:= .F.
		EndCase
	Else
		lRet	:= .T.
	EndIF

Return lRet

//Função para preencher os itens que estão amarrados as tabelas
Static Function TrcTab(cTab, cContem)

	IF !Empty(cContem)
		Do Case
			Case cTab == "SB1"
			cEdtNProd := Posicione("SB1",1,xFilial("SB1") + cContem,"B1_DESC")
			IF Empty(cEdtNProd)
				cEdtProd	:= Space(TamSX3("B1_COD")[1] )
				cEdtNProd	:= Space(TamSX3("B1_DESC")[1] )
				oEdtProd:SetFocus()
				U_MsgHelp(,"Produto informado não encontrado.", "Verifique a informação digitada.")
			EndIF
			oEdtProd:Refresh()
			oEdtNProd:Refresh()

			Case cTab == "ZB1"
			cEdtNTec := Posicione("ZB1",1,xFilial("ZB1") + cContem,"ZB1_NMTECN")
			IF Empty(cEdtNTec)
				cEdtTec		:= Space(TamSX3("ZB1_TECNIC")[1] )
				cEdtNTec	:= Space(TamSX3("ZB1_NMTECN")[1] )
				oEdtTec:SetFocus()
				U_MsgHelp(,"Técnico informado não encontrado.", "Verifique a informação digitada.")
			EndIF
			oEdtTec:Refresh()
			oEdtNTec:Refresh()

			Case cTab == "NP3"
			cEdtNCul := Alltrim(Posicione("NP3",1,xFilial("NP3") + Substr(cContem,1,TamSX3("NP3_CODIGO")[1]),"NP3_DESCRI"))
			IF Empty(cEdtNCul)
				cEdtCult	:= Space(TamSX3("NP3_CODIGO")[1] )
				cEdtNCul	:= Space(TamSX3("NP3_DESCRI")[1] )
				oEdtCult:SetFocus()
				U_MsgHelp(,"Cultura informada não encontrada.", "Verifique a informação digitada.")
			EndIF
			oEdtCult:Refresh()
			oEdtNCul:Refresh()

			Case cTab == "ZB4"	
			cEdtNDiag := Posicione("ZB4",1,xFilial("ZB4") + cContem,"ZB4_DESCRI")
			IF Empty(cEdtNDiag)
				cEdtDiag	:= Space(TamSX3("ZB4_CODIGO")[1] )
				cEdtNDiag	:= Space(TamSX3("ZB4_DESCRI")[1] )
				oEdtDiag:SetFocus()
				U_MsgHelp(,"Diagostico informado não encontrado.", "Verifique a informação digitada.")
			EndIF
			oEdtDiag:Refresh()
			oEdtNDiag:Refresh()

			Case cTab == "ZB5"
			cEdtNEqui := Posicione("ZB5",1,xFilial("ZB5") + cContem,"ZB5_DESCRI")
			IF Empty(cEdtNEqui)
				cEdtEqui	:= Space(TamSX3("ZB5_CODIGO")[1] )
				cEdtNEqui	:= Space(TamSX3("ZB5_DESCRI")[1] )
				oEdtEqui:SetFocus()
				U_MsgHelp(,"Equipamento informado não encontrado.", "Verifique a informação digitada.")
			EndIF
			oEdtEqui:Refresh()
			oEdtNEqui:Refresh()
			Case cTab == "ZB0"
				If Empty(cEdtNApl)
					cEdtNApl  := Posicione("ZB0",1,xFilial("ZB0") + cContem,"ZB0_NAPLIC" )
				EndIf
				If Empty(cEdtIAdic)
					cEdtIAdic := Posicione("ZB0",1,xFilial("ZB0") + cContem,"ZB0_OBSERV" )
					If Len(cEdtIAdic) < 250
						cEdtIAdic := cEdtIAdic+space(250-len(cEdtIAdic))
					EndIf
				EndIf
			
			OEdtNApl:Refresh()
			OEdtIAdic:Refresh()


		EndCase
	EndIF

Return .T.

//Função para Simular o RunTrigger
User Function FTRunAll(nTipo, nLinha, cMacro, cCampo, lRunVld, lRunGat, uReturn)

	Local aArea     := GetArea()
	Local aAreaSX3  := SX3->(GetArea())

	Local cProcName
	Local nContador

	Local lValido
	Local cBkpRead  := __ReadVar
	Local cBkpXVar  := &(__ReadVar)

	Default cMacro  := ""

	Default lRunVld := .T.
	Default lRunGat := .T.

	cCampo := Padr(cCampo, 10)

	//Controle para não ocorrer recursividade na chamada na validação efetuada pela RunAll
	cProcName := ProcName()
	nContador := 1

	While !Empty(ProcName(nContador))
		If cProcName == ProcName(nContador)
			Return uReturn
		End
		nContador ++
	End

	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(cCampo))

		dbSelectArea(SX3->X3_Arquivo)

		If nTipo == 1

			__ReadVar := "M->" + cCampo

			lValido := .T.

			If lRunVld
				If lValido .And. !Empty(SX3->X3_Valid)
					lValido := &(SX3->X3_Valid)
				End

				If lValido .And. !Empty(SX3->X3_VldUser)
					lValido := &(SX3->X3_VldUser)
				End
			End

			//Se der erro na validação, limpa o campo origem
			If !lValido
				&(__ReadVar) := CriaVar(cCampo)
			End

			If lRunGat
				If lValido
					RunTrigger(1,,cMacro,,cCampo)
				End
			End

		ElseIf nTipo == 2

			__ReadVar := "M->" + cCampo

			lValido := .T.

			If lRunVld
				&(__ReadVar) := aCols[nLinha,gdFieldPos(cCampo)]

				If lValido .And. !Empty(SX3->X3_Valid)
					lValido := &(SX3->X3_Valid)
				End

				If lValido .And. !Empty(SX3->X3_VldUser)
					lValido := &(SX3->X3_VldUser)
				End
			End

			//Se der erro na validação, limpa o campo origem
			If !lValido
				&(__ReadVar) := CriaVar(cCampo)
				aCols[nLinha,gdFieldPos(cCampo)] := CriaVar(cCampo)
			End

			If lRunGat
				If lValido
					RunTrigger(2, nLinha, cMacro,,cCampo)
				End
			End
		End
	End

	__ReadVar    := cBkpRead
	&(__ReadVar) := cBkpXVar

	RestArea(aAreaSX3)
	RestArea(aArea)

Return uReturn

User Function FilZB0C()
Local cFiltro := "@ZB0_PRODUT = '" + cEdtProd + "' "
Return(cFiltro)

User Function FilZB0D()
Local cFiltro := "@ZB0_PRODUT = '" + cEdtProd + "' AND " +;
                 "ZB0_CULTUR = '" + cEdtCult + "'"  
Return(cFiltro)

User Function FilZB0E()
Local cFiltro := "@ZB0_PRODUT = '" + cEdtProd + "' AND "+;
                 "ZB0_CULTUR = '" + cEdtCult + "' AND "+;  
                 "ZB0_DIAGNO = '" + cEdtDiag + "'"  
Return(cFiltro)


//
// Função para Verificar na opção do Faturamento se haverá Receituário para os itens inclusos.
// 19/05/2020
// Chandrer
//		u_ConfReceit( cod_Tecnico )
User Function ConfReceit(cTmpCmp)
Local lRet      := .T.
Local aArea     := GetArea()
Local cAlias1	:= GetNextAlias()     // retorna o próximo alias disponível
Local nPosProd	:= aScan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(funname()="LOJA701","LR_PRODUTO", "C6_PRODUTO")})	
Local nQuant    := 0
LOCAL nItem     := 0
LOCAL nQtdRCT   := 0

IF !Empty(cTmpCmp) 
		// Verificando se existe Receituario para todos os itens
		cQuery1:="SELECT ZB2_PRXREC, ZB2_RECFIM "
		cQuery1+= "FROM "+RetSqlName("ZB2")+" ZB2 "
		cQuery1+= "WHERE "+RetSqlCond("ZB2")
		cQuery1+= " AND ZB2_PRXREC <= ZB2_RECFIM "
		cQuery1+= " AND ZB2_TECNIC = '"+cValToChar(cTmpCmp)+"' "
		cQuery1+= " AND ZB2_ATIVO = 'S' AND ZB2_FINAL = 'N' "
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery1),cAlias1,.T.,.T.)
		dbSelectArea(cAlias1)
		(cAlias1)->(dbGoTop())
		Do While (cAlias1)->(!EOF()) // Verifico todos receituarios do tecnico que esteja ativo pra ver se os itens cabe no receituário;
			nQtdRCT += ((cAlias1)->ZB2_RECFIM) - ((cAlias1)->ZB2_PRXREC) 
			(cAlias1)->(dBSkip())
		ENDDO

		// Realiza a contagem de qtos itens precisa de receituario agronomico;   
		FOR nItem := 1 to len(aCols)
			IF !(aCols[nItem][Len(aCols[nItem])])
				lReceita	:= !Empty(POSICIONE("ZB0", 1,xFilial("ZB0")+ aCols[nItem,nPosProd]  , "ZB0_PRODUT"))
				If lReceita 
					//nQuant := nQuant + aCols[nItem,aScan(aHeader,{|x| Alltrim(Upper(x[2])) == IIF(funname()="LOJA701","LR_QUANT", "C6_QTDVEN")})]
					nQuant ++
				EndIf
			EndIf
		NEXT nItem

		If nQuant > nQtdRCT
			MsgStop("- Não será possível gerar os receituarios necessários para este Pedido, os itens ultrapassam a Numeração do Receituario!"+chr(13)+"Numeros disponivels..: "+ str(nQtdRCT))
			lRet:=.F.
		EndIf
EndIf
RestArea(aArea)
Return(lRet)

