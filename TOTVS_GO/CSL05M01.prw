// #########################################################################################
// Projeto: Casul
// Modulo : Faturamento
// Fonte  : CSL05M01
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor				| Descricao
// ---------+-------------------+-----------------------------------------------------------
// 24/05/19 | Ricardo Mendes 	| Exporta��o de Registros Integra��o Crea-SP
// ---------+-------------------+-----------------------------------------------------------
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include 'parmtype.ch'
#Include "TOPCONN.CH"
#include "fileio.ch"

user function CSL05M01()
	Private nMeter
	Private oMeter
	Private nTotal 		:= 0	
	Private cEdtSaida	:= SuperGetMV("SC_SENDIR",,fdesktop())
	Private lProcOK		:= .F.
	Private lkCREA		:= .T.
	Private cEdArtIni	:= space(TamSX3("ZB3_NUMART")[1])
	Private cEdArtFIM	:= space(TamSX3("ZB3_NUMART")[1])

	IF Len(cEdtSaida) < 130
		cEdtSaida:= cEdtSaida + Space(Len(cEdtSaida)- 130)
	EndIF	

	SetPrvt("oJanArq","oGpConf","EdtSaida","EdARTIni","EdARTFim","oBtnFile","oGpCheck","ckCREA","oGpProc","oGpMsg")
	SetPrvt("btnGerar","btnSair")

	oJanArq		:= MSDialog():New( 092,232,590,890,"Rotina de Processamento Protheus x CREA-SP",,,.F.,,,,,,.T.,,,.T. )
	oGpConf		:= TGroup():New( 000,004,030,328," Configura��es Gerais",oJanArq,CLR_BLACK,CLR_WHITE,.T.,.F. )
	EdtSaida	:= TGet():New( 008,008,{|u| If(PCount()>0,cEdtSaida:=u,cEdtSaida)}	,oGpConf,220,008,'@!'	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""		,"cEdtSaida"	,,,,,, .T. ,"Diretorio Saida:"	, 1 )
	EdARTIni	:= TGet():New( 008,246,{|u| If(PCount()>0,cEdArtIni:=u,cEdArtIni)}	,oGpConf,040,008,''		,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"ZB2ART"	,"cEdArtIni"	,,,,,, .T. ,"ART Inicial:"		, 1 )
	EdARTFim	:= TGet():New( 008,286,{|u| If(PCount()>0,cEdArtFIM:=u,cEdArtFIM)}	,oGpConf,040,008,''		,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"ZB2ART"	,"cEdArtFIM"	,,,,,, .T. ,"ART Final:"		, 1 )
	oBtnFile	:= TButton():New( 015,228,"...",oGpConf,{||cEdtSaida:= CapDiret() },015,010,,,,.T.,,"",,,,.F. )
	EdtSaida:Disable()

	oGpCheck	:= TGroup():New( 032,004,052,328," Arquivos Disponiveis ",oJanArq,CLR_BLACK,CLR_WHITE,.T.,.F. )
	ckCREA		:= TCheckBox():New( 041,008,"Importa��o CREA-SP",{|u| If(PCount()>0,lkCREA:=u,lkCREA)},oGpCheck,100,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

	oGpProc		:= TGroup():New( 054,004,078,272," Status de Processamento ",oJanArq,CLR_BLACK,CLR_WHITE,.T.,.F. )

	nMeter		:= 0
	nTotal		:= 0
	oMeter		:= TMeter():New(063,008,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oGpProc,260,13, /*[ uParam8]*/,.T.,/*[ uParam10]*/, /*[ uParam11]*/,.T., /*[ nClrPane]*/, /*[ uParam14]*/, /*[ uParam15]*/, /*[ uParam16]*/, /*[ uParam17]*/, /*[ uParam18]*/ )	
	oMeter:setFastMode(.F.)
	oMeter:lPercentage := .T.

	oGpMsg		:= TGroup():New( 080,004,224,328," Resumo de Processamento ",oJanArq,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oLstMsg		:= TListBox():New( 088,008,,,316,132,,oGpMsg,,CLR_BLACK,CLR_WHITE,.T.,,,,"",,,,,,, )

	btnGerar	:= TButton():New( 056,273,"&Processar"	,oJanArq,{|| VldProce() }	,054,021,,,,.T.,,"",,,,.F. )
	btnSair		:= TButton():New( 225,004,"&Sair"		,oJanArq,{|| VldSaid() }	,324,020,,,,.T.,,"",,,,.F. )

	nMeter		:= 0
	nTotal		:= 0
	oMeter:Set(0) // Atualiza Gauge/Tmeter	

	oJanArq:lEscClose	:= .F. //Nao permite sair ao se pressionar a tecla ESC.
	oJanArq:lCentered	:= .T.
	oJanArq:Activate(,,,.T.)

Return .T.

//Fun��o para validar se pode fechar a tela caso esteja em processamento
Static Function VldSaid()
	IF !lProcOK
		oJanArq:End()
	EndIF
Return .T.

//Fun��o para Validar Antes de iniciar o processamento
Static Function VldProce()
	Local lRetProc	:= .T.

	oLstMsg:Reset()
	oLstMsg:Refresh()
	oGpMsg:Refresh()
	nMeter		:= 0
	nTotal		:= 0
	oMeter:Set(0) // Atualiza Gauge/Tmeter	

	AddList("Iniciando processo de montagem de arquivos.")

	IF Empty(cEdArtIni) .AND. lRetProc
		lRetProc	:= .F.
		AddList("ERRO:: Nr. ART Inicial n�o foi informado.")
	EndIF

	IF Empty(cEdArtFIM) .AND. lRetProc
		lRetProc	:= .F.
		AddList("ERRO:: Nr. ART Final n�o foi informado.")
	EndIF

	IF Empty(cEdtSaida) .AND. lRetProc
		lRetProc	:= .F.
		AddList("ERRO:: Local do diret�rio de saida dos arquivos n�o informado.")
	EndIF

	IF (!lkCREA) .AND. lRetProc
		lRetProc	:= .F.
		AddList("ERRO:: Nenhuma op��o de processamento foi informado.")
	EndIF

	IF lRetProc
		ProcArq()
	EndIF

	AddList("Finalizando processo de montagem de arquivos.")
	AddList("Processo finalizado!!!!")

Return .T.

//Fun��o para Adicionar Linha no ListBox
Static Function AddList(cTexto)
	Local cPreTxt:= cValToChar(Date()) + " " + Time()+ " ---> "
	oLstMsg:Add(cPreTxt+cTexto)
	oLstMsg:Refresh()
	oGpMsg:Refresh()
Return .T.

//Fun��o para captura do diretorio
Static Function CapDiret()
	Local cDirRet:= AllTrim(cGetFile( '*.*' , 'Arquivos', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )) 

	IF Len(cDirRet) > 130 
		cDirRet:= ""
		Help('',1,"CapDiret","","Tamanho do caminho do relat�rio � maior do que o permitido (Tamanho M�ximo: 130).",1,0)
	EndIF

Return cDirRet

//Fun��o para processar a gera��o dos arquivos
Static Function ProcArq()
	Local cNomeArq	:= ""
	Local aReg		:= {}
	Local nFaz		:= 0

	MakeDir(cEdtSaida)

	//Gerar processamento de arquivo de Aquisi��o de Produ��o - S-1250
	IF lkCREA
		oMeter:Set(0) // Atualiza Gauge/Tmeter	
		aReg 		:= PesqART(cEdArtIni, cEdArtFIM)

		IF Len(aReg) = 0
			lProcOK := .F.
			AddList("ERRO:: N�o existe registro para gerar a estrutura ART/Receita para o periodo.")
		Else
			DbSelectArea("ZB2")
			ZB2->(DbSetOrder(1))

			lProcOK:= .T.
			For nFaz:=1 to Len(aReg)
				cNomeArq	:= Alltrim(aReg[nFaz,1]) +".txt"
				IF FILE(cEdtSaida+cNomeArq) 
					FERASE(cEdtSaida+cNomeArq)
				EndIF

				CreaSP(cNomeArq, aReg[nFaz] )

				ZB2->(dbGoto(aReg[nFaz,4]))
				RecLock("ZB2",.F.)
				ZB2->ZB2_INTEGR	:= 'S'
				ZB2->(MsUnlock())

			Next nFaz
			lProcOK := .F.

		EndIF
	EndIF

Return .T.

//Fun��o para gerar o arquivo referente ao S1250
Static Function CreaSP(cNomeArq, aReg)
	Local nFaz		:= 0
	local nHandle	:= 0
	Local cMsgBx	:= ""
	Local cCabArq	:= "#Numero de Ordem#Contratante#Telefone#CPF/CNPJ#Logradouro#Numero#CEP#Valor Contrato#Inicio#Termino#"
	Local cNUMART	:= aReg[1]
	Local cSERIE	:= aReg[2]
	Local cTECNIC	:= aReg[3]  
	Local aRegART	:= PsqRecNF(cNUMART,cSERIE, cTECNIC )

	Local cTeleRec	:= ""
	Local cNomeRec	:= ""
	Local cCNPJRec	:= ""
	Local cEndeRec	:= ""
	Local cCepRec	:= ""
	Local nVlrRec	:= 0
	Local dDataIni	
	Local dDataFim	
	Local dDataExc	
	Local cNotaExc	:= "N"

	IF Len(aRegART) > 0

		nHandle	:= FCREATE(cEdtSaida+cNomeArq, FC_NORMAL)
		AddList("ARQUIVO:: Iniciando Gera��o de Exporta��o CREA-SP -> ART Nr. "+cNUMART)

		IF nHandle = -1
			AddList("ERRO:: N�o foi possivel criar arquivo ("+cNomeArq+") " + Str(Ferror()))
		else

			nTotal:= Len(aRegART)
			oMeter:SetTotal(nTotal)
			oMeter:Set(0) // Atualiza Gauge/Tmeter	

			For nFaz:=1 to nTotal
				oMeter:Set(nFaz)

				IF Empty(aRegART[nFaz,9])
					cNotaExc := "N"
				Else
					cNotaExc := aRegART[nFaz,9]
				EndIF

				IF nFaz == 1
					IF !GeraLog(nHandle, cCabArq+CHR(13)+CHR(10))
						break
					EndIF
				EndIF

				IF Len(aRegART[nFaz]) > 9 .AND. cNotaExc == "S"
					IF Empty(StrTran(cValToChar(aRegART[nFaz,10]),"/",""))
						dDataExc := FirstDate(dDataBase)
					Else
						dDataExc := STOD(aRegART[nFaz,10])
					EndIF
				Else
					dDataExc := FirstDate(dDataBase)
				EndIF

				cNomeRec := IIF(cNotaExc == "S"	,Alltrim(SM0->M0_NOMECOM) 			,Alltrim(aRegART[nFaz,02]) 				) 
				cTeleRec := IIF(cNotaExc == "S"	,Alltrim(SoNumero(SM0->M0_TEL)) 	,Alltrim(SoNumero(aRegART[nFaz,03])) 	)
				cCNPJRec := IIF(cNotaExc == "S"	,Alltrim(SoNumero(SM0->M0_CGC)) 	,Alltrim(SoNumero(aRegART[nFaz,04]))	)
				cEndeRec := IIF(cNotaExc == "S"	,Alltrim(SM0->M0_ENDCOB) 			,Alltrim(aRegART[nFaz,05])				)	
				cCepRec	 := IIF(cNotaExc == "S"	,Alltrim(SoNumero(SM0->M0_CEPCOB)) 	,Alltrim(SoNumero(aRegART[nFaz,06]))	)	
				nVlrRec	 := IIF(cNotaExc == "S"	,0.01 								,aRegART[nFaz,07]						)	
				dDataIni := IIF(cNotaExc == "S"	,dDataExc							,STOD(aRegART[nFaz,08])					)
				dDataFim := IIF(cNotaExc == "S"	,LastDay(dDataExc)					,LastDay(STOD(aRegART[nFaz,08]))		)

				cTeleRec := IIF(Empty(cTeleRec)	, Alltrim(SoNumero(SM0->M0_TEL))	, cTeleRec)
				cCepRec	 := IIF(Empty(cCepRec)	, Alltrim(SoNumero(SM0->M0_CEPCOB))	, cCepRec) 
				cNomeRec := Alltrim(FwCutOff(FwNoAccent(cNomeRec), .F.))
				cEndeRec := Alltrim(FwCutOff(FwNoAccent(StrTran(cEndeRec,",S/N","")), .F.))

				cMsgBx:= "#"+Alltrim(cValToChar(aRegART[nFaz,01])) 			//Numero de Ordem (Codigo da Receita
				cMsgBx+= "#"+cNomeRec										//Contratante (Nome do Cliente)
				cMsgBx+= "#"+cTeleRec										//Telefone
				cMsgBx+= "#"+cCNPJRec										//CPF/CNPJ
				cMsgBx+= "#"+cEndeRec										//Logradouro
				cMsgBx+= "#"+"S/N"											//Numero
				cMsgBx+= "#"+cCepRec										//CEP
				cMsgBx+= "#"+Alltrim(transform(nVlrRec,"@E 999999999.99"))	//Valor Contrato
				cMsgBx+= "#"+cValToChar(dDataIni)							//Inicio
				cMsgBx+= "#"+cValToChar(dDataFim)							//Termino
				cMsgBx+= "#"

				IF !GeraLog(nHandle, cMsgBx+IIF(nFaz==nTotal,"",CHR(13)+CHR(10)))
					break
				EndIF

			Next nFaz

		EndIF
		FClose(nHandle)
		AddList("ARQUIVO:: Finalizando Exporta��o CREA-SP -> ART Nr. "+cNUMART)

	EndIF

Return .T.

//Fun��o para Retornar a Data no formato (DD/MM/YYYY)
Static Function FormData(cData, lTira)
	Local cNovData:= cValToChar(GravaData(DATE(),.T.,5))
	default lTira := .F.

	If ValType(cData) == "D"
		IF !Empty(cValtoChar(cData))
			cNovData := SubStr(cValtoChar(cData),7,2)+"/"+SubStr(cValtoChar(cData),5,2)+"/"+SubStr(cValtoChar(cData),1,4)
		EndIf
	ElseIF ValType(cData) == "C"
		IF !Empty(cData)
			cNovData := SubStr(cData,7,2)+"/"+SubStr(cData,5,2)+"/"+SubStr(cData,1,4)
		EndIf
	EndIF

	IF lTira
		cNovData := StrTran(cNovData,"/","")
	EndIF

Return cNovData


//Fun��o para gerar o Log
Static Function GeraLog(nTmpHDL, cMsgBx)
	Local lRet		:= .T.

	If fWrite(nTmpHDL,cMsgBx,Len(cMsgBx)) != Len(cMsgBx)
		lRet:= .F.
		AddList("ERRO:: Ocorreu um erro na gravacao do arquivo.")
	Endif

Return lRet

//Fun��o somente numeros
//cTexto	-> Texto que ser� passado pela fun��o
//cChar		-> Caracter que ser� ignorado na remo��o
Static function SoNumero(cTexto, cChar)
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

//Fun��o para trazer todas as notas de entradas do periodo
Static Function PesqART(cTmpIni, cTmpFim)
	Local aRetART	:= {}
	Local cQuery	:= ""

	cQuery := "SELECT ZB2_NUMART, ZB2_SERIE, ZB2_TECNIC, ZB2.R_E_C_N_O_ "
	cQuery += "FROM "+ retsqlname("ZB2")+" ZB2 "
	cQuery += "WHERE ZB2.D_E_L_E_T_ = ' ' " 
	cQuery += "AND ZB2_INTEGR != 'S' AND ZB2_FINAL = 'S'  "
	cQuery += "AND ZB2_NUMART BETWEEN '"+cTmpIni+"' AND '"+cTmpFim+"' "
	cQuery += "ORDER BY ZB2_NUMART, ZB2_SERIE, ZB2_TECNIC "

	//	MemoWrite("C:\TEMP\PesqART.sql",cQuery)
	aRetART := ArrayQry(cQuery)

Return aRetART

//Fun��o para retornar o valor das notas j� com as devolu��es
Static Function PsqRecNF(cNUMART,cSERIE, cTECNIC )
	Local aNotas	:= {}
	Local cQuery	:= ""

	DbSelectArea("ZB3")

	cQuery := "SELECT ZB3_RECEIT, A1_NOME, A1_TEL, A1_CGC, A1_END, A1_CEP,"
	cQuery += " (SELECT SUM(D2_TOTAL) "
	cQuery += "	      FROM "+ retsqlname("SD2")+" SD2 "
	cQuery += "	      WHERE SD2.D_E_L_E_T_	= ' ' "
	cQuery += "	      AND D2_DOC			= ZB3_NTFISC " 
	cQuery += "       AND D2_SERIE 			= ZB3_SERNTA "
	cQuery += "       AND D2_CLIENTE		= ZB3_CLIENT "
	cQuery += "       AND D2_LOJA			= ZB3_LOJA "
	cQuery += "       AND D2_XCULTUR 	   != ' ' "
	cQuery += "       AND D2_XDIAGNO 	   != ' ' "
	cQuery += "       AND D2_XEQUIPO 	   != ' ' "
	cQuery += " )VALOR , F2_EMISSAO, ZB3_NTEXCL "
	IF ZB3->(FieldPos("ZB3_DTEXCL"))> 0 
		cQuery += ", ZB3_DTEXCL	"
	EndIF
	cQuery += "FROM "+ retsqlname("ZB3")+" ZB3 "
	cQuery += "INNER JOIN "+ retsqlname("SA1")+" SA1 ON SA1.D_E_L_E_T_ = ' ' "
	cQuery += "       AND A1_COD			= ZB3_CLIENT "
	cQuery += "       AND A1_LOJA			= ZB3_LOJA "
	cQuery += "LEFT JOIN "+ retsqlname("SF2")+" SF2 ON SF2.D_E_L_E_T_ = ' ' ""
	cQuery += "	      AND F2_DOC			= ZB3_NTFISC " 
	cQuery += "       AND F2_SERIE	 		= ZB3_SERNTA "
	cQuery += "       AND F2_CLIENTE		= ZB3_CLIENT "
	cQuery += "       AND F2_LOJA			= ZB3_LOJA "
	cQuery += "WHERE ZB3.D_E_L_E_T_ = ' ' "
	cQuery += "AND ZB3_NUMART = '"+cNUMART+"' "
	cQuery += "AND ZB3_SERART = '"+cSERIE+"' " 
	cQuery += "AND ZB3_TECNIC = '"+cTECNIC+"' "
	cQuery += "ORDER BY ZB3_RECEIT "

	//MemoWrite("C:\TEMP\PsqRecNF.sql",cQuery)
	aNotas := ArrayQry(cQuery)

Return aNotas

Static function fdesktop()
	Local cTemp := GetTempPath() //capturo a pasta tempor�ria do usuario

	//Utilizarei a fun��o AT para pegar a posi��o onde come�a o texto \AppData
	//irei usar a fun��o substring para pegar da 1� posi��o at� a posi��o do texto
	//informado na fun��o AT
	Local cRaiz := substr(cTemp,1,AT("\AppData",cTemp))

	//Agora incluo a pasta desktop ou qualquer outra que esteja na mesma raiz
	Local cDesktop := cRaiz + "desktop\"

Return cDesktop


//Fun��o para retornar um array a partir de uma query
Static Function ArrayQry(cQuery)

	Local aRet001    := {}
	Local aRet1   := {}
	Local nRegAtu := 0
	Local x       := 0

	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "_TRB"

	dbSelectArea("_TRB")
	aRet1   := Array(Fcount())
	nRegAtu := 1

	While !Eof()

		For x:=1 To Fcount()
			aRet1[x] := FieldGet(x)
		Next
		Aadd(aRet001,aclone(aRet1))

		dbSkip()
		nRegAtu += 1
	Enddo

	dbSelectArea("_TRB")
	_TRB->(DbCloseArea())

Return(aRet001)

user function CSL05MART()
	PesqZB2()
Return .T.

Static Function PesqZB2()

	Local cConsSQL	:= ""//Consulta SQL
	Local cRetorM	:= "ZB2_NUMART"//Campo que ser� retornado
	Local cAgrupM	:= ""//Group By do SQL
	Local cOrderM	:= "ZB2_NUMART, ZB2_SERIE, ZB2_TECNIC"//Order By do SQL
	Local lOK		:= .F.

	cConsSQL := "SELECT ZB2_NUMART, ZB2_SERIE, ZB2_TECNIC "
	cConsSQL += "FROM "+ retsqlname("ZB2")+" ZB2 "
	cConsSQL += "WHERE ZB2.D_E_L_E_T_ = ' ' " 
	cConsSQL += "AND ZB2_INTEGR != 'S' AND ZB2_FINAL = 'S'  "

	lOK := U_zConsSQL(cConsSQL, cRetorM, cAgrupM, cOrderM)

	IF !lOK
		MsgAlert("<b>Consulta Cancelada!</b><br>A Consulta n�o retornou valores selecionado<b>'", "Aten��o")
		__cRetorno := ""
	EndIF

return .T.