#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"

#DEFINE PAD_LEFT          0
#DEFINE PAD_RIGHT         1
#DEFINE PAD_CENTE         2

#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030

/*
Relatório dos itens do Receituario Agronomico emitido por:
	Perguntas a Criar:
	"01","Emissão De: ?     ","","","mv_ch1","D",08,0,0,"G","","mv_par01
	"02","Emissão Até: ?    ","","","mv_ch2","D",08,0,0,"G","","mv_par02
//"03","Nota De: ?        ","","","mv_ch3","C",09,0,0,"G","","mv_par03
//"04","Nota Até: ?       ","","","mv_ch4","C",09,0,0,"G","","mv_par04
	"03","No.ART de: ?      ","","","mv_ch3","C",09,0,0,"G","","mv_par03
	"04","No.ART ate: ?     ","","","mv_ch4","C",09,0,0,"G","","mv_par04
	"05","Filial: ?         ","","","mv_ch5","C",04,0,0,"G","","mv_par05

       ver CTSETFIL
	Primeiro design:
		No layout do relatório deverá conter informações como: 
		Filial, data emissão, numero receituario, numero nota, produto, agrônomo, cliente (código e nome) 
	Solicitação de alteração design: Pablo com concentimento do Andre;
		Filial, Data Emissao, Num Recei, Nfe, Cod Prod, Descrição, Diagnostico, Cultura, COD. Nome do Tec, Cod Cliente, Nome Fantasia


ZB0 - Cadastro de Produto X Cultura   
ZB1 - Cadastro Tecnicos Receituario   
ZB2 - Autorizacao Receit. do Tecnico  
ZB3 - Historico Uso Receituario       
ZB4 - Cadastro de Diagnostico         
ZB5 - Cadastro de Equipamentos        
ZB6 - Itens do Receituario Agronomico 

========================================================================================================================
CRIAR MENU SIGAFAT/RELATORIOS/REL.RECEIT.AGRONOMICO
========================================================================================================================

========================================================================================================================
CRIAR PERGUNTAS: CSL05R03
========================================================================================================================
Grupo      Ordem Pergunta        Tipo Tam Dec Formato Valid                  Help  Objeto  F3      Itens.Combo(1a5)
------------------------------------------------------------------------------------------------------------------------
CSL05R03       1 Emissão De: ?     D    08  0                                Edit   
CSL05R03       2 Emissão Até: ?    D    08  0                                Edit   
CSL05R03       3 Nota De: ?        C    20  0                                Edit   
CSL05R03       4 Nota Até: ?       C    20  0                                Edit   
CSL05R03       5 Filiais: ?        C    04  0                                Edit   
*/

User Function CSL05R03()

//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã
//Â³Declaracao de variaveis                   Â³
//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã
	Private cPerg    := Padr("CSL05R03",Len(SX1->X1_GRUPO))
	Private oReport

	// Variaveis para gerenciar a criação do PDF
	Private lAdjustToLegacy := .F.
	Private lDisableSetup := .T.
	Private cDirPrint	:= SuperGetmv("CS_DRTREC",.f.,"C:\TEMP\RECEITA\"/*GetTempPath(.F.)*/)
	Private cHoraAtu	:= StrTran(TIME(),":","")
	Private cTmpNome	:= SuperGetmv("CS_NOMREC",.f.,"RecAgro_"+StrTran(cValToChar(dDatabase),"/","") )
	Private cFileOP		:= cTmpNome+"_"+cHoraAtu+".pdf"
	Private cIRAgr      := SuperGetMV("MV_X_IRAGR")		// Imagem do Verso do Receituario.
	Private cCFRAG      := SuperGetMV("MV_X_CFRAG")		// Os CFOP's inclusos nesse parametro nao irao Emitir Receituario Agronomico. (Solicitacao em 03/03/2020 email)
	Private lPorItem	:= SuperGetMV( "CS_PORITE",,"N" ) == "S"
	
//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã
//Â³Criacao e apresentacao das perguntas      Â³
//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã
//PutSx1(cPerg,"01","Cliente?"  ,'','',"mv_ch1","C",TamSx3 ("E1_CLIENTE")[1] ,0,,"G","","SA1","","","mv_par01","","","","","","","","","","","","","","","","")
	GeraSX1(.F.)
	If !Pergunte(cPerg,.T.) 
		Return(Nil)
	EndIf

	MontaDir(cDirPrint)
	
	lAdjustToLegacy := .F.
	lDisableSetup := .T.
	oReport := FWMSPrinter():New(cFileOP,IMP_PDF, lAdjustToLegacy,cDirPrint, .t.,,,,.t.)// Ordem obrigátoria de configuração do relatório.
	oReport:cPathPDF := cDirPrint
	
	Processa({|| ProDados(oReport) },"Imprimindo...")
	// Visualiza a impressão

//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã
//Â³Definicoes/preparacao para impressao      Â³
//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã
	oReport:EndPage()
	Processa({||oReport:Preview()},"Gerando Visualização...")
	

Return Nil

/*
ÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃ
Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â
Â±Â±Ã‰ÃÃÃÃÃÃÃÃÃÃÃ‘ÃÃÃÃÃÃÃÃÃÃÃ‹ÃÃÃÃÃÃÃÃ‘ÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃ‹ÃÃÃÃÃÃÃ‘ÃÃÃÃÃÃÃÃÃÃÃÃÃÂ»Â
Â±Â±ÂºPrograma  Â³ReportDef ÂºAutor  Â³ Wesley Tofole   Âº Data Â³ 19/07/2016       Â
Â±Â±ÃŒÃÃÃÃÃÃÃÃÃÃÃ˜ÃÃÃÃÃÃÃÃÃÃÃŠÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃŠÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÂ¹Â±Â±
Â±Â±ÂºDesc.     Â³ DefiniÃ§Ã£o da estrutura do relatÃ³rio.                       ÂºÂ±
Â±Â±Âº          Â³                                                            Âº Â±Â±
Â±Â±ÃŒÃÃÃÃÃÃÃÃÃÃÃ˜ÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃ   Â¹±Â±
Â±Â±ÂºUso       Â³                                                            Âº Â±Â±
Â±Â±ÃˆÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÂ¼  Â±Â±
Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â
ÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃ
*/
Static Function ProDados(oReport)
Local cQuery     := ""
Local cLogo    := SuperGetMV("MV_X_LOGPV")

	oReport:SetResolution(78) //Tamanho estipulado para a Danfe
	oReport:SetLandsCape()    // SetPortrait()-->Retrato
	oReport:SetPaperSize(DMPAPER_A4)
	oReport:SetMargin(10,10,10,10)
	oReport:lServer  := .f.
	oReport:nDevice  := IMP_PDF
	oReport:cPathPDF := cDirPrint//oSetupBOL:aOptions[PD_VALUETYPE]

// oReport := TReport():New("CSL05R03","Receituário",cPerg,{|oReport| PrintReport(oReport)},"Relatório de Emissão do Receituário")
// oReport:SetLandscape(.F.)    //Define a orientação de página do relatório como paisagem  ou retrato. .F.=Retrato; .T.=Paisagem
// oReport:cFontBody := 'Calibri'
// oReport:nFontBody := 10
//TRFunction():New(/*Cell*/             ,/*cId*/,/*Function*/,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,/*Section*/)
//TRFunction():New(oSecCab:Cell("A1_NREDUZ"),/*cId*/,/*"COUNT"*/     ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)

/*
ÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœÃœ
Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±
Â±Â±Ã‰ÃÃÃÃÃÃÃÃÃÃÃ‘ÃÃÃÃÃÃÃÃÃÃÃ‹ÃÃÃÃÃÃÃÃ‘ÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃ‹ÃÃÃÃÃÃÃ‘ÃÃÃÃÃÃÃÃÃÃÃÃÃÂ»Â±Â±
Â±Â±ÂºPrograma  Â³POSCLI   ÂºAutor  Â³ VinÃ­cius Moreira   Âº Data Â³ 12/11/2013  ÂºÂ±Â±
Â±Â±ÃŒÃÃÃÃÃÃÃÃÃÃÃ˜ÃÃÃÃÃÃÃÃÃÃÃŠÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃŠÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÂ¹Â±Â±
Â±Â±ÂºDesc.     Â³                                                            ÂºÂ±Â±
Â±Â±Âº          Â³                                                            ÂºÂ±Â±
Â±Â±ÃŒÃÃÃÃÃÃÃÃÃÃÃ˜ÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÂ¹Â±Â±
Â±Â±ÂºUso       Â³                                                            ÂºÂ±Â±
Â±Â±ÃˆÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÃÂ¼Â±Â±
Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±Â±
ÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸÃŸ
*/
Private nLinI      := 000
Private nCol       := 000
Private nSalto     := 010
Private nSaltoSay  := 008

Private oFont06	   := TFontEx():New(oReport,"Courier New",06,06,.F.,.T.,.F.)//
Private oFont06n   := TFontEx():New(oReport,"Courier New",06,06,.T.,.T.,.F.)//Negrito
Private oFont07	   := TFontEx():New(oReport,"Courier New",07,07,.F.,.T.,.F.)//
Private oFont07n   := TFontEx():New(oReport,"Courier New",07,07,.T.,.T.,.F.)//Negrito
Private oFont08	   := TFontEx():New(oReport,"Courier New",08,08,.F.,.T.,.F.)//
Private oFont08n   := TFontEx():New(oReport,"Courier New",08,08,.T.,.T.,.F.)//Negrito
Private oFont09	   := TFontEx():New(oReport,"Courier New",09,09,.F.,.T.,.F.)//
Private oFont09n   := TFontEx():New(oReport,"Courier New",09,09,.T.,.T.,.F.)//Negrito
Private oFont10	   := TFontEx():New(oReport,"Courier New",10,10,.F.,.T.,.F.)//
PRIVATE oFont10N   := TFontEx():New(oReport,"Courier New",10,10,.T.,.T.,.F.)//Negrito
Private oFont12    := TFontEx():New(oReport,"Courier New",12,12,.F.,.T.,.F.)//
Private oFont12n   := TFontEx():New(oReport,"Courier New",12,12,.T.,.T.,.F.)//Negrito
Private oBrush     := TBrush():New( , RGB( 200, 200, 200 ) )  // Cinza

Private m_pag      := 0

Private PixelX := oReport:nLogPixelX()
Private PixelY := oReport:nLogPixelY()
Private nLinMax := 600  // 3168 / 10 = 316 linhas
Private nColMax := 900  // 2400 / 4  = 600 colunas

InicPage()
nHPage := oReport:nHorzRes() //2400
nHPage *= (300/PixelX)
nHPage -= HMARGEM  //2370
nVPage := oReport:nVertRes() //3168
nVPage *= (300/PixelY)
nVPage -= VBOX  //3088

//Pergunte(cPerg,.F.)
/*
// Filial, data emissão, numero receituario, numero nota, produto    , agrônomo,  cliente (código e nome) 
// ZB6_FILIAL, |           ZB6_RECEIT         ZB6_NTFISC  ZB6_PRODUT   ZB6_NMTECN ZB6_CLIENT -> SA1->A1_FILIAL+A1_COD==A1_NREDUZ
//             (ZB6_XFILUS+ZB6_NTFISC+ZB6_SERNTA)-->F2_EMISSAO

CSL05R03       1 Emissão De: ?     D    08  0  SF2                           Edit   
CSL05R03       2 Emissão Até: ?    D    08  0  SF2                           Edit   
CSL05R03       3 Nota De: ?        C    09  0                                Edit   
CSL05R03       4 Nota Até: ?       C    09  0                                Edit   
CSL05R03       5 Filiais: ?        C    04  0                                Edit   

TRCell():New( oSecCab, "ZB6_FILIAL"     , "QRY")
TRCell():New( oSecCab, "F2_EMISSAO"     , "QRY")
TRCell():New( oSecCab, "ZB6_RECEIT"     , "QRY")
TRCell():New( oSecCab, "ZB6_NTFISC"     , "QRY")
TRCell():New( oSecCab, "ZB6_PRODUT"     , "QRY")
TRCell():New( oSecCab, "ZB6_NMTECN"     , "QRY")
TRCell():New( oSecCab, "ZB6_CLIENT"     , "QRY")
TRCell():New( oSecCab, "A1_NREDUZ"      , "QRY")
*/

//oReport:Cell("F2_EMISSAO"):SetValue(DTOC(STOD(QRY->F2_EMISSAO)))
cQuery := "SELECT ZB6_NUMART, " + CRLF // 
cQuery += "       ZB6_FILIAL, " + CRLF
cQuery += "       ZB6_RECEIT, " + CRLF
cQuery += "       ZB6_TECNIC, " + CRLF
cQuery += "       ZB6_RECEIT, " + CRLF
cQuery += "       ZB6_NTFISC, " + CRLF
cQuery += "       ZB6_PRODUT, " + CRLF
cQuery += "       ZB6_NMTECN, " + CRLF
cQuery += "       ZB6_CLIENT, " + CRLF
cQuery += "       F2_EMISSAO, " + CRLF
cQuery += "       A1_COD, "     + CRLF
cQuery += "       A1_NREDUZ "   + CRLF
cQuery += "FROM " + CRLF
cQuery += RetSQLName("ZB6") + " ZB6 "+ CRLF
cQuery += "INNER JOIN " + RetSQLName("SF2") + " SF2 "+ CRLF
cQuery += "ON (ZB6_FILIAL = '" + xFilial("ZB6") + "' AND ZB6_NUMART BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "+ CRLF
cQuery += "ZB6_NTFISC=F2_DOC AND ZB6_SERNTA=F2_SERIE AND ZB6_XFILUS=F2_FILIAL AND ZB6.D_E_L_E_T_ = ' ' ) "+ CRLF
cQuery += "JOIN " + RetSQLName("SA1") + " SA1 "+ CRLF
cQuery += "ON ("+ CRLF
cQuery += "SA1.D_E_L_E_T_ = ' ' AND "+ CRLF
cQuery += "SA1.A1_FILIAL='"+Xfilial("SA1")+"' AND " + CRLF
cQuery += "SA1.A1_COD=ZB6_CLIENT AND SA1.A1_LOJA=ZB6_LOJA) "+ CRLF
cQuery += "WHERE F2_FILIAL='" + MV_PAR05 + "' AND SF2.D_E_L_E_T_=' ' AND F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "+ CRLF
cQuery += "ORDER BY F2_EMISSAO,ZB6_NTFISC,ZB6_XFILUS "+ CRLF
cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "QRY"

If QRY->(FCount()) == 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
	MsgInfo("Sem dados a Exibir, verifique !","Mensagem ao Usuario")
	Return
EndIf

//TcQuery cQuery New Alias "QRY"
//TCSetField("QRY", "F2_EMISSAO", "D")


//             XFIL   F2_EMISSAO   ZB6_RECEIT ZB6_NTFISC   ZB6_PRODUT      B1_DESC                        ZB0_DIAGNO/NMDIAG               ZB0_CULTUR           ZB6_TECNIC/ZB6_NMTECN                   A1_COD       A1_NREDUZ
//	cLinha := "Filial Data Emissao Num Recei Nfe       Cod Prod        Descrição                      Diagnostico                     Cultura              COD. Nome do Tec                    Cod Cliente  Nome Fantasia"
//	           Filial Data Emissao Num Recei Nfe       Cod Prod        Descrição                      Diagnostico                     Cultura              COD. Nome do Tec,                   Cod Cliente  Nome Fantasia
//             mv_p05 01/01/0101   12345678  123456789 123456789012345 123456789012345678901234567890 1234567890123456789012345679890 12345678901234567890 1234 123456879012345678901234567890 123456 12345678901234560

//*************** Imprime Cabecalho ********************
//Dados da Empresa
oReport:SayBitmap(nLinI, nCol, cLogo, 150, 060)
nLinI += nSalto
oReport:Say(nLinI, nCol + 170, Alltrim(SM0->M0_NOMECOM),oFont08N:oFont)
nLinI += nSalto   
oReport:Say(nLinI, nCol + 170, "CNPJ:" + transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + "  I.E.:" + alltrim(SM0->M0_INSC),oFont08N:oFont)
nLinI += nSalto   
oReport:Say(nLinI, nCol + 170, Alltrim(SM0->M0_ENDCOB) + " " + Alltrim(SM0->M0_BAIRCOB),oFont08N:oFont)
nLinI += nSalto
oReport:Say(nLinI, nCol + 170, Transform(SM0->M0_CEPCOB,PesqPict("SA1","A1_CEP")) + " " + alltrim(SM0->M0_CIDCOB) + "-" + alltrim(SM0->M0_ESTCOB),oFont08N:oFont)
nLinI += nSalto
oReport:Say(nLinI, nCol + 170, "Telefone: " + alltrim(SM0->M0_TEL) + " / Fax: " + alltrim(SM0->M0_FAX),oFont08N:oFont)
nLinI += nSalto
oReport:Say(nLinI, nCol + 170, InfoUsu(cUsuario,14),oFont08N:oFont)
nLinI += nSalto
nLinI += nSalto
//oReport:Line(nLinI,nCol      , nLinI, nColMax)
//nLinI += nSalto
Zebrado(10)
ImpCabecI()

DO While !EOF()
 //           1        2              3          4      5          6           7             8         9                  10            11           
 // ImpDet({ "Filial","Data Emissao","Num Recei","Nfe","Cod Prod","Descrição","Diagnostico","Cultura","COD. Nome do Tec","Cod Cliente","Nome Fantasia"}, oFont09N:oFont, .T.)
 //           1        2              3           4     5          6           7                 8          9                      10            11 
 // ImpDet({ "Filial","Data Emissao","Num Recei","Nfe","Cod Prod","Descrição","Diagnostico"    ,"Cultura" ,"COD. Nome do Tec"    ,"Cod Cliente","Nome Fantasia"}, oFont09N:oFont, .T.)
 //           XFIL     F2_EMISSAO    ZB6_RECEIT ZB6_NTFISC  ZB6_PRODUT B1_DESC     ZB0_DIAGNO/NMDIAG ZB0_CULTUR ZB6_TECNIC/ZB6_NMTECN  A1_COD A1_NREDUZ
	cDescProd := GetAdvfVal("SB1","B1_DESC"   ,xFilial("SB1") + QRY->ZB6_PRODUT,1) 
	cDiagno   := GETADVFVAL("ZB0","ZB0_DIAGNO",xFilial("SB1") + QRY->ZB6_PRODUT,1) + " " + GETADVFVAL("ZB0","ZB0_NMDIAG",xFilial("SB1") + QRY->ZB6_PRODUT,1)
	cCultur   := GETADVFVAL("ZB0","ZB0_CULTUR",xFilial("SB1") + QRY->ZB6_PRODUT,1) + " " + GETADVFVAL("ZB0","ZB0_NMCULT",xFilial("SB1") + QRY->ZB6_PRODUT,1)
	cStrin1   := GETADVFVAL("ZB2","ZB2_STRIN1",xFilial("ZB2") + QRY->ZB6_NUMART,1)
	cStrin2   := GETADVFVAL("ZB2","ZB2_STRIN2",xFilial("ZB2") + QRY->ZB6_NUMART,1)
	cReceit   := Alltrim(cStrin1)+StrZero(QRY->ZB6_RECEIT,3)+Alltrim(cStrin2)

 //           1        2                             3                            4                5                 6          7        8        9                                    10           11 
  	ImpDet({MV_PAR05, DTOC(STOD(QRY->F2_EMISSAO)), cReceit, QRY->ZB6_NTFISC, QRY->ZB6_PRODUT, LEFT(cDescProd,23), lEFT(cDiagno,25), cCultur, QRY->ZB6_TECNIC+" "+Left(QRY->ZB6_NMTECN,22), QRY->A1_COD, QRY->A1_NREDUZ}, oFont09:oFont)
	
  	If nLinI > nLinMax
  		InicPage()
  		ImpCabecI()
  	EndIf

  	//Separador de  linha
  	oReport:Line(nLinI+nSalto, nCol, nLinI+nSalto, nColMax)
	
  	nLinI += nSalto
	If nLinI > nLinMax
		InicPage()
  		ImpCabecI()
	EndIf
	  	
  	DbSelectArea("QRY")
  	QRY->(DbSkip())
  ENDDO

Return Nil




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InicPage  ºAutor  ³Daniel Peixoto      º Data ³  14/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicia uma nova pagina e impremi nro da pagina              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InicPage()
oReport:EndPage()
oReport:StartPage()
nLinI := 0
m_pag++
oReport:Say(nLinI+010, nColMax-47, "Pag.: " + STRZERO(m_pag, 2),oFont08:oFont)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCabecI ºAutor  ³Daniel Peixoto      º Data ³  14/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Cabecalho do Itens                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabecI()
LOCAL cNumART
 //Separador de  linha
 	cNumART := QRY->ZB6_NUMART
	 nLinI += nSalto
    oReport:Say(nLinI , nCol+5, "ART: " + cNumART ,oFont12n:oFont)	
 	nLinI += nSalto

	oReport:Line(nLinI, nCol, nLinI, nColMax)
 //	cLinha :="Filial Data Emissao Num Recei Nfe       Cod Prod        Descrição                      Diagnostico                     Cultura              COD. Nome do Tec                    Cod Cliente  Nome Fantasia"
 //           1        2              3          4      5          6           7             8         9                  10            11           
 	ImpDet({ "Filial","Dt Emissao","Num Receituario","Nfe","Cod Prod","Descrição","Diagnostico","Cultura","Cod. Nome do Tec","Cod.","Nome Fantasia"}, oFont09N:oFont, .T.)
	//Separador de  linha
	oReport:Line(nLinI+nSalto, nCol, nLinI+nSalto, nColMax)
 	nLinI += nSalto

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ InfoUsu  ³ Autor ³ Choite                          ³ Data ³ 19/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna informacao do usuario                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ usuario que inclui o registro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ HISTORICO DE ATUALIZACOES DA ROTINA ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Desenvolvedor   ³ Data   ³Solic.³ Descricao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                 ³        ³      ³                                               ³±±
±±³                 ³        ³      ³                                               ³±±
±±³                 ³        ³      ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InfoUsu(cNomeUsu,nInfo)
LOCAL cRet		:= " "
LOCAL aUsuario	:= {}
PswOrder(2)
PswSeek(cNomeUsu,.T.)
aUsuario  := PSWRET(1)
cRet 	    := alltrim(aUsuario[1,nInfo])
return(cRet)


// Imprime preenchimento da linha
Static Function Zebrado(nTamFont, nColIni)
Default nTamFont := 0
Default nColIni  := nCol
oReport:FillRect({nLinI-nTamFont, nColIni, nLinI+nSalto, nColMax}, oBrush )
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpDet    ºAutor  ³Daniel Peixoto      º Data ³  13/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime grid de Itens                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpDet(aValores, oFontImp, lZebrado)
Default lZebrado := .F.
If lZebrado
	Zebrado()
EndIf

oReport:Line(nLinI, nCol    , nLinI+nSalto, nCol    ) //1-Filial
oReport:Line(nLinI, nCol+035, nLinI+nSalto, nCol+035) //2-Data Emissao
oReport:Line(nLinI, nCol+085, nLinI+nSalto, nCol+085) //3-Num Receituario
oReport:Line(nLinI, nCol+163, nLinI+nSalto, nCol+163) //4-Nfe
oReport:Line(nLinI, nCol+207, nLinI+nSalto, nCol+207) //
oReport:Line(nLinI, nCol+267, nLinI+nSalto, nCol+267) //
oReport:Line(nLinI, nCol+375, nLinI+nSalto, nCol+375) //
oReport:Line(nLinI, nCol+497, nLinI+nSalto, nCol+497) //
oReport:Line(nLinI, nCol+637, nLinI+nSalto, nCol+637) //
oReport:Line(nLinI, nCol+766, nLinI+nSalto, nCol+766) //
oReport:Line(nLinI, nCol+797, nLinI+nSalto, nCol+797) //
oReport:Line(nLinI, nColMax, nLinI+nSalto, nColMax)

oReport:Say(nLinI+nSaltoSay, nCol+005, AllTrim(aValores[01]),oFontImp)    //1-Filial 
oReport:Say(nLinI+nSaltoSay, nCol+037, AllTrim(aValores[02]),oFontImp)    //2-Data Emissao
oReport:Say(nLinI+nSaltoSay, nCol+088, AllTrim(aValores[03]),oFontImp)    //3-Num Recei
IF lZebrado //Cabecalho
	oReport:Say(nLinI+nSaltoSay, nCol+165, AllTrim(aValores[04]),oFontImp) //4-Nfe
	oReport:Say(nLinI+nSaltoSay, nCol+210, AllTrim(aValores[05]),oFontImp) //5-Cod Prod
	oReport:Say(nLinI+nSaltoSay, nCol+270, AllTrim(aValores[06]),oFontImp) //6-Descrição
	oReport:Say(nLinI+nSaltoSay, nCol+377, AllTrim(aValores[07]),oFontImp) //7-Diagnostico
	oReport:Say(nLinI+nSaltoSay, nCol+500, AllTrim(aValores[08]),oFontImp) //8-Cultura
	oReport:Say(nLinI+nSaltoSay, nCol+640, AllTrim(aValores[09]),oFontImp) //9-COD. Nome do Tec
	oReport:Say(nLinI+nSaltoSay, nCol+768, AllTrim(aValores[10]),oFontImp) //10-Cod Cliente
	oReport:Say(nLinI+nSaltoSay, nCol+800, AllTrim(aValores[11]),oFontImp) //11-Nome Fantasia
ELSE //Itens
	oReport:Say(nLinI+nSaltoSay, nCol+165, aValores[04],oFontImp,,,,, PAD_RIGHT) //4-Nfe
	oReport:Say(nLinI+nSaltoSay, nCol+210, aValores[05],oFontImp)                //5-Cod Prod
	oReport:Say(nLinI+nSaltoSay, nCol+270, aValores[06],oFontImp,,,,, PAD_RIGHT) //6-Descrição
	oReport:Say(nLinI+nSaltoSay, nCol+377, aValores[07],oFontImp)                //7-Diagnostico
	oReport:Say(nLinI+nSaltoSay, nCol+500, aValores[08],oFontImp)                //8-Cultura
	oReport:Say(nLinI+nSaltoSay, nCol+640, aValores[09],oFontImp)                //9-COD. Nome do Tec
	oReport:Say(nLinI+nSaltoSay, nCol+768, aValores[10],oFontImp)                //10-Cod Cliente
	oReport:Say(nLinI+nSaltoSay, nCol+800, aValores[11],oFontImp)                //11-Nome Fantasia
ENDIF
Return




/*/{Protheus.doc} GeraSX1
Gera perguntas "Parametros" 
@author Marcelo José
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}
@param lOpc, logical, descricao
@type function
/*/
Static Function GeraSX1(lOpc)
	Local aArea     := GetArea()
	Local aRegs     := {}
	Local nCtaI     := 0
	Local nCtaJ     := 0
	Local aHelpPor  := {}
	Local aHelpSpa  := {}
	Local aHelpEng  := {}

	DbSelectArea("SX1")

	If lOpc
		While .t.
			If MsSeek(cPerg)
				RecLock("SX1", .F.)
				dbdelete()
				MsUnlock()
			Else
				Exit
			EndIf
			DBSKIP()
		End
	EndIf

	AAdd(aRegs,{cPerg,"01","Emissão De: ?     ","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
	AAdd(aRegs,{cPerg,"02","Emissão Até: ?    ","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
	AAdd(aRegs,{cPerg,"03","ART De: ?         ","","","mv_ch3","C",20,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
	AAdd(aRegs,{cPerg,"04","ART Até: ?        ","","","mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
	AAdd(aRegs,{cPerg,"05","Filial: ?         ","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
	
	dbSelectArea("SX1")
	dbSetOrder(1)

	For nCtaI:=1 to Len(aRegs)

		If !dbSeek(cPerg+aRegs[nCtaI,2])
			RecLock("SX1",.T.)
			For nCtaJ := 1 to FCount()
				If nCtaJ <= Len(aRegs[nCtaI])
					FieldPut(nCtaJ,aRegs[nCtaI,nCtaJ])
				Endif
			Next

			// se tiver grupo de campo, ajusta tamanho da pergunta
			IF !empty(aRegs[nCtaI,40])
				IF SXG->( DbSeek( PADR(aRegs[nCtaI,40],Len(SXG->XG_GRUPO)) ) )
					SX1->X1_TAMANHO := SXG->XG_SIZE
				ENDIF
			ENDIF

			MsUnlock()

			// Cria o Help
			aHelpPor := {}
			aHelpSpa := {}
			aHelpEng := {}

			If nCtaI == 1
				AADD(aHelpPor,"Informe a Data Inicial                 ")
				AADD(aHelpPor,"                                       ")
				AADD(aHelpPor,"                                       ")
			ElseIf nCtaI == 2
				AADD(aHelpPor,"Informa a Data Final                   ")
				AADD(aHelpPor,"                                       ")
				AADD(aHelpPor,"                                       ")
			ElseIf nCtaI == 3
				AADD(aHelpPor,"Informe a Numeração da Nota Inicial.   ")
				AADD(aHelpPor,"                                       ")
				AADD(aHelpPor,"                                       ")
			ElseIf nCtaI == 4
				AADD(aHelpPor,"Informe a Numeração da Nota Final.     ")
				AADD(aHelpPor,"                                       ")
				AADD(aHelpPor,"                                       ")
			ElseIf nCtaI == 5
				AADD(aHelpPor,"Informe a Filial que deseja o Relat.   ")
				AADD(aHelpPor,"                                       ")
				AADD(aHelpPor,"                                       ")
			EndIf

			PutSX1Help("P."+alltrim(cPerg)+strzero(nCtaI,2)+".",aHelpPor,aHelpEng,aHelpSpa)

		Endif
	Next
	RestArea(aArea)
Return( Nil )


