// #########################################################################################
// Projeto: Comiva
// Modulo : Faturamento
// Fonte  : CSL05A05
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 13/05/19	| Ricardo Mendes    | Cadastro de Diagnostico (Receituario Agronomico)
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

user function CSL05A05()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer, oPanel
	Private oBrowse
	Private oDlgPrinc
	Private cCadastro := "Cadastro de Diagnostico (Receituario Agronomico)"

	Private LEXECAUTO := .F.
	Private lNovaRotina := .T.

	Define MsDialog oDlgPrinc Title '[CSL05A05] ' + cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( 'LINHA', 100, .F. )// Cria uma "linha" com 100% da tela
	oFWLayer:AddCollumn( 'COLUNA', 100, .T., 'LINHA' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oPanel := oFWLayer:GetColPanel( 'COLUNA', 'LINHA' )// Pego o objeto desse peda�o do container
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPanel ) // Aqui se associa o browse ao componente de tela
	oBrowse:SetDescription( "Cadastro de Diagnostico (Receituario Agronomico)" )
//oBrowse:DisableDetails()
	oBrowse:SetAlias( 'ZB4' )
	oBrowse:SetMenuDef( 'CSL05A05' ) // Define de que fonte vir�o os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// For�a a exibicao do bot�o Sair
	oBrowse:Activate()

	Activate MsDialog oDlgPrinc CENTER

return NIL

Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.CSL05A05', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'		, 'VIEWDEF.CSL05A05', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'		, 'VIEWDEF.CSL05A05', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'		, 'U_05A05EXC()'	, 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir'		, 'VIEWDEF.CSL05A05', 0, 8, 0, NIL } )

Return aRotina

Static Function ModelDef()

// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruZB4M := FWFormStruct( 1, 'ZB4' )
	Local oModel // Modelo de dados constru�do
	Local oMdl

// Cria o objeto do Modelo de Dados
	oModel := MpFormModel():New( '_SL05A05'   ,/*Pre-Validacao*/,{|oMdl| F05A05PS(oMdl) }, /*Commit*/ , /*Cancel*/)

// Adiciona ao modelo um componente de formul�rio
	oModel:AddFields( 'ZB4MASTER', /*cOwner*/, oStruZB4M , /*bLinePre*/,  /* bLinePost*/, /*bPre*/ )

// Adiciona a descri��o do Modelo de Dados
	oModel:SetDescription( cCadastro )

// Adiciona a descri��o dos Componentes do Modelo de Dados
	oModel:GetModel( 'ZB4MASTER' ):SetDescription( 'Cadastro de Diagnostico (Receituario Agronomico)' )

// chave primaria
	oModel:SetPrimaryKey( {} )

// Retorna o Modelo de dados
Return oModel

//******************************
Static Function ViewDef()
//******************************

// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'CSL05A05' )

// Cria as estruturas a serem usadas na View
	Local oStruZB4M := FWFormStruct( 2, 'ZB4' )

// Interface de visualiza��o constru�da
	Local oView		:= FWFormView():New()

//oStruZA3M:RemoveField('ZA3_FILIAL')

// Define qual Modelo de dados ser� utilizado
	oView:SetModel( oModel )

// Para nao reabrir a tela, ap�s salvar registro
	oView:SetCloseOnOk({||.T.})

// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
	oView:AddField( 'VIEW_MASTER', oStruZB4M, 'ZB4MASTER' )

// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 100)

// Relaciona o identificador (ID) da View com o "box" para exibi��o
	oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )

// Retorna o objeto de View criado
Return oView

//Fun��o para ajustar a descri��o em cadastros externos
Static Function F05A05PS( oModel )
	Local nOperation := oModel:GetOperation()
	Local lRet 		:= .T.
	Local cCodigo	:= ""
	Local cDescri	:= ""

	If nOperation == MODEL_OPERATION_UPDATE
		cCodigo	:= oModel:GetValue( 'ZB4MASTER', 'ZB4_CODIGO' )
		cDescri	:= oModel:GetValue( 'ZB4MASTER', 'ZB4_DESCRI' )

		IF !Empty(cCodigo) .AND. !Empty(cDescri)
			AtualZB0(cCodigo, cDescri)
		EndIF
	EndIf

Return lRet

//Fun��o para atualizar todas as descri��es referente ao equipamento
Static Function AtualZB0(cCodigo, cDescri)
	Local cQuery:= ""
	Local aReg	:= {}
	Local nFaz	:= 0
	
	cQuery := "SELECT ZB0.R_E_C_N_O_  "
	cQuery += "FROM "+RetSqlName("ZB0")+" ZB0 "
	cQuery += "WHERE " + RetSqlCond("ZB0")+" "
	cQuery += "AND ZB0_DIAGNO = '" + cCodigo + "' "

	aReg	:= U_CSL00G01(cQuery)

	IF Len (aReg) > 0
		DbSelectArea("ZB0")
		For nFaz:=1 to Len (aReg)
			ZB0->(dbGoto(aReg[nFaz,1]))
			RecLock("ZB0",.F.)
			ZB0->ZB0_NMDIAG:= cDescri
			ZB0->(MsUnlock())
		Next nFaz
	EndIF

Return .T.

//Fun��o para validar se pode excluir registro que podem ter sido utilizados.
User Function 05A05EXC()
	Local lRet:= .T.
	Local cDiag:= ZB4_CODIGO
	Local cQuery:= ""

	cQuery := "SELECT COUNT(D2_COD) CONTADOR "
	cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += " WHERE " + RetSqlCond("SD2")
	cQuery += " AND D2_XDIAGNO = '"+cDiag+"' "

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
		//MsgAlert("Receita Agron�mica j� foi utilizada. N�o � permitido realizar a exclus�o.","Exclus�o de Dados")
		//Help('',1,"05A05EXC","","Diagnostico ("+Alltrim(cDiag)+") j� foi utilizada. N�o � permitido realizar a exclus�o.",1,0)
		U_MsgHelp(,"Diagnostico ("+Alltrim(cDiag)+") j� foi utilizada.", "Exclus�o N�o Permitida.")
	Else
		RecLock("ZB4",.F.) // Define que ser� realizada uma altera��o no registro posicionado
		DbDelete() // Efetua a exclus�o l�gica do registro posicionado.
		MsUnLock() // Confirma e finaliza a opera��o
	EndIf

Return lRet