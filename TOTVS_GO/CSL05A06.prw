// #########################################################################################
// Projeto: Comiva
// Modulo : Faturamento
// Fonte  : CSL05A06
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 13/05/19	| Ricardo Mendes    | Cadastro de Equipamento (Receituario Agronomico)
// ---------+-------------------+-----------------------------------------------------------

#Include 'Protheus.ch'
#include 'parmtype.ch'
#Include "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE MODEL_OPERATION_VIEW       1
#DEFINE MODEL_OPERATION_INSERT     3
#DEFINE MODEL_OPERATION_UPDATE     4
#DEFINE MODEL_OPERATION_DELETE     5
#DEFINE MODEL_OPERATION_ONLYUPDATE 6
#DEFINE ENTER Chr(10)+Chr(13)

user function CSL05A06()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer, oPanel
	Private oBrowse
	Private oDlgPrinc
	Private cCadastro := "Cadastro de Equipamento (Receituario Agronomico)"

	Private LEXECAUTO := .F.
	Private lNovaRotina := .T.

	Define MsDialog oDlgPrinc Title '[CSL05A06] ' + cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( 'LINHA', 100, .F. )// Cria uma "linha" com 100% da tela
	oFWLayer:AddCollumn( 'COLUNA', 100, .T., 'LINHA' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oPanel := oFWLayer:GetColPanel( 'COLUNA', 'LINHA' )// Pego o objeto desse pedaço do container
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPanel ) // Aqui se associa o browse ao componente de tela
	oBrowse:SetDescription( "Cadastro de Equipamento (Receituario Agronomico)" )
	//oBrowse:DisableDetails()
	oBrowse:SetAlias( 'ZB5' )
	oBrowse:SetMenuDef( 'CSL05A06' ) // Define de que fonte virão os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Força a exibicao do botão Sair
	oBrowse:Activate()

	Activate MsDialog oDlgPrinc CENTER

return NIL

Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.CSL05A06', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'		, 'VIEWDEF.CSL05A06', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'		, 'VIEWDEF.CSL05A06', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'		, 'U_05A06EXC()'	, 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir'		, 'VIEWDEF.CSL05A06', 0, 8, 0, NIL } )

Return aRotina

Static Function ModelDef()

	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruZB5M := FWFormStruct( 1, 'ZB5' )
	Local oModel // Modelo de dados construído

	// Cria o objeto do Modelo de Dados
	oModel := MpFormModel():New( '_SL05A06',/*Pre-Validacao*/,{|oMdl| F05A06PS(oMdl) }, /*Commit*/ , /*Cancel*/)

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'ZB5MASTER', /*cOwner*/, oStruZB5M , /*bLinePre*/,  /* bLinePost*/, /*bPre*/ )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( cCadastro )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'ZB5MASTER' ):SetDescription( 'Cadastro de Diagnostico (Receituario Agronomico)' )

	// chave primaria
	oModel:SetPrimaryKey( {} )

	// Retorna o Modelo de dados
Return oModel


//******************************
Static Function ViewDef()
	//******************************

	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'CSL05A06' )

	// Cria as estruturas a serem usadas na View
	Local oStruZB5M := FWFormStruct( 2, 'ZB5' )

	// Interface de visualização construída
	Local oView		:= FWFormView():New()

	//oStruZA3M:RemoveField('ZA3_FILIAL')

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Para nao reabrir a tela, após salvar registro
	oView:SetCloseOnOk({||.T.})

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_MASTER', oStruZB5M, 'ZB5MASTER' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 100)

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )

	// Retorna o objeto de View criado
Return oView

//Função para ajustar a descrição em cadastros externos
Static Function F05A06PS( oModel )
	Local nOperation := oModel:GetOperation()
	Local lRet 		:= .T.
	Local cCodigo	:= ""
	Local cDescri	:= ""

	If nOperation == MODEL_OPERATION_UPDATE
		cCodigo	:= oModel:GetValue( 'ZB5MASTER', 'ZB5_CODIGO' )
		cDescri	:= oModel:GetValue( 'ZB5MASTER', 'ZB5_DESCRI' )

		IF !Empty(cCodigo) .AND. !Empty(cDescri)
			AtualZB0(cCodigo, cDescri)
		EndIF
	EndIf

Return lRet

//Função para atualizar todas as descrições referente ao equipamento
Static Function AtualZB0(cCodigo, cDescri)
	Local cQuery:= ""
	Local aReg	:= {}
	Local nFaz	:= 0
	
	cQuery := "SELECT ZB0.R_E_C_N_O_  "
	cQuery += "FROM "+RetSqlName("ZB0")+" ZB0 "
	cQuery += "WHERE " + RetSqlCond("ZB0")+" "
	cQuery += "AND ZB0_EQUIPA = '" + cCodigo + "' "

	aReg	:= U_CSL00G01(cQuery)

	IF Len (aReg) > 0
		DbSelectArea("ZB0")
		For nFaz:=1 to Len (aReg)
			ZB0->(dbGoto(aReg[nFaz,1]))
			RecLock("ZB0",.F.)
			ZB0->ZB0_NMEQUI:= cDescri
			ZB0->(MsUnlock())
		Next nFaz
	EndIF

Return .T.

//Função para validar se pode excluir registro que podem ter sido utilizados.
User Function 05A06EXC()
	Local lRet:= .T.
	Local cEquip:= ZB5_CODIGO
	Local cQuery:= ""

	cQuery := "SELECT COUNT(ZB0_EQUIPA) CONTADOR "
	cQuery += " FROM " + RetSqlName("ZB0") + " ZB0 "
	cQuery += " WHERE " + RetSqlCond("ZB0")
	cQuery += " AND ZB0_EQUIPA = '"+cEquip+"' "

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
		//Help('',1,"05A06EXC","","Equipamento ("+Alltrim(cEquip)+") já foi utilizada. Não é permitido realizar a exclusão.",1,0)
		U_MsgHelp(,"Equipamento ("+Alltrim(cEquip)+") já foi utilizada.", "Exclusão Não Permitida.")
	Else
		RecLock("ZB5",.F.) // Define que será realizada uma alteração no registro posicionado
		DbDelete() // Efetua a exclusão lógica do registro posicionado.
		MsUnLock() // Confirma e finaliza a operação
	EndIf

Return lRet