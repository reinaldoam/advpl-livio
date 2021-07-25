// #########################################################################################
// Projeto: CASUL
// Modulo : Faturamento
// Fonte  : CSL05A01
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 13/05/19	| Ricardo Mendes    | Cadastro de Produto x Cultura (Receituario Agronomico)
// ---------+-------------------+-----------------------------------------------------------

#Include 'Protheus.ch'
#include 'parmtype.ch'
#Include "TOPCONN.CH"

#DEFINE ENTER Chr(10)+Chr(13)

user function CSL05A01()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer, oPanel
	Private oBrowse
	Private oDlgPrinc
	Private cCadastro := "Cadastro de Produto x Cultura (Receituario Agronomico)"

	Private LEXECAUTO := .F.
	Private lNovaRotina := .T.

	Define MsDialog oDlgPrinc Title '[CSL05A01] ' + cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( 'LINHA', 100, .F. )// Cria uma "linha" com 100% da tela
	oFWLayer:AddCollumn( 'COLUNA', 100, .T., 'LINHA' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oPanel := oFWLayer:GetColPanel( 'COLUNA', 'LINHA' )// Pego o objeto desse pedaço do container
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPanel ) // Aqui se associa o browse ao componente de tela
	oBrowse:SetDescription( "Cadastro de Produto x Cultura (Receituario Agronomico)" )
	//oBrowse:DisableDetails()
	oBrowse:SetAlias( 'ZB0' )
	oBrowse:SetMenuDef( 'CSL05A01' ) // Define de que fonte virão os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Força a exibicao do botão Sair
	oBrowse:Activate()

	Activate MsDialog oDlgPrinc CENTER

return NIL

Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.CSL05A01', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'		, 'VIEWDEF.CSL05A01', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'		, 'VIEWDEF.CSL05A01', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'		, 'U_05A01EXC()'	, 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir'		, 'VIEWDEF.CSL05A01', 0, 8, 0, NIL } )

Return aRotina

Static Function ModelDef()

	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruZB0M := FWFormStruct( 1, 'ZB0' )
	Local oModel // Modelo de dados construído

	// Cria o objeto do Modelo de Dados
	oModel := MpFormModel():New( '_SL05A01',/*Pre-Validacao*/,/*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'ZB0MASTER', /*cOwner*/, oStruZB0M , /*bLinePre*/,  /* bLinePost*/, /*bPre*/ )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( cCadastro )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'ZB0MASTER' ):SetDescription( 'Cadastro de Produto x Cultura (Receituario Agronomico)' )

	// chave primaria
	oModel:SetPrimaryKey( {} )

	// Retorna o Modelo de dados
Return oModel

//******************************
Static Function ViewDef()
	//******************************

	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'CSL05A01' )

	// Cria as estruturas a serem usadas na View
	Local oStruZB0M := FWFormStruct( 2, 'ZB0' )

	// Interface de visualização construída
	Local oView		:= FWFormView():New()

	//oStruZA3M:RemoveField('ZA3_FILIAL')

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Para nao reabrir a tela, após salvar registro
	oView:SetCloseOnOk({||.T.})

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_MASTER', oStruZB0M, 'ZB0MASTER' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 100)

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )

	// Retorna o objeto de View criado
Return oView

//Função para validar que já existe cadastro igual entre Produto x Cultura
User Function 05A01DSC(cProd, cCult, cDiag, cEquipa)
	Local lret := .T.
	Local cDesc := ""

	cDesc:=Posicione("ZB0",1,xFilial("ZB0")+cProd+cCult+cDiag+cEquipa,"ZB0_NMPROD")
	If !Empty(cDesc)
		lRet:=.F.
		//Help('',1,"05A01DSC","","Produto ("+Alltrim(cProd)+") x Cultura ("+Alltrim(cCult)+") já cadastrado",1,0)
		U_MsgHelp(,"Produto ("+Alltrim(cProd)+") x Cultura ("+Alltrim(cCult)+") x Diagnostico ("+Alltrim(cDiag)+") x Equipamento ("+Alltrim(cEquipa)+") já cadastrado", "Verifique os dados informados.")
	Endif

Return(lRet)

//Função para validar se pode excluir registro que podem ter sido utilizados.
User Function 05A01EXC()
	Local lRet:= .T.
	Local cCult:= ZB0_CULTUR
	Local cProd:= ZB0_PRODUT
	Local cDiag:= ZB0_DIAGNO
	Local cEqui:= ZB0_EQUIPA
	Local cQuery:= ""

	cQuery := "SELECT COUNT(D2_COD) CONTADOR "
	cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += " WHERE " + RetSqlCond("SD2")
	cQuery += " AND D2_COD = '"+cProd+"' "
	cQuery += " AND D2_XCULTUR = '"+cCult+"' "
	cQuery += " AND D2_XDIAGNO = '"+cDiag+"' "
	cQuery += " AND D2_XEQUIPO = '"+cEqui+"' "

	If Select("QRYSD2") <> 0
		QRYSD2->(dbCloseArea())
	EndIf

	TCQUERY cQuery NEW ALIAS "QRYSD2"

	dbSelectArea("QRYSD2")
	QRYSD2->(dbGoTop())

	While !QRYSD2->(EOF())
		lRet:= IIF(QRYSD2->CONTADOR = 0, .T., .F.)
		QRYSD2->(dbSkip())
	EndDo

	If !(lRet)
		lRet:=.F.
		//MsgAlert("Receita Agronômica já foi utilizada. Não é permitido realizar a exclusão.","Exclusão de Dados")
		//Help('',1,"05A01EXC","","Produto ("+Alltrim(cProd)+") x Cultura ("+Alltrim(cCult)+") já foi utilizada. Não é permitido realizar a exclusão.",1,0)
		U_MsgHelp(,"Produto ("+Alltrim(cProd)+") x Cultura ("+Alltrim(cCult)+") x Diagnostico ("+Alltrim(cDiag)+") x Equipamento ("+Alltrim(cEqui)+") já foi utilizada. Não é permitido realizar a exclusão.", "Exclusão não permitido.")
	Else
		RecLock("ZB0",.F.) // Define que será realizada uma alteração no registro posicionado
		DbDelete() // Efetua a exclusão lógica do registro posicionado.
		MsUnLock() // Confirma e finaliza a operação
	EndIf

Return lRet


