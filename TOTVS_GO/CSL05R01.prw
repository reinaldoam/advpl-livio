// #########################################################################################
// Projeto: Casul
// Modulo : Faturamento
// Fonte  : CSL05R01
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 13/05/19	| Ricardo Mendes    | Tela de Montagem de Impressão do Receituario Agronomico
// ---------+-------------------+-----------------------------------------------------------
#include 'protheus.ch'
#include 'parmtype.ch'

User function CSL05R01(nTipo, cNrNota, cSerie, cCliente, cLoja, cTecni, cFilNF )
	//Local aOpcao	:= {"1-FRENTE & VERSO", "2-SOMENTE FRENTE","3-SOMENTE VERSO"}
	//Local cOpcImpr	:= ""	 
	Local aParam	:={}
	//Local lFreVers	:= SuperGetmv("CS_FREVER",.f.,"N") == "S"
	Local cPerg		:= "CSL05R01"	
	Local cTmpFil	:= ""
	
	Local cFilAtua	:= cFilAnt 

	Default nTipo   := 2
	Default cFilNF := ""

	If nTipo == 1
		//Imprime a receita, pois a nota é a que está posicionada
		Aadd(aParam, nTipo 		)//Tipo
		Aadd(aParam, cNrNota	)//Numero da Nota
		Aadd(aParam, cSerie		)//Serie
		Aadd(aParam, cCliente	)//Cliente
		Aadd(aParam, cLoja		)//Loja
		Aadd(aParam, cTecni		)//Tecnico
		IF Empty(cFilNF)
			cTmpFil := AchaFil(cNrNota, cSerie,cCliente,cLoja,cTecni)
		Else
			cTmpFil := cFilNF
		EndIF
		IF Empty(cTmpFil)
			cTmpFil := cFilAnt
		EndIF
		Aadd(aParam, cTmpFil	)//Filial da Nota
	Else
		// Chama as perguntas para localizar a receita a partir da nota

		u_zAtuPerg(cPerg, "MV_PAR01", cNrNota)
		u_zAtuPerg(cPerg, "MV_PAR02", cSerie)
		u_zAtuPerg(cPerg, "MV_PAR03", cCliente)
		u_zAtuPerg(cPerg, "MV_PAR04", cLoja)
		u_zAtuPerg(cPerg, "MV_PAR05", cTecni)
		AjustaSX1(cPerg)
		If Pergunte(cPerg,.T.)
			Aadd(aParam, nTipo		)//Tipo
			Aadd(aParam, mv_par01	)//Numero da Nota
			Aadd(aParam, mv_par02	)//Serie
			Aadd(aParam, mv_par03	)//Cliente
			Aadd(aParam, mv_par04	)//Loja
			Aadd(aParam, mv_par05	)//Tecnico

			IF (Empty(mv_par01) .OR. Empty(mv_par02) .OR. Empty(mv_par03) .OR. Empty(mv_par04) .OR. Empty(mv_par05))
				//MsgAlert("Existe informações não preenchidas para impressão. Processo Cancelado","Atenção!")
				U_MsgHelp(,"Existe informações não preenchidas para impressão. Processo Cancelado.", "Verifique os campos informados.")
				Return .F.
			EndIF

			cTmpFil := AchaFil(mv_par01, mv_par02,mv_par03,mv_par04,mv_par05)
			IF Empty(cTmpFil)
				cTmpFil := cFilAnt
			EndIF
			Aadd(aParam, cTmpFil	)//Filial da Nota

		EndIf

	EndIf
	
	//Imprimir Relatorio em Laser - Descomente o código abaixo
	IF Len(aParam) > 0
		cFilAnt := aParam[7]
	
//		IF lFreVers
//			U_CSL05R02(aParam, "1")
//		Else
			//cOpcImpr:= U_InpComb("Opção de Impressão",aOpcao,0,.F.,1) //CH
			//IF Empty(cOpcImpr) //CH
				//MsgAlert("Opção não selecionada. Processo Cancelado","Atenção!")
				//U_MsgHelp(,"Opção não selecionada. Processo Cancelado.", "Verifique os campos informados.") //CH
			//Else //CH
				U_CSL05R02(aParam, 2 /*Substr(cOpcImpr, 1,1)*/) 
			//EndIF // CH
//		EndIF
//
		cFilAnt := cFilAtua

	EndIF

return .T.

//Monta as perguntas para o usuário
Static Function AjustaSX1(cPerg) //cNrNota, cSerie,cCliente,cLoja, cTecni, cFilNF
	aTam := TamSX3("F2_DOC")
	aHelpPor := {}
	aAdd(aHelpPor, "Nr. Nota Fiscal?")
	U_xPutSx1(cPerg,"01","Nr. Nota Fiscal ","","","mv_ch1",aTam[3],aTam[1],aTam[2],0,"G","","SF2TEC","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,{},{})

	aTam := TamSX3("F2_SERIE")
	aHelpPor := {}
	aAdd(aHelpPor, "Série da NF?")
	U_xPutSx1(cPerg,"02","Série da NF ","","","mv_ch2",aTam[3],aTam[1],aTam[2],0,"S","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,{},{})

	aTam := TamSX3("F2_CLIENTE")
	aHelpPor := {}
	aAdd(aHelpPor, "Cliente?")
	U_xPutSx1(cPerg,"03","Cliente ","","","mv_ch3",aTam[3],aTam[1],aTam[2],0,"S","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,{},{})

	aTam := TamSX3("F2_LOJA")
	aHelpPor := {}
	aAdd(aHelpPor, "Loja?")
	U_xPutSx1(cPerg,"04","Loja ","","","mv_ch4",aTam[3],aTam[1],aTam[2],0,"S","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,{},{})

	aTam := TamSX3("F2_XTECNIC")
	aHelpPor := {}
	aAdd(aHelpPor, "Técnico?")
	U_xPutSx1(cPerg,"05","Técnico ","","","mv_ch5",aTam[3],aTam[1],aTam[2],0,"S","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,{},{})

Return

//Função para achar a filial que está vinculada a nota e fazer a troca de filiais
Static Function AchaFil(cNrNota, cSerie,cCliente,cLoja,cTecnico)
	Local cRetFil	:= ""
	Local aRet		:= {}
	Local cQuery2 	:= ""
	Local lPorItem	:= SuperGetMV( "CS_PORITE",,"N" ) == "S"

	If lPorItem
		cQuery2:="select ZB6_TECNIC, ZB6_NMTECN, ZB6_RECEIT, ZB6_NUMART, ZB6_SERART, ZB6_NTFISC, ZB6_SERNTA, ZB6_CLIENT, ZB6_LOJA, ZB6_ROTINA   "
		cQuery2+="from "+RetSqlName("ZB6")+" ZB6 "
		cQuery2+="where "+ RetSqlCond("ZB6") + " AND ZB6.D_E_L_E_T_ <> '*'"
	//  cQuery2+=" AND ZB6_XFILUS = '    '"
		cQuery2+=" AND ZB6_XFILUS = '"+xFilial('ZB6')+"'"
		cQuery2+=" AND ZB6_NTFISC = '"+cNrNota+"'"
		cQuery2+=" AND ZB6_SERNTA = '"+cSerie+"'"
		cQuery2+=" AND ZB6_CLIENT = '"+cCliente+"'"
		cQuery2+=" AND ZB6_LOJA   = '"+cLoja+"'"
		cQuery2+=" AND ZB6_NTEXCL != 'S' "
	Else
		//Criar os campos de itens
		cQuery2:="select F2_FILIAL "
		cQuery2+="from "+RetSqlName("SF2")+" SF2 "
		cQuery2+="where SF2.D_E_L_E_T_ = ' ' "
		cQuery2+=" AND F2_DOC 		= '"+cNrNota+"' "
		cQuery2+=" AND F2_SERIE		= '"+cSerie+"' "
		cQuery2+=" AND F2_CLIENTE 	= '"+cCliente+"' "
		cQuery2+=" AND F2_LOJA 		= '"+cLoja+"' "
		cQuery2+=" AND F2_XRECEIT  != ' ' "
	EndIf
	//MemoWrite("C:\TEMP\BuscSld.sql",cQuery)
	aRet	:= U_CSL00G01(cQuery2)

	IF Len(aRet) > 0
		cRetFil := aRet[1,1]
	EndIF

Return cRetFil


// -------------------------------------------------------------------------------
/*/{Protheus.doc} zAtuPerg
// Permite designar um novo valor a Variavel da Pergunta (MV_PAR),
// 
@author Chandrer
@since 05/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cPergAux, characters, descricao
@param cParAux, characters, descricao
@param xConteud, , descricao
@type function
/*/
User Function zAtuPerg(cPergAux, cParAux, xConteud)
    Local aArea      := GetArea()
    //Local nPosCont   := 8
    Local nPosPar    := 14
    Local nLinEncont := 0
    Local aPergAux   := {}
    Default xConteud := ''
     
    //Se não tiver pergunta, ou não tiver ordem
    If Empty(cPergAux) .Or. Empty(cParAux)
        Return
    EndIf
     
    //Chama a pergunta em memória
    Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
     
    //Procura a posição do MV_PAR
    nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })
     
    //Se encontrou o parâmetro
    If nLinEncont > 0
        //Caracter
        If ValType(xConteud) == 'C'
            &(cParAux+" := '"+xConteud+"'")
         
        //Data
        ElseIf ValType(xConteud) == 'D'
            &(cParAux+" := sToD('"+dToS(xConteud)+")'")
             
        //Numérico ou Lógico
        ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
            &(cParAux+" := "+cValToChar(xConteud)+"")
        EndIf
         
        //Chama a rotina para salvar os parâmetros
        __SaveParam(cPergAux, aPergAux)
    EndIf
    RestArea(aArea)
Return
