// #########################################################################################
// Projeto: Casul
// Modulo : Faturamento
// Fonte  : CSL05R02
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao 
// ---------+-------------------------------------------------------------------------------
// 13/05/19	| Ricardo Mendes    | Impress�o do Receituario Agronomico
// 09/12/19 | Chandrer Silva    | Atualizacao com Personalizacoes
// 03/03/20 | Chandrer          |- Atualizacao referente a impressao do receituario agronomico
//          |                   |trazendo a Data da NF e nao mais a database.
// ----------+------------------------+----------------------------------------------------- 
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function CSL05R02(aParam/*, cTpImp*/)
  //aParam[1] - Tipo
  //aParam[2] - Numero da Nota
  //aParam[3] - Serie
  //aParam[4] - Cliente
  //aParam[5] - Loja
  //aParam[6] - Tecnico
  //aParam[7] - Filial
  //cFonte := "Courier New"
  cFonte := "Arial"
  Private oFont0 	 := TFont():New( cFonte,,10,,.F.,,,,,.F. ) // 07
  Private oFont06  := TFont():New( cFonte,,06,,.F.,,,,,.F. ) // 09 N
  Private oFont08  := TFont():New( cFonte,,10,,.F.,,,,,.F. ) // 09 N
  Private oFont09  := TFont():New( cFonte,,09,,.F.,,,,,.F. ) // 09 N
  Private oFont2 	 := TFont():New( cFonte,,12,,.F.,,,,,.F. ) // 08
  Private oFont2N  := TFont():New( cFonte,,12,,.T.,,,,,.F. ) // 10 N
  Private oFont3N  := TFont():New( cFonte,,14,,.T.,,,,,.F. ) // 14 N
  Private oFont4N  := TFont():New( cFonte,,20,,.T.,,,,,.F. ) // 20 N
  Private oFont10	 := TFont():New( cFonte,,10,,.F.,,,,,.F. ) // 06 I
  Private oFont10N := TFont():New( cFonte,,10,,.T.,,,,,.F. ) // 06 IN
	
  // Variaveis para gerenciar a cria��o do PDF
  Private lAdjustToLegacy := .F.
  Private lDisableSetup   := .T.
  Private cDirPrint	      := SuperGetmv("CS_DRTREC",.f.,"C:\TEMP\RECEITA\"/*GetTempPath(.F.)*/)
  Private cHoraAtu	      := StrTran(TIME(),":","")
  Private cTmpNome	      := SuperGetmv("CS_NOMREC",.f.,"RecAgro_"+StrTran(cValToChar(dDatabase),"/","") )
  Private cFileOP		  := cTmpNome+"_"+cHoraAtu+".pdf"
  Private cIRAgr          := SuperGetMV("MV_X_IRAGR")		// Imagem do Verso do Receituario.
  Private cCFRAG          := SuperGetMV("MV_X_CFRAG")		// Os CFOP's inclusos nesse parametro nao irao Emitir Receituario Agronomico. (Solicitacao em 03/03/2020 email)
  Private lPorItem	      := SuperGetMV("CS_PORITE",,"N" ) == "S"
	
  Private aReceita := BscDados(aParam)
  Private oReport	
	
  If Len(aReceita) > 0
     MontaDir(cDirPrint)
		
	 lAdjustToLegacy := .F.
	 lDisableSetup := .T.
	 oReport := FWMSPrinter():New(cFileOP,IMP_PDF, lAdjustToLegacy,cDirPrint, .t.,,,,.t.)// Ordem obrig�toria de configura��o do relat�rio.
	 oReport:cPathPDF := cDirPrint
		
	 Processa({|| ProDados(oReport/*, cTpImp*/) },"Imprimindo...")
	 // Visualiza a impress�o
	 oReport:EndPage()
	 Processa({||oReport:Preview()},"Gerando Visualiza��o Receita...")
	 oReport := Nil
	 oSetupOP := Nil
  Else
     //MsgAlert("N�o foi encontrado registro com o filtro informado.")
	 U_MsgHelp(,"N�o foi encontrado registro com o filtro informado. Processo Cancelado.", "Verifique os campos informados.")
  EndIF
Return .T.

//Monta as estruturas e traz o relat�rio
Static Function ProDados(oReport/*, cTpImp*/)
  Local nFaz	:= 0
  Local aCabeca	:= {}
  Local aRodape	:= {}
  Local nTmpCli	:= TamSX3("A1_COD")[1]
  Local nTmpLoj	:= TamSX3("A1_LOJA")[1]

  Private nConta	:= 0 //Quantidade 

  oReport:SetResolution(78) //Tamanho estipulado para a Danfe
  oReport:SetPortrait()
  oReport:SetPaperSize(DMPAPER_A4)
  oReport:SetMargin(10,10,10,10)
  oReport:lServer  := .f.
  oReport:nDevice  := IMP_PDF
  oReport:cPathPDF := cDirPrint//oSetupBOL:aOptions[PD_VALUETYPE]
	
  For nFaz := 1 to Len(aReceita)
     aCabeca	:= {}
	 aRodape	:= {}
		
	 DbSelectArea("SA1")
	 DbSetOrder(1)
	 
	 If SA1->(DbSeek(xFilial("SA1")+Substr(aReceita[nFaz, 8],1,nTmpCli)+Substr(aReceita[nFaz, 9],1,nTmpLoj),.T.))
	    //Criar os campos de cabe�alho
		cString1 := ""
		cString2 := ""			
		//Order 2 - zb2_Filial + zb2_tecnic + zb2_numart + zb2_serie - Venda com Receituario Teste: 011978
		CodTec  := aReceita[nFaz, 1] //Cod.Tecnico 
		cReceit := aReceita[nFaz, 3] // No.Receituario
		
		DBSelectArea("ZB2")
		DBSetOrder(2)
		If DbSeek(XFilial("ZB2")+CodTec+aReceita[nFaz, 4])
		   //cString1 := Alltrim(ZB2->ZB2_STRIN1)
		   //cString2 := Alltrim(ZB2->ZB2_STRIN2)
		Endif 

		If !Empty(cString1) .AND. !empty(cString2)
		   cReceit := cString1+StrZero(cReceit,4)+cString2 //Atualizacao do array na montagem da Numeracao do Receitu�rio.	
		   aReceita[nFaz,3] := cReceit
		Else
		   aReceita[nFaz,3] := cReceit //StrZero(cReceit,4)
		Endif
   	    Aadd( aCabeca, cReceit ) //Nr. da Receita
		Aadd( aCabeca, ALLTRIM(aReceita[nFaz, 5] )) //Nr. da Serie da Receita
		Aadd( aCabeca, ALLTRIM(aReceita[nFaz, 4] )) //Nr. da ART
		Aadd( aCabeca, ALLTRIM(SA1->A1_NOME) ) //Nome do Cliente
		Aadd( aCabeca, ALLTRIM(SA1->A1_END) )  //Endere�o do Cliente
		Aadd( aCabeca, ALLTRIM(SA1->A1_MUN) + "/"+ ALLTRIM(SA1->A1_EST)	) //Cidade do Cliente
		Aadd( aCabeca, ALLTRIM(SA1->A1_NREDUZ) )   //Nome da Propriedade
		Aadd( aCabeca, ALLTRIM(aReceita[nFaz, 6] ))
		Aadd( aCabeca, ALLTRIM(aReceita[nFaz, 7] ))

		If ALLTRIM(SA1->A1_PESSOA) == "J"
		   aadd(aCabeca, TRANSFORM(ALLTRIM(SA1->A1_CGC),"@R 99.999.999/9999-99"))		//[01]CNPJ Formatado
		Else
		   aadd(aCabeca, TRANSFORM(ALLTRIM(SA1->A1_CGC),"@R 999.999.999-99"))			//[01]CPF Formatado
		EndIf
		Aadd( aCabeca, ALLTRIM(SA1->A1_INSCR) ) //Insc. Estadual do Cliente
			
	    cNumeroNF := aReceita[1,6] 
		cSerieNF  := aReceita[1,7]
		cLojaNF   := aReceita[1,9]
		cRotina   := "M460FIM" //aReceita[1,12]
        
		// Buscar o Numero da NF na tabela SD2 para trazer a Data da Emissao da NF no Receituario.
		dDataRCT = 	GetAdvFVal("SD2","D2_EMISSAO",xFilial("SD2")+cNumeroNF+cSerieNF+Alltrim(aReceita[1,8])+cLojaNF, 3)
		If Empty(dDataRCT)
		   dDataRCT := dDataBase
		Endif
        
		//Criar os campos de rodape
		Aadd( aRodape, ALLTRIM(aReceita[nFaz, 2] )) //Nome do Tecnico
		Aadd( aRodape, ALLTRIM(Posicione("ZB1",1,xFilial("ZB1")+aReceita[nFaz, 1],"ZB1_CREA")) ) //CREA
		Aadd( aRodape, ALLTRIM(Transform(Posicione("ZB1",1,xFilial("ZB1")+aReceita[nFaz, 1],"ZB1_CPF"), "@R 999.999.999-99" ))) //CIC
		Aadd( aRodape, ALLTRIM(Posicione("ZB1",1,xFilial("ZB1")+aReceita[nFaz, 1],"ZB1_ENDERE")) ) //Endere�o
		Aadd( aRodape, Alltrim(SM0->M0_CIDCOB)+", " + STRZERO(Day(dDataRCT), 2) + " de " + MesExtenso(dDataRCT) + " de " + StrZero(Year(dDataRCT), 4)  )
		Aadd( aRodape, ALLTRIM(SA1->A1_NOME) ) //Nome do Cliente
        
		//IF cTpImp == "1" // Imprimir Frente e Verso
		   //ImpFrent(.T., aCabeca, aRodape, aReceita[nFaz])
		//ElseIF cTpImp == "2" // Imprimir Somente Frente
		   ImpFrent(.T., aCabeca, aRodape, aReceita[nFaz])
		//ElseIF cTpImp == "3" // Imprimir Somente Verso
		   //ImpFrent(Nil, aCabeca, aRodape, aReceita[nFaz])
		   //ImpVerso(aCabeca, aRodape)
		//EndIF
		oReport:EndPage(.T.)
	 EndIF
  Next nFaz
Return(oReport)

//Fun��o para buscar dados da Receita Agron�nomica
Static Function BscDados(aConfigur)
  Local cQuery2:= ""
  Local aRet	:= {}
  
  If lPorItem
     //cQuery2+="ZB6_PRODUT, ZB6_ITEMPR, ZB6_ROTINA "
	 cQuery2 += "SELECT ZB6_TECNIC, ZB6_NMTECN, ZB6_RECEIT, ZB6_NUMART, ZB6_SERART, "
	 cQuery2 += "ZB6_NTFISC, ZB6_SERNTA, ZB6_CLIENT,ZB6_LOJA,ZB6_PRODUT, "
	 cQuery2 += "ZB6_ITEMPR, ZB6_ROTINA, ZB6_NAPLIC, ZB6_OBSERV "
	 cQuery2 += "FROM "+RetSqlName("ZB6")+" ZB6 "
	 cQuery2 += "WHERE "+ RetSqlCond("ZB6") + " AND ZB6.D_E_L_E_T_ <> '*'"
	 //cQuery2 +=" AND ZB6_XFILUS = '    '"
	 cQuery2 +=" AND ZB6_XFILUS = '"+aConfigur[7]+"'"
	 cQuery2 +=" AND ZB6_NTFISC = '"+aConfigur[2]+"'"
	 cQuery2 +=" AND ZB6_SERNTA = '"+aConfigur[3]+"'"
	 cQuery2 +=" AND ZB6_CLIENT = '"+aConfigur[4]+"'"
	 cQuery2 +=" AND ZB6_LOJA   = '"+aConfigur[5]+"'"
	 cQuery2 +=" AND ZB6_TECNIC = '"+aConfigur[6]+"'"
	 cQuery2 +=" AND ZB6_NTEXCL != 'S' "
  Else
     cQuery2 += "SELECT ZB3_TECNIC, ZB3_NMTECN, ZB3_RECEIT, ZB3_NUMART, ZB3_SERART, "
     cQuery2 += "ZB3_NTFISC, ZB3_SERNTA, ZB3_CLIENT, ZB3_LOJA, ZB3_ROTINA"
     cQuery2 += "FROM "+RetSqlName("ZB3")+" ZB3 "
     cQuery2 += "WHERE "+ RetSqlCond("ZB3") + " AND ZB3.D_E_L_E_T_ <> '*'"
     //cQuery2+=" AND ZB3_XFILUS = '    '"
     cQuery2+=" AND ZB3_XFILUS = '"+aConfigur[7]+"'"
     cQuery2+=" AND ZB3_NTFISC = '"+aConfigur[2]+"'"
     cQuery2+=" AND ZB3_SERNTA = '"+aConfigur[3]+"'"
     cQuery2+=" AND ZB3_CLIENT = '"+aConfigur[4]+"'"
     cQuery2+=" AND ZB3_LOJA   = '"+aConfigur[5]+"'"
     cQuery2+=" AND ZB3_TECNIC = '"+aConfigur[6]+"'"
     cQuery2+=" AND ZB3_NTEXCL != 'S' "
  EndIf
  //MemoWrite("C:\TEMP\BscDados.sql",cQuery2)
  aRet := U_CSL00G01(cQuery2)
Return aRet

//Fun��o para buscar os produtos que est�o vinculados a nota fiscal
Static Function BscItens(aDdRect)
  Local aRet	:= {}
  Local cQuery2 := ""
	
  //Criar os campos de itens
  cQuery2:="SELECT D2_COD, D2_XCULTUR, D2_QUANT, D2_XDIAGNO, D2_XEQUIPO "
  cQuery2+="FROM "+RetSqlName("SD2")+" SD2 "
  cQuery2+="WHERE "+ RetSqlCond("SD2")  + " AND SD2.D_E_L_E_T_ <> '*'"
  cQuery2+=" AND D2_DOC 	   = '"+aDdRect[6]+"' "
  cQuery2+=" AND D2_SERIE	   = '"+aDdRect[7]+"' "
  cQuery2+=" AND D2_CLIENTE  = '"+aDdRect[8]+"' "
  cQuery2+=" AND D2_LOJA 	   = '"+aDdRect[9]+"' "
  cQuery2+=" AND D2_XCULTUR != ' ' "

  If lPorItem	
    cQuery2+=" AND D2_COD  = '"+aDdRect[10]+"' " //Produto
    cQuery2+=" AND D2_ITEM = '"+aDdRect[11]+"' " //Item
  EndIf
  cQuery2+=" ORDER BY D2_ITEM"
  //MemoWrite("C:\TEMP\BuscSld.sql",cQuery)
  aRet	:= U_CSL00G01(cQuery2)
Return aRet

//Fun��o para Imprimir a Frente da Receita
Static Function ImpFrent(lImpTudo, aCabRec, aRodRec, aDados)
  LOCAL aItens	:= BscItens(aDados)
  LOCAL nFaz	 	:= 0
  LOCAL nConta	:= 1
  LOCAL lImp
  LOCAL cNAplc := aDados[13]
  LOCAL cIAdic := aDados[14]

  lImp 		:= .F.
	
  For nFaz := 1 to Len(aItens)
     //nConta := nConta + 1
	 //Do Case				: Foi comentado tambem, pois agora pra cada Pagina e' um Receituario Novo.
	 //	Case nConta = 1     :
	 If lImpTudo = .T.
	    ImpCab(aCabRec)
		//ImpItem(nConta, aItens[nFaz,1], aItens[nFaz,2], aItens[nFaz,3], aItens[nFaz,4], aItens[nFaz,5] )
		ImpItem(nConta, aItens[nFaz,1], aItens[nFaz,2], aItens[nFaz,3], aItens[nFaz,4], aItens[nFaz,5], cNAplc, cIAdic )
		ImpRod(aRodRec,"1a.Via Usu�rio")
		ImpCab(aCabRec)
		ImpItem(nConta, aItens[nFaz,1], aItens[nFaz,2], aItens[nFaz,3], aItens[nFaz,4], aItens[nFaz,5], cNAplc, cIAdic )
		ImpRod(aRodRec,"2a.Via Arquivo Estabelecimento")
  	    //ImpVerso(aCabRec, aRodRec)
		//	lImp:= .T.
	 Endif
     // Trecho a seguir removido porque foi unificado o Verso do Receituario na frente;
	 //If lImpTudo = .F. 
	 //	ImpCab(aCabRec)
	 //	//ImpItem(nConta, aItens[nFaz,1], aItens[nFaz,2], aItens[nFaz,3], aItens[nFaz,4], aItens[nFaz,5] )
	 //	ImpItem(nConta, aItens[nFaz,1], aItens[nFaz,2], aItens[nFaz,3], aItens[nFaz,4], aItens[nFaz,5], cNAplc, cIAdic )
	 //	ImpRod(aRodRec)
	 ////	lImp:= .T.
	 //Endif
	 //If lImpTudo = Nil 
	 //	//ImpCab(aCabRec)
	 //	//ImpItem(nConta, aItens[nFaz,1], aItens[nFaz,2], aItens[nFaz,3], aItens[nFaz,4], aItens[nFaz,5] )
	 //	//ImpItem(nConta, aItens[nFaz,1], aItens[nFaz,2], aItens[nFaz,3], aItens[nFaz,4], aItens[nFaz,5], cNAplc, cIAdic )
	 //	//ImpRod(aRodRec)
	 //	ImpVerso(aCabRec, aRodRec)
	 ////	lImp:= .T.
	 //EndIf
  Next nFaz
Return .T.

//Fun��o para Imprimir o Verso da Receita
//Static Function ImpVerso(aCabRec, aRodRec)
//	oReport:StartPage ()

//	ImpCab(aCabRec, .T.)
//	if !empty(cIRAgr)
//		oReport:SayBitmap( 20, 20, cIRAgr, 600, 800)
//	endif
	
/*
	oReport:Say(115,60,'INFORMA��ES COMPLEMENTARES - LEIA ATENTAMENTE ANTES DE INICIAR O MANUSEIO',oFont3N)
	oReport:Say(125,150,'PRECAU��ES DE USO E CUIDADOS COM O MEIO AMBIENTE',oFont3N)

	oReport:Say(140,15,'01 - Durante o preparo das caldas de agrot�xicos use sempre luvas  nitr�licas, um vez que 80% dos casos de  intoxica��es ocorrem',oFont2)  
	oReport:Say(150,15,'nesta fase. Use os  equipamentos de prote��o individual (EPI) recomendados toda vez que utilizar  agrot�xicos, tais como chap�u,',oFont2) 
	oReport:Say(160,15,'protetor facial, m�scaras,  luvas, roupa imperme�vel, botas de borracha (Portaria  MTB 3067 de 12/04/88).                       ',oFont2)
	oReport:Say(170,15,'02 - N�o fume, n�o coma e n�o beba durante o manuseio e aplica��o de agrot�xicos.                                               ',oFont2)
	oReport:Say(180,15,'03 - Nunca desentupa os bicos do pulverizador com a boca.                                                                       ',oFont2)
	oReport:Say(190,15,'04 - Verifique antes de iniciar a aplica��o se o equipamento est� em boas condi��es de uso, sem vazamento e bem calibrado.      ',oFont2)
	oReport:Say(200,15,'05 - N�o permita a presen�a de crian�as, animais e  pessoas estranhas ao trabalho nos locais de manuseio, preparo de caldas, la-',oFont2)
	oReport:Say(210,15,'vagem de equipamentos e EPIs e aplica��o de agrot�xicos, obedecendo o per�odo de reentrada.                                     ',oFont2)
	oReport:Say(220,15,'06 - Os agrot�xicos n�o devem ser aplicados por menores, pessoas de idade ou doentes e gestantes.                               ',oFont2)
	oReport:Say(230,15,'07 - N�o aplique agrot�xicos contra o vento, nem em dias de vento forte ou com tempo chuvoso. Evitar aplicar os produtos nas ho-',oFont2)
	oReport:Say(240,15,'ras mais quentes do dia, observando as recomenda��es t�cnicas.                                                                  ',oFont2)
	oReport:Say(250,15,'08 - Os agrot�xicos devem ser armazenados em dep�sitos fechados, exclusivos para este fim, com placa de aviso (PRODUTOS T�XICOS,',oFont2)
	oReport:Say(260,15,'CAVEIRA, PERIGO), impedindo o acesso a crian�as, pessoas desavisadas, animais dom�sticos, de cria��o ou silvestres, permanecendo',oFont2)
	oReport:Say(270,15,'as embalagens bem fechadas e com r�tulos originais.                                                                             ',oFont2)
	oReport:Say(280,15,'09 - N�o guarde ou transporte os agrot�xicos juntamente com alimentos, ra��es, bebidas, medicamentos e pessoas.                 ',oFont2)
	oReport:Say(290,15,'10 - Nunca abaste�a ou lave o pulverizador diretamente nas fontes de �gua. Use tanques ou reservat�rios especiais. �gua contami-',oFont2)
	oReport:Say(300,15,'nada mata peixes, crian�as, homens e animais. A lavagem dos equipamentos n�o deve comprometer o homem e o meio ambiente.        ',oFont2)
	oReport:Say(310,15,'11 - Respeite o per�odo de car�ncia (per�odo entre a �ltima aplica��o e colheita) indicado para cada produto.                   ',oFont2)
	oReport:Say(320,15,'12 - Tr�plice Lavagem,  formula��es l�quidas ou p� sol�veis  em �gua: para embalagens pl�sticas, vidro  ou metal,  imediatamente',oFont2) 
	oReport:Say(330,15,'ap�s o completo esvaziamento, devem ser enxuguadas 3(tr�s) vezes com agita��o, e as caldas resultantes vertidas no tanque do pul-',oFont2)
	oReport:Say(340,15,'verizador. Formula��es sem dilui��o em �gua devem ser totalmente  esgotadas no tanque do pulverizador e depois inutilizadas. N�o',oFont2)
	oReport:Say(350,15,'reutilize as embalagens vazias. As mesmas devem ser destu�das adequadamente, conforme indica��es espec�ficas.                   ',oFont2)
	oReport:Say(360,15,'13 - Disposi��o final de res�duos e embalagens n�o abandone embalagens em carreadores, caminhos, estradas, cercas, �reas de vege-',oFont2)
	oReport:Say(370,15,'ta��o arb�rea e principalmente nas  margens de quaisquer cole��es de �gua (rios, lagos, c�rregos, represas, etc).  As embalagens',oFont2)  
	oReport:Say(380,15,'tr�plice lavadas devem ser inutilizadas. Para o destino correto, cosulte o Governo Estadual e Municipal para conhecer a legisla-',oFont2)
	oReport:Say(390,15,'��o e os procedimentos corretos para sua regi�o. Nunca abandone embalagens na natureza.                                         ',oFont2)
	oReport:Say(400,15,'14 - Se o agrot�xico atingir alguma parte de seu corpo, lavea imediatamente com �gua fria e sab�o. Ap�s as aplica��es, tomar ba-',oFont2)
	oReport:Say(410,15,'nho com �gua fria e sab�o, trocando de roupa. Lavar a roupa utilizada durante a aplica��o.                                      ',oFont2)
	oReport:Say(420,15,'15 - Se durante a aplica��o sentir mal estar,  dor de cabe�a, v�mitos, tremores, tonturas, febres ou dificuldade de enxergar, ou',oFont2)
	oReport:Say(430,15,'em caso de acidentes, pare imediatamente o  servi�o e procure um m�dico, levando o receitu�rio agron�mico e a  bula ou r�tulo do',oFont2)
	oReport:Say(440,15,'agrot�xico.                                                                                                                     ',oFont2)
	oReport:Say(450,15,'16 - Para a aplica��o  de agrot�xicos e afins, o produtor  deve recorrer sempre � Assist�ncia T�cnica de Profissional Legalmente',oFont2)
	oReport:Say(460,15,'Habilitado.                                                                                                                     ',oFont2)
	oReport:Say(470,15,'17 - Os produtores, usu�rios, aplicadores,  meeiros e arrendat�rios que n�o se utilizarem da  Assist�ncia T�cnica, responsabili-',oFont2)
	oReport:Say(480,15,'zam-se pelos dados a que derem causa, solidariamente.                                                                           ',oFont2)  
	oReport:Say(490,15,'18 - Somente utilize o agrot�xico para cultura e problema recomendado.                                                          ',oFont2) 
	oReport:Say(500,15,'19 - Advert�ncias Relacionadas a Prote��o do Meio Ambiente:  N�o contamine manaciais de �gua, lavando equipamentos de pulveriza-',oFont2)
	oReport:Say(510,15,'��o ou embalagens vazias, nem lan�ando-lhes seus restos. Em caso de acidente, suspender o uso da  fonte de �gua para consumo hu-',oFont2)
	oReport:Say(520,15,'mano ou animal. Evite deriva que possa atingir a fauna silvestre ou animais dom�sticos.                                         ',oFont2) 
	oReport:Say(530,15,'O uso indevido e/ou aplica��o inadequada destes produtos pode resultar em graves danos � sa�de p�blica, ao meio ambiente e � in-',oFont2) 
	oReport:Say(540,15,'tegridade f�sica de usu�rios e consumidores em geral.                                                                           ',oFont2) 
	oReport:Say(550,15,'',oFont2)
	oReport:Say(560,15,'PRIMEIROS SOCORROS',oFont3N)
	oReport:Say(570,15,'01 - Caso ocorra um acidente,  quando da manipula��o do agrot�xico, leia e siga as instru�es do r�tulo, bula ou folheto explica-',oFont2) 
	oReport:Say(580,15,'tivo e procure um m�dico.                                                                                                       ',oFont2)
	oReport:Say(590,15,'02 - Caso sinta mal-estar (Dor de Cabe�a,  V�mitos, Diarr�ia, Suores ou Tonturas, Etc.).  Pare imediatamente o servi�o e procure',oFont2)
	oReport:Say(600,15,'um posto de sa�de levando o r�tulo, bula ou folheto explicativo do agrot�xico utilizado.                                        ',oFont2)
	oReport:Say(610,15,'',oFont2)
	oReport:Say(620,15,'AGRICULTOR: AGROT�XICO � VENENO',oFont3N)
	oReport:Say(630,15,'O uso de agrot�xicos fora das recomenda��es desta receita � da sua inteira responsabilidade. Qualquer d�vida, consulte o profis-',oFont2)
	oReport:Say(640,15,'sional respons�vel por esta recomenda��o.                                                                                       ',oFont2)
	oReport:Say(650,15,'',oFont2)
	oReport:Say(660,15,'INFORMA��ES �TEIS NO CASO DE INTOXICA��O:',oFont3N)
	oReport:Say(670,15,'Para atendimento 24 horas, o paciente com intoxica��o, precisa ser encaminhado para o seguinte endere�o:                        ',oFont2)
	oReport:Say(680,15,'Irmandade da Santa Casa de Miseric�rdia de Parapu� - R. Fortaleza, 725 - Centro - Telefone (18) 3582-1393                       ',oFont2)
	oReport:Say(690,15,'',oFont2)
	oReport:Say(700,15,'Vigil�ncia Sanit�ria Municipal de Parapu� - Rua Natal, n� 928 - Centro, Telefone: (18) 3582-1358 - Seg. a Sex. (07:00 as 17:00) ',oFont2)
	oReport:Say(710,15,'E-mail: vigilanciasanitariaparapua@hotmail.com                                                                                  ',oFont2)
*/
//	ImpRod(aRodRec, .T.)
// Return .T.

//Fun��o para Imprimir o Item
//Static Function ImpItem(nTpLinha, cProd, cCult, nQtde, cDiag, cEquip)
Static Function ImpItem(nTpLinha, cProd, cCult, nQtde, cDiag, cEquip, cNApl, cIAdic)
	Local cTmpAplc	:= ""
	Local nTmpAplc	:= 0 
	Local nTamProd	:= TamSX3("ZB0_PRODUT")[1]
	Local nTamCult	:= TamSX3("C6_XCULTUR")[1]
	Local nTamDiag	:= TamSX3("C6_XDIAGNO")[1]
	Local nTamEqui	:= TamSX3("C6_XEQUIPO")[1]
	// Verificar a funcionalidade...
	nTpLinha := 1
	cTmpAplc	:= ""
	nTmpAplc	:= 0 

	dbSelectArea("ZB0")
	ZB0->(dbSetOrder(1))
	If ZB0->(dbSeek(xFilial("ZB0")+Substr(cProd,1,nTamProd)+Substr(cCult,1,nTamCult)+Substr(cDiag,1,nTamDiag)+Substr(cEquip,1,nTamEqui)))

	   nTmpAplc:= Len(ALLTRIM(ZB0->ZB0_EPCAPL ))
	   cTmpAplc:= ALLTRIM(ZB0->ZB0_EPCAPL )
		
	   If empty(cNApl) 
	      cNApl  := ZB0->ZB0_NAPLIC 
	   EndIf
	   If empty(cIAdic)
	      cIAdic := ZB0->ZB0_OBSERV
	   EndIf
   	   oReport:Box(110,010,300,630)// box Identifica��o da Receita //49 espacos é o limite para a quebra de pagina:
	   oReport:Say(122,015, 'CULTURA...........: '+UPPER(ZB0->ZB0_NMCULT),oFont10) // oFont10N

	   oReport:Say(134,015, 'DIAGNOSTICO.......: '+SUBST(UPPER(ZB0->ZB0_NMDIAG),01,49),oFont10)
	   oReport:Say(146,015, '                    '+SUBST(UPPER(ZB0->ZB0_NMDIAG),50,70),oFont10)
			
	   oReport:Say(158,015, 'PRODUTO...........: '+SUBST(UPPER(ZB0->ZB0_NMPROD),01,49),oFont10)
	   oReport:Say(170,015, '                    '+SUBST(UPPER(ZB0->ZB0_NMPROD),50,80),oFont10)

	   oReport:Say(182,015, 'DOSAGEM...........: '+UPPER(ZB0->ZB0_DOSAGE),oFont10)

	   oReport:Say(194,015, 'INTERVALO APLICAC.: '+UPPER(ZB0->ZB0_CARENC),oFont10)

	   oReport:Say(206,015, 'PRINCIPIO ATIVO...: '+SUBSTR(UPPER(ZB0->ZB0_PRCATV),01,49),oFont10)
	   oReport:Say(218,015, '                      '+SUBSTR(UPPER(ZB0->ZB0_PRCATV),50,99),oFont10)

	   oReport:Say(230,015,'�POCA DE APLICA��O: '+SUBSTR(UPPER(ZB0->ZB0_EPCAPL),01,049),oFont10)
	   oReport:Say(242,015,'                    '+SUBSTR(UPPER(ZB0->ZB0_EPCAPL),50,049),oFont10)
	   oReport:Say(254,015,'                    '+SUBSTR(UPPER(ZB0->ZB0_EPCAPL),99,050),oFont10)

	   oReport:Say(268,015,'MODALIDADE APLICAC: '+SUBSTR(UPPER(ZB0->ZB0_NMEQUI),01,49),oFont10)
	   oReport:Say(280,015,'                    '+SUBSTR(UPPER(ZB0->ZB0_NMEQUI),50,70),oFont10)

   	   oReport:Say(292,015,'INTERVAL.SEGURANCA: '+UPPER(ZB0->ZB0_ISCONS),oFont10)

	   oReport:Say(122,374,'�REA A TRATAR..: '+UPPER(cValToChar(ZB0->ZB0_COBERT * nQtde))+" "+ALLTRIM(ZB0->ZB0_UM ),oFont10)
	   oReport:Say(134,374,'GRUPO QUIMICO..: '+UPPER(ALLTRIM(ZB0->ZB0_GRUPOQ)),oFont10)
	   oReport:Say(146,374,'QUANTIDADE.....: '+UPPER(cValToChar(nQtde)),oFont10)
	   oReport:Say(170,374,'CONCENTRA��O...: '+UPPER(SUBST(ZB0->ZB0_CONCEN,1,30) ),oFont10)
	   oReport:Say(194,374,'FORMULA��O.....: '+UPPER(SUBST(ZB0->ZB0_FORMUL,1,30) ),oFont10)     
	   oReport:Say(206,374,'No. de Aplica��es: '+UPPER(ALLTRIM(cNApl) ),oFont10)    
	   oReport:Say(230,374,'TOXIDADE: '+ UPPER(SUBST(ZB0->ZB0_TOXICI,1,30)),oFont10)

	   oReport:Box(300,10,350,630)// box MANEJO INTEGRADO DE PRAGA l=230 ate l=260
	   oReport:Say(310,015,'MANEJO INTEGRADO DE PRAGA:',oFont09)
	   ImpObs(320, ALLTRIM(ZB0->ZB0_MIPRAG)) // 334 346 
			
	   oReport:Box(350,10,430,630)// box PRECAU��ES DE USO // ==> L=260 ate l=310 := 503
	   oReport:Say(360,015,'PRECAU��ES DE USO:',oFont09)
	   ImpObs(370, ALLTRIM(ZB0->ZB0_PRECAU))

	   oReport:Box(430,10,510,630)// box PRIMEIROS SOCORROS EM CASO DE ACIDENTES // l=310 ate l=370
	   oReport:Say(440,015,'PRIMEIROS SOCORROS EM CASO DE ACIDENTES:',oFont09)
	   ImpObs(450, ALLTRIM(ZB0->ZB0_PRIMEI))

	   oReport:Box(510,10,550,630)// box INFORMAÇÕES SOBRE ANTIDOTO E TRATAMENTO [500,10,550,630]
	   oReport:Say(520,015,'INFORMA��ES SOBRE ANTIDOTO E TRATAMENTO:',oFont09)
	   ImpObs(530, ALLTRIM(ZB0->ZB0_IATRAT))

	   oReport:Box(550,10,590,630)// box ADVERTENCIAS RELACIONADAS A PROTE��O DO MEIO AMBIENTE [500,10,550,630]
	   oReport:Say(560,015,'ADVERTENCIAS RELACIONADAS A PROCE��O DO MEIO AMBIENTE:',oFont09)
	   ImpObs(570, ALLTRIM(ZB0->ZB0_ARPMAM))

	   oReport:Box(590,10,660,630)// box INSTRU�OES SOBRE A DISPOSI��O FINAL DE SOBRAS E EMBALAGENS [550,10,660,630]
	   oReport:Say(600,015,'INSTRU��O SOBRE A DISPOSI��O FINAL DE SOBRAS E EMBALAGENS:',oFont09)
	   ImpObs(610, ALLTRIM(ZB0->ZB0_IDESEM))

	   oReport:Box(660,10,690,630)// box EQUIPAMENTO DE PROTE��O INDIVIDUAL  [630,10,660,630]
	   oReport:Say(670,015,'EQUIPAMENTO DE PROTE��O INDIVIDUAL:',oFont09)
	   ImpObs(678, ALLTRIM(ZB0->ZB0_EPIND))

	   oReport:Box(690,10,725,630)// box INFORMA��ES ADICIONAIS/OBSERVACOES [660,10,720,630]
	   oReport:Say(700,015,'INFORMA��ES ADICIONAIS:',oFont09)
	   ImpObs(710, ALLTRIM(cIAdic))

	   oReport:Box(110,372,300,372)// box Identificação da Receita //49 espacos é o limite para a quebra de pagina:

	EndIF

Return .T.

//Fun��o para imprimir o Cabe�alho do Receituario Agronomico
Static Function ImpCab(aCabeca, lVerso)
  Local cLogo:= Alltrim(SuperGetMV("CS_IMGREL",,FisxLogo("1") ))//"lglr"+Alltrim(cEmpAnt)+".bmp"
  default lVerso:= .F.
  //cLogo	:= GetSrvProfString("Startpath","") + "lgrl01.png"

  oReport:StartPage ()
  //oReport:Box(0,10,20,610)// box Titulo
  oReport:Say(10,230,'RECEITA AGRON�MICA',oFont4N)
  oReport:Box(15,10,60,470)//Box da Imagem + Empresa
  oReport:Say(30,150,Alltrim(SM0->M0_NOMECOM),oFont3N)

  oReport:Say(40,150,ALLTRIM(SM0->M0_ENDCOB),oFont0)//Endere�o
  oReport:Say(48,150,ALLTRIM(SM0->M0_CIDCOB)+' - '+ALLTRIM(SM0->M0_ESTCOB),oFont0)//Cidade/UF
  oReport:Say(56,150,Transform(ALLTRIM(SM0->M0_CEPCOB),"@R 99999-999"),oFont0)    //CEP

  oReport:Box(15,450,45,630)//Box Nr. Receita
  
  If LEN(UPPER(cValTochar(aCabeca[1]))) <= 15 
     oReport:Say(25,452,'NR. RECEITA: '+UPPER(cValTochar(aCabeca[1]))+' S�RIE: '+UPPER(cValTochar(aCabeca[2])),oFont0)
  ElseIf LEN(UPPER(cValTochar(aCabeca[1]))) > 15
     oReport:Say(25,452,'NR. RECEITA: '+UPPER(cValTochar(aCabeca[1])),oFont0)
	 oReport:Say(37,452,'S�RIE......: '+UPPER(cValTochar(aCabeca[2])),oFont0)
  Endif

  //oReport:Say(37,472,'NT. FISCAL: '+UPPER(cValTochar(aCabeca[8]))+' S�RIE NF: '+UPPER(cValTochar(aCabeca[9])),oFont0)
  oReport:Box(45,450,60,630)//Box Nr. ART
  oReport:Say(55,452,'VINCULADA A ART NR�: '+UPPER(cValTochar(aCabeca[3])),oFont0)
  oReport:SayBitmap(16,15,cLogo,135,42, , .T. ) //0103011978

  oReport:Box(60,10,95,630)// box Cliente
  oReport:Say(70,015,'REQUERENTE: '+UPPER(cValTochar(aCabeca[4])),oFont0)
  oReport:Say(70,380,'CNPJ/CPF..: '+UPPER(cValTochar(aCabeca[10])),oFont0)

  oReport:Say(80,015,'NOME DA PROPRIEDADE: '+UPPER(cValTochar(aCabeca[7])),oFont0)
  oReport:Say(80,380,'INSC. EST.: '+UPPER(cValTochar(aCabeca[11])),oFont0)

  oReport:Say(90,015,'LOCALIZA��O: '+UPPER(cValTochar(aCabeca[5])),oFont0)
  oReport:Say(90,380,'MUNICIPIO.: '+UPPER(cValTochar(aCabeca[6])),oFont0)

  //oReport:Box(95,10,110,620)// box Recomenda��es
  If !lVerso
     oReport:Say(105,230,'RECOMENDA��ES T�CNICAS',oFont2N)
  Endif
Return

//Fun��o para Imprimir o Rodape do Receituario Agronomico
Static Function ImpRod(aRodape, cMensag)
  default cMensag := ""

  oReport:Box(725,10,840,630)// box Rodape
  oReport:Say(755,15,cValTochar(aRodape[5]),oFont10)
  oReport:Say(757,15,'_________________________________________________',oFont10)
  oReport:Say(765,15,'Local e Data',oFont10)

  //oReport:Say(755,350,'Ténico do Teste de Impressão. ',oFont10)
  oReport:Say(780,350,'________________________________________________',oFont10) // 757
  oReport:Say(790,350,'Assinatura do Profissional',oFont10)  // 765

  oReport:Say(805,350,'Resp. T�cnico: '+cValTochar(aRodape[1]),oFont10) // 785
  oReport:Say(815,350,'CREA Nro.: '+cValTochar(aRodape[2]),oFont10) // 795
  oReport:Say(815,480,'CPF: '+cValTochar(aRodape[3]),oFont10) // 795
  oReport:Say(825,350,'Endere�o: '+cValTochar(aRodape[4]),oFont10) // 805

  oReport:Say(735,345,'ESTOU CIENTE DAS RECOMENDA��ES CONTIDAS NESTA RECEITA',oFont10)
  //oReport:Say(745,342,'INCLUSIVE NO SEU VERSO.',oFont10)

  oReport:Say(807,15,'_________________________________________________',oFont10)
  oReport:Say(815,15,'Assinatura do Requerente',oFont10)
  oReport:Say(825,15,cValTochar(aRodape[6]),oFont10)

  If !Empty(cMensag)
     nTamMen := LEN(cMensag)*4
     nColu   := 630-nTamMen
  	 oReport:Say(850,nColu,cMensag,oFont08)
  Endif
Return .T.

//Fun��o para imprimir a observa��o do produto
Static Function ImpObs(nLinIni, cObs)
  Local cMemo
  Local nMemCount
  Local nLinFim
  Local nAux
  Local nLoop
  Local nDados := 0

  nLinFim := nLinIni

  cMemo     := Alltrim(cObs)
  nMemCount := MlCount(cMemo)

  // Pega o maior n�mero entre as duas variaveis e armazena no nAux
  If nMemCount >= nDados
     nAux := nMemCount
  Else
     nAux := nDados
  EndIf

  //Loop com o maior n�mero de linhas e impress�o do rodap�
  For nLoop := 1 To nAux
     If nLoop <= nMemCount
	    cLinha := MemoLine( cMemo, 150, nLoop,,.T. )
        If IsUpper(cLinha)
  		   cLinha := MemoLine( cMemo, 115, nLoop,,.T. )
        Endif
 	    oReport:Say(nLinFim,15,cLinha ,oFont10) // Estava oFont06 
		nLinFim+=8
	 EndIf
  Next nLoop
Return .T.
