// #########################################################################################
// Projeto: Casul
// Modulo : Faturamento
// Fonte  : CSL05A03
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 13/05/19	| Ricardo Mendes    | Cadastro de Autoriza��o de T�cnicos (Receituario Agronomico)
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 'Protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "topconn.ch"

#DEFINE ENTER Chr(10)+Chr(13) 

user function CSL05A03()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer, oPanel
	Private oBrowse
	Private oDlgPrinc
	Private cCadastro := "Autoriza��o de T�cnicos - ART (Receituario Agronomico)" 

	Private LEXECAUTO := .F.
	Private lNovaRotina := .T.

	Define MsDialog oDlgPrinc Title '[CSL05A03] ' + cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( 'LINHA', 100, .F. )// Cria uma "linha" com 100% da tela
	oFWLayer:AddCollumn( 'COLUNA', 100, .T., 'LINHA' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oPanel := oFWLayer:GetColPanel( 'COLUNA', 'LINHA' )// Pego o objeto desse peda�o do container
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPanel ) // Aqui se associa o browse ao componente de tela
	oBrowse:SetDescription( "Autoriza��o de T�cnicos - ART (Receituario Agronomico)" )
	//oBrowse:DisableDetails()
	oBrowse:SetAlias( 'ZB2' )
	oBrowse:SetMenuDef( 'CSL05A03' ) // Define de que fonte vir�o os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// For�a a exibicao do bot�o Sair
	oBrowse:Activate()

	Activate MsDialog oDlgPrinc CENTER

return NIL


Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.CSL05A03'	, 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir' 		, 'VIEWDEF.CSL05A03'	, 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar' 		, 'VIEWDEF.CSL05A03'	, 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir' 		, 'U_05A03EXC()'		, 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir' 	, 'VIEWDEF.CSL05A03'	, 0, 8, 0, NIL } )
Return aRotina

//********************************
Static Function ModelDef()
	//********************************

	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruZB2M := FWFormStruct( 1, 'ZB2' )
	Local oModel // Modelo de dados constru�do

	// Cria o objeto do Modelo de Dados
	oModel := MpFormModel():New( '_SL05A03',/*Pre-Validacao*/,/*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

	// Adiciona ao modelo um componente de formul�rio
	oModel:AddFields( 'ZB2MASTER', /*cOwner*/, oStruZB2M , /*bLinePre*/,  /* bLinePost*/, /*bPre*/ )

	// Adiciona a descri��o do Modelo de Dados
	oModel:SetDescription( cCadastro )

	// Adiciona a descri��o dos Componentes do Modelo de Dados
	oModel:GetModel( 'ZB2MASTER' ):SetDescription( 'Autoriza��o de T�cnicos - ART (Receituario Agronomico)' )

	// chave primaria
	oModel:SetPrimaryKey( {} )

	// Retorna o Modelo de dados
Return oModel

//******************************
Static Function ViewDef()
	//******************************

	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'CSL05A03' )

	// Cria as estruturas a serem usadas na View
	Local oStruZB2M := FWFormStruct( 2, 'ZB2' )

	// Interface de visualiza��o constru�da
	Local oView		:= FWFormView():New()

	//oStruZA3M:RemoveField('ZA3_FILIAL')

	// Define qual Modelo de dados ser� utilizado
	oView:SetModel( oModel )

	// Para nao reabrir a tela, ap�s salvar registro
	oView:SetCloseOnOk({||.T.})

	// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
	oView:AddField( 'VIEW_MASTER', oStruZB2M, 'ZB2MASTER' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 100)

	// Relaciona o identificador (ID) da View com o "box" para exibi��o
	oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )

	// Retorna o objeto de View criado
Return oView

//Fun��o para validadr se para o mesmo tecnico est� sendo cadastrado a mesma autoriza��o e serie
User Function 05A03TEC(cTecno, cNumART, cSerART)
	Local lRet:= .T.

	IF Empty(cTecno)
		lRet:=.F.
		//Help('',1,"05A03TEC","","T�cnico ainda n�o foi informado.",1,0)
		U_MsgHelp(,"T�cnico ainda n�o foi informado.", "Verifique o campo de T�cnico.")
	ElseIF Empty(cNumART)
		lRet:=.F.
		//Help('',1,"05A03TEC","","Nr. ART ainda n�o foi informado.",1,0)
		U_MsgHelp(,"Nr. ART ainda n�o foi informado.", "Verifique o campo de Nr. ART.")
	ElseIF Empty(cSerART)
		lRet:=.F.
		//Help('',1,"05A03TEC","","S�rie ainda n�o foi informado.",1,0)
		U_MsgHelp(,"S�rie ainda n�o foi informado.", "Verifique o campo S�rie da ART.")
	Else
		dbSelectArea("ZB2")
		ZB2->(dbSetOrder(2))
		ZB2->(dbGoTop())
		If ZB2->(dbSeek(xFilial("ZB2")+cTecno+cNumART+cSerART))
			lRet:=.F.
			//Help('',1,"05A03TEC","","J� existe um registro de Autoriza��o/Serie para esse T�cnico cadastrado.",1,0)
			U_MsgHelp(,"J� existe um registro de Autoriza��o/Serie para esse T�cnico cadastrado.", "Verifique as informa��es mencionadas.")
		Endif
	EndIF

Return lRet

//Fun��o para validar se o Range da Receita j� n�o foi utilizado em outro cadastro
User Function 05A03REC(cTecno, nNumero, cNumART, cSerART)
	Local aArea:= GetArea()
	Local lRet:= .T.

	IF Empty(cTecno)
		lRet:=.F.
		//Help('',1,"05A03REC","","T�cnico ainda n�o foi informado.",1,0)
		U_MsgHelp(,"T�cnico ainda n�o foi informado.", "Verifique o campo de T�cnico.")
	ElseIF Empty(cNumART)
		lRet:=.F.
		//Help('',1,"05A03REC","","T�cnico ainda n�o foi informado.",1,0)
		U_MsgHelp(,"Nr. ART ainda n�o foi informado.", "Verifique o campo de Nr. ART.")
	ElseIF Empty(cSerART)
		lRet:=.F.
		//Help('',1,"05A03REC","","T�cnico ainda n�o foi informado.",1,0)
		U_MsgHelp(,"S�rie ART. ainda n�o foi informado.", "Verifique o campo de S�rie ART.")
	ElseIF nNumero < 1
		lRet:=.F.
		//Help('',1,"05A03REC","","Nr. Receita (Inicio ou Final) precisa ser maior que zero.",1,0)
		U_MsgHelp(,"Nr. Receita (Inicio ou Final) precisa ser maior que zero.", "Verifique o campo Receita Inicial ou Receita Final.")
	Else
		dbSelectArea("ZB2")
		ZB2->(dbSetOrder(3))
		ZB2->(dbGoTop())
		If ZB2->(dbSeek(xFilial("ZB2")+cTecno))
			While !ZB2->(EOF()) .AND. ZB2->ZB2_TECNIC == cTecno .AND. ZB2->ZB2_NUMART == cNumART .AND. ZB2->ZB2_SERIE == cSerART
				If ((nNumero >= ZB2->ZB2_RECINI) .AND. (nNumero <= ZB2->ZB2_RECFIM)) 
					lRet:=.F.
					//Help('',1,"05A03REC","","Nr. do Receitu�rio j� foi utilizado em outro cadastro para o mesmo T�cnico.",1,0)
					U_MsgHelp(,"Nr. do Receitu�rio j� foi utilizado em outro cadastro para o mesmo T�cnico.", "Verifique o Cadastro de Autoriza��o de ART.")
					Exit
				EndIF
				ZB2->(dbSkip())
			EndDo
		EndIF
	EndIF

	RestArea(aArea)

Return lRet

//Fun��o para validar se pode excluir registro
User Function 05A03EXC()
	Local lRet:= .T.
	If(ZB2_RECINI <> ZB2_PRXREC)
		lRet:=.F.
		//MsgAlert("Autoriza��o de Receita j� foi utilizada. N�o � permitido realizar a exclus�o.","Exclus�o de Dados")
		U_MsgHelp(,"Autoriza��o de Receita j� foi utilizada.", "Exclus�o n�o permitido.")
	Else
		RecLock("ZB2",.F.) // Define que ser� realizada uma altera��o no registro posicionado
		DbDelete() // Efetua a exclus�o l�gica do registro posicionado.
		MsUnLock() // Confirma e finaliza a opera��o
	EndIf
Return lRet

User Function fVerifST()
LOCAL aInfo := {}
LOCAL lRet  := .T.
	fInfo(@aInfo,ZB2->ZB2_FILIAL)
	IF aInfo[6] == "MS"
		//IF EMPTY(M->ZB2_STRIN1)
		//	MsgAlert("� Obrigat�rio o preenchimento do campo ZB2_STRING1, pois ele comp�e a numera��o do Receituario, Verifique !!!","Alerta Usu�rio")
		//	lRet := .F.
		//ELSEIF EMPTY(M->ZB2_STRIN2)
		//	MsgInfo("� Obrigat�rio o preenchimento do campo ZB2_STRING2, pois ele comp�e a numera��o do Receituario, Verifique !!!","Alerta Usu�rio")
		//	lRet := .F.
		//ENDIF
	ENDIF

	IF aInfo[6] == "SP"
		//IF !EMPTY(M->ZB2_STRIN1)
		//	MsgAlert("Esse campo � utilizado somente na(s) Filial(is) do Estado Mato Grosso, Verifique !!!","Alerta Usu�rio")
		//	lRet := .F.
		//ELSEIF !EMPTY(M->ZB2_STRIN2)
		//	MsgAlert("Esse campo � utilizado somente na(s) Filial(is) do Estado Mato Grosso, Verifique !!!","Alerta Usu�rio")
		//	lRet := .F.
		//ENDIF
	ENDIF

Return(lRet)

