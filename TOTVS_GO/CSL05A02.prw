// #########################################################################################
// Projeto: Casul
// Modulo : Faturamento
// Fonte  : DSG05A02
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 13/05/19	| Ricardo Mendes    | Cadastro de Técnicos (Receituario Agronomico)
// ---------+-------------------+-----------------------------------------------------------

#Include 'Protheus.ch'
#include 'parmtype.ch'
#Include "TOPCONN.CH"

#DEFINE ENTER Chr(10)+Chr(13)

user function CSL05A02()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer, oPanel
	Private oBrowse
	Private oDlgPrinc
	Private cCadastro := "Cadastros de Técnicos (Receituario Agronomico)"

	Private LEXECAUTO := .F.
	Private lNovaRotina := .T.

	Define MsDialog oDlgPrinc Title '[CSL05A02] ' + cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( 'LINHA', 100, .F. )// Cria uma "linha" com 100% da tela
	oFWLayer:AddCollumn( 'COLUNA', 100, .T., 'LINHA' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oPanel := oFWLayer:GetColPanel( 'COLUNA', 'LINHA' )// Pego o objeto desse pedaço do container
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPanel ) // Aqui se associa o browse ao componente de tela
	oBrowse:SetDescription( "Cadastros de Técnicos (Receituario Agronomico)" )
	//oBrowse:DisableDetails()
	oBrowse:SetAlias( 'ZB1' )
	oBrowse:SetMenuDef( 'CSL05A02' ) // Define de que fonte virão os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Força a exibicao do botão Sair
	oBrowse:Activate()

	Activate MsDialog oDlgPrinc CENTER

return NIL

//***************************
Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.CSL05A02', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir' 		, 'VIEWDEF.CSL05A02', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar' 		, 'VIEWDEF.CSL05A02', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir' 		, 'U_05A02EXC()'	, 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir' 	, 'VIEWDEF.CSL05A02', 0, 8, 0, NIL } )

Return aRotina

Static Function ModelDef()

	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruZB1M := FWFormStruct( 1, 'ZB1' )
	Local oModel // Modelo de dados construído

	// Cria o objeto do Modelo de Dados
	oModel := MpFormModel():New( '_SL05A02',/*Pre-Validacao*/,/*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'ZB1MASTER', /*cOwner*/, oStruZB1M , /*bLinePre*/,  /* bLinePost*/, /*bPre*/ )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( cCadastro )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'ZB1MASTER' ):SetDescription( 'Cadastros de Técnicos (Receituario Agronomico)' )

	// chave primaria
	oModel:SetPrimaryKey( {} )

	// Retorna o Modelo de dados
Return oModel

//******************************
Static Function ViewDef()
	//******************************

	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'CSL05A02' )

	// Cria as estruturas a serem usadas na View
	Local oStruZB1M := FWFormStruct( 2, 'ZB1' )

	// Interface de visualização construída
	Local oView		:= FWFormView():New()

	//oStruZA3M:RemoveField('ZA3_FILIAL')

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Para nao reabrir a tela, após salvar registro
	oView:SetCloseOnOk({||.T.})

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_MASTER', oStruZB1M, 'ZB1MASTER' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 100)

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )

	// Retorna o objeto de View criado
Return oView

//Função para validar que já existe cadastro igual entre Tecnico x Nr. CREA
User Function 05A02EXT(cTecno, cCrea)
	Local lRet:= .T.
	Local cQuery:= ""

	cQuery := "SELECT COUNT(ZB1_TECNIC) CONTADOR "
	cQuery += " FROM " + RetSqlName("ZB1") + " ZB1 "
	cQuery += " WHERE " + RetSqlCond("ZB1")
	cQuery += " AND ZB1_CREA = '"+cCrea+"' "
	cQuery += " AND ZB1_TECNIC <> '"+cTecno+"' "

	If Select("QRY") <> 0
		QRY->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QRY",.T.,.T.)
	While QRY->(!EOF())
		lRet:= IIF(QRY->CONTADOR = 0, .T., .F.)
		QRY->(dbSkip())
	EndDo

	IF !lRet 
		//Help('',1,"05A02EXT","","Já existe um cadastro de Técnico, com o mesmo Nr. CREA: "+Alltrim(cCrea),1,0)
		U_MsgHelp(,"Já existe um cadastro de Técnico, com o mesmo Nr. CREA: "+Alltrim(cCrea), "Cadastro já existente.")
	EndIF	

Return lRet

//Função para preencher o nome do municipio a partir do código do IBGE
User Function 05A02Mun(cUF, cIBGE)
	Local cDescMun:= ""

	IF Empty(cUF)
		//Help('',1,"05A02Mun","","Campo UF está em branco.",1,0)
		U_MsgHelp(,"Campo UF está em branco.", "Verifique o campo de UF.")
	ElseIF Empty(cIBGE)
		//Help('',1,"05A02Mun","","Campo IBGE está em branco.",1,0)
		U_MsgHelp(,"Campo IBGE está em branco", "Verifique o campo de IBGE.")
	Else
		cDescMun:=POSICIONE("CC2", 1, xFilial("CC2") +cUF+cIBGE, "CC2_MUN")
	EndIF

Return cDescMun

//Função para validar se pode excluir registro que podem ter sido utilizados.
User Function 05A02EXC()
	Local lRet:= .T.
	Local cTec:= ZB1_TECNIC
	Local cQuery:= ""

	cQuery := "SELECT COUNT(F2_DOC) CONTADOR "
	cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
	cQuery += " WHERE " + RetSqlCond("SF2")
	cQuery += " AND F2_XTECNIC = '"+cTec+"' "

	If Select("QRYSF2") <> 0
		QRYSF2->(dbCloseArea())
	EndIf

	TCQUERY cQuery NEW ALIAS "QRYSF2"

	dbSelectArea("QRYSF2")
	QRYSF2->(dbGoTop())

	While !QRYSF2->(EOF())
		lRet:= IIF(QRYSF2->CONTADOR = 0, .T., .F.)
		QRYSF2->(dbSkip())
	EndDo

	If !(lRet)
		lRet:=.F.
		//MsgAlert("Técnico já foi utilizado. Não é permitido realizar a exclusão.","Exclusão de Dados")
		U_MsgHelp(,"Técnico já foi utilizado.", "Exclusão não permitida.")
	Else
		RecLock("ZB1",.F.) // Define que será realizada uma alteração no registro posicionado
		DbDelete() // Efetua a exclusão lógica do registro posicionado.
		MsUnLock() // Confirma e finaliza a operação
	EndIf

Return lRet
