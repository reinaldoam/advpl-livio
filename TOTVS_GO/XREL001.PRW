#INCLUDE 'TopConn.ch'
#INCLUDE 'OGR295.ch'

/** {Protheus.doc} OGR295
Listagem Romaneios de Entregas do Produtor (Vulgo Ext. Produtor na Sementes Goias)
Este rel. foi elaborado de acordo com a necessidade da Sementes Goias
@param: 	Nil
@author: 	Emerson coelho
@since: 	25/03/2015
@Uso: 		Agro Industria
*/

User Function XREL001()


//--< variáveis >---------------------------------------------------------------------------
	Private cPerg	 	:= "OGR295"
	Private oBreak1,oBreak2,Obreak3
	Private lPlanilha
	Private oReport,oSec2,oSec3
	Private aTotalPro   := {}
	
	
//--Colunas com Posições Fixas--//
	Private nPoscolA := 10
	Private nPoscolB := 110
	Private nPoscolC := 270
	Private nPoscolD := 320
	Private nPoscolE := 480
	Private nPoscolF := 610
	Private nPoscolG := 720
	Private nPoscolH := 915
	Private nPoscolI := 1100
	Private nPoscolJ := 1277
	Private nPoscolJ1:= 1475
	
	Private nPoscolK := 1660//1445
	Private nPoscolK1:= 1860//1625
	
	//Private nPoscolL := 1755//1780//1630
	Private nPoscolM := 1990
	Private nPoscolN := 2070
	Private nPoscolO := 2190
	Private nPoscolP := 2270
	Private nPoscolQ := 2390
	Private nPoscolR := 2470
	Private nPoscolS := 2600
	Private nPoscolT := 2680
	Private nPoscolU := 2800
	Private nPoscolV := 2880				
	Private nPoscolX := 3000
	Private nPoscolZ := 3080
	Private lTemdado := .f.
	Private vVetGera := {0,0,0,0,0,0}
	
	If !AGRIFDICIONA("SXB","AGRBOX",1,.f.)
		AGRINCOMDIC("UPDOG",,.T.)	
		Return
	EndIf
	
	if .NOT.(IsV12("12")) //-- Somente para versão 11 --//
		AjustaSX1()
	endif		
	Pergunte(cPerg,.f.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/** {Protheus.doc} OGR295
Montando a estrutura/layout do tReport
@param: 	Nil
@author: 	Emerson coelho
@since: 	25/03/2015
@Uso: 		Agro Industria
*/

Static Function ReportDef()
Local nI	:=	0
	
    
//Montando o objeto oReport
	oReport := TReport():NEW("OGR295", STR0001, cPerg, {|oReport|PrintReport(oReport)}, STR0001) //"Listagem de Romaneios Por Entidade,loja e produto"

//Para não imprimir a página de parâmetros
	oReport:lParamPage := .f.
	oReport:GetOrientation(2)
	oreport:nFontBody := 6
	oReport:CFONTBODY			:= "Courier New"
	oReport:nLineHeight:=30
	oReport:SetDevice(2) //iMPRESSORA
	oReport:oPage:setPaperSize(9) // 9 e 10 sao A4
	//oReport:SetColSpace(7,.T.)
	//oReport:lautosize:=.f.
	
	//oreport:oprint:nmargleft
	//oreport:oprint:nmargright
	//oreport:oprint:nmargtop
	//oreport:oprint:nmargbot
	
//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)	

	oSec2 := TRSection():New(oReport,STR0002,{}) //"Romaneios"
	
	oSec2:SettotalInline(.f.)
	osec2:lbold:=.f.
	//oSec2:SetColSpace(,.T.)
	oSec2:lAutosize:=.f.
	osec2:llinebreak:=.f.
	oSec2:lEdit	:= .f. // Usu n. pode editar a secao
	///oSec2:lLineStyle:=.f.
	
	oSec2:SetHeaderSection(.f.)
	TRCell():New(oSec2,"Filial"			,"",STR0003	,'@!'							,08	,.f.) //'Filial'
	TRCell():New(oSec2,"EMISSAO"		,"",STR0004 ,PesqPict('NJJ',"NJJ_DOCEMI")	,10	,.f.) //'Emissão   '
	TRCell():New(oSec2,"TPMVTO"			,"",STR0005 ,"@!"							,2	,.f.) //'TP'	
	TRCell():New(oSec2,"ROMAN"			,"",STR0006 ,'@!'							,10,.f.) //'Romaneio  '	 
	TRCell():New(oSec2,"CONTRATO"		,"",STR0007	,'@!'							,08	,.f.) //'Contrato'
	TRCell():New(oSec2,"PLACA"     		,"",STR0008	,'@R! AAA-9999'					,08	,.f.) //"Placa   "
	TRCell():New(oSec2,"PESO1"     		,"",STR0009	,'@E 9999,999,999'				,12	,.f.) //"   1aPesagem"
	TRCell():New(oSec2,"PESO2"     		,"",STR0010	,'@E 9999,999,999'				,12	,.f.) //"   2aPesagem"
	TRCell():New(oSec2,"PESOBRUTO"    	,"",STR0011	,'@E 9999,999,999'				,12	,.f.) //"  Liq S/Desc"
	TRCell():New(oSec2,"QUEBRA"      ,"","Quebra"	,'@E 9,999.9999'				,10	,.f.) //" Descontos" CASUL
	TRCell():New(oSec2,"QUEBRAT"     ,"","Quebra Tecnica"	,'@E 9,999.9999'				,10	,.f.) //" Descontos" CASUL
	TRCell():New(oSec2,"PESOLIQ"     	,"",STR0013	,'@E 9999,999.9999'				,12	,.f.) //"   P.Liquido"
	TRCell():New(oSec2,"DOCTO"     		,"",STR0014	,'@!'							,10	,.f.) //"Docto     "	
	//TRCell():New(oSec2,"TRANSGENIA"   	,"",PADL(STR0015,30)	,'@!'				,30	,.f.) //"Transgenia" CASUL
	
	/*/ Lembrando o Cab. das Celulas de desconto são dianmicos de acordo com o Mv_par19
		Defino as Cells de Descto com o Header da Cell definido para imprimir em Planilha, Antes de
	  	imprimir verifico se o user escolheu outro device então re-ajusto o Kbeçalho da seçaõ para
	  	ficar em um formato Visivel e q caiba no papel A4
	/*/
	
	/*Totais*/
	oSec3 := TRSection():New(oReport,"Totais",{}) //"Totais"
	oSec3:SettotalInline(.f.)
	osec3:lbold:=.f.
	oSec3:lAutosize:=.f.
	osec3:llinebreak:=.f.
	oSec3:lEdit	:= .f. 
	
	TRCell():New(oSec3,"PRODUTO"		,"","Produto" ,PesqPict('SB1',"B1_DESC")   	,30	,.f.) //'Produto   '
	TRCell():New(oSec3,"PESO1"     		,"",STR0009	,'@E 9999,999,999'				,12	,.f.) //"   1aPesagem"
	TRCell():New(oSec3,"PESO2"     		,"",STR0010	,'@E 9999,999,999'				,12	,.f.) //"   2aPesagem"
	TRCell():New(oSec3,"PESOBRUTO"    	,"",STR0011	,'@E 9999,999,999'				,12	,.f.) //"  Liq S/Desc"
	TRCell():New(oSec3,"QUEBRA"      ,"","Quebra"	,'@E 9,999.9999'				,10	,.f.) //" Descontos" CASUL
	TRCell():New(oSec3,"QUEBRAT"      ,"","Quebra Tecnica"	,'@E 9,999.9999'				,10	,.f.) //" Descontos" CASUL
	TRCell():New(oSec3,"PESOLIQ"     	,"",STR0013	,'@E 999,999.9999'				,12	,.f.) //"   P.Liquido"
	
	aAux	:= {}
	aAdd(aAux,'')
	aAdd(aAux,'')
	aAdd(aAux,'')
	aAdd(aAux,'')
	aAdd(aAux,'')
	aAdd(aAux,'')
	aAuxA 	:= separa(MV_PAR19, ';')
	
	For nI := 1 to Len(aAuxa)
	  aAux[nI] := aAuxa[ni]
	nExt
		
	TRCell():New(oSec2,"VRDESC1"    	,"",aAux[1] + " " + STR0016,'@E 99.99'						,07,.f.)
	TRCell():New(oSec2,"DESC1"     		,"",aAux[1] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec2,"VRDESC2"    	,"",aAux[2] + " " + STR0016,'@E 99.99'						,07	,.f.)
	TRCell():New(oSec2,"DESC2"     		,"",aAux[2] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec2,"VRDESC3"    	,"",aAux[3] + " " + STR0016,'@E 99.99'						,07	,.f.)
	TRCell():New(oSec2,"DESC3"     		,"",aAux[3] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec2,"VRDESC4"    	,"",aAux[4] + " " + STR0016,'@E 99.99'						,07	,.f.)
	TRCell():New(oSec2,"DESC4"     		,"",aAux[4] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec2,"VRDESC5"    	,"",aAux[5] + " " + STR0016,'@E 99.99'						,07	,.f.)
	TRCell():New(oSec2,"DESC5"     		,"",aAux[5] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec2,"VRDESC6"    	,"",aAux[6] + " " + STR0016,'@E 99.99'						,07,.f.)
	TRCell():New(oSec2,"DESC6"     		,"",aAux[6] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	
	/*totais*/
	TRCell():New(oSec3,"VRDESC1"    	,"",aAux[1] + " " + STR0016,'@E 99.99'						,07,.f.)
	TRCell():New(oSec3,"DESC1"     		,"",aAux[1] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec3,"VRDESC2"    	,"",aAux[2] + " " + STR0016,'@E 99.99'						,07	,.f.)
	TRCell():New(oSec3,"DESC2"     		,"",aAux[2] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec3,"VRDESC3"    	,"",aAux[3] + " " + STR0016,'@E 99.99'						,07	,.f.)
	TRCell():New(oSec3,"DESC3"     		,"",aAux[3] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec3,"VRDESC4"    	,"",aAux[4] + " " + STR0016,'@E 99.99'						,07	,.f.)
	TRCell():New(oSec3,"DESC4"     		,"",aAux[4] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec3,"VRDESC5"    	,"",aAux[5] + " " + STR0016,'@E 99.99'						,07	,.f.)
	TRCell():New(oSec3,"DESC5"     		,"",aAux[5] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	TRCell():New(oSec3,"VRDESC6"    	,"",aAux[6] + " " + STR0016,'@E 99.99'						,07,.f.)
	TRCell():New(oSec3,"DESC6"     		,"",aAux[6] + " " + STR0017,'@E 9999,999'					,09	,.f.)
	
	
	
//--Ajustando o AutoSize e Tbem, o Header Size para que possa ser fixo, o tam das colunas e pelo Tit --//
/*
	oSec2:Cell( "Filial"		):SetAutoSize(.f.)
	oSec2:Cell( "EMISSAO"	):SetAutoSize(.f.)
	oSec2:Cell( "ROMAN" 		):SetAutoSize(.f.)
	oSec2:Cell( "TPMVTO"		):SetAutoSize(.f.)
	oSec2:Cell( "CONTRATO"	):SetAutoSize(.f.)
	oSec2:Cell( "PLACA"		):SetAutoSize(.f.)
	oSec2:Cell( "PESO1"		):SetAutoSize(.f.)
	oSec2:Cell( "PESO2" 		):SetAutoSize(.f.)
	oSec2:Cell( "PESOBRUTO"	):SetAutoSize(.f.)
	oSec2:Cell( "DESCONTOS"	):SetAutoSize(.f.)
	oSec2:Cell( "PESOLIQ"	):SetAutoSize(.f.)
	oSec2:Cell( "TRANSGENIA"):SetAutoSize(.f.)
	oSec2:Cell( "VRDESC1"	):SetAutoSize(.f.)
	oSec2:Cell( "DESC1"		):SetAutoSize(.f.)
	oSec2:Cell( "VRDESC2"	):SetAutoSize(.f.)
	oSec2:Cell( "DESC2"		):SetAutoSize(.f.)
	oSec2:Cell( "VRDESC3"	):SetAutoSize(.f.)
	oSec2:Cell( "DESC3"		):SetAutoSize(.f.)
	oSec2:Cell( "VRDESC4"	):SetAutoSize(.f.)
	oSec2:Cell( "DESC4"		):SetAutoSize(.f.)
	oSec2:Cell( "VRDESC5"	):SetAutoSize(.f.)
	oSec2:Cell( "DESC5"		):SetAutoSize(.f.)
	oSec2:Cell( "VRDESC6"	):SetAutoSize(.f.)
	oSec2:Cell( "DESC6"		):SetAutoSize(.f.)
	
//Garanto q o tamanho da cell seja baseado no tamanho do header da mesma



	oSec2:Cell( "FILIAL"		):SetHeaderSize(.t.)
	oSec2:Cell( "EMISSAO"	):SetHeaderSize(.t.)
	oSec2:Cell( "ROMAN" 		):SetHeaderSize(.t.)
	oSec2:Cell( "TPMVTO"		):SetHeaderSize(.t.)
	oSec2:Cell( "CONTRATO"	):SetHeaderSize(.t.)
	oSec2:Cell( "PLACA"		):SetHeaderSize(.t.)
	oSec2:Cell( "PESO1"		):SetHeaderSize(.t.)
	oSec2:Cell( "PESO2" 		):SetHeaderSize(.t.)
	oSec2:Cell( "PESOBRUTO"	):SetHeaderSize(.t.)
	oSec2:Cell( "DESCONTOS"	):SetHeaderSize(.t.)
	oSec2:Cell( "PESOLIQ"	):SetHeaderSize(.t.)
	oSec2:Cell( "TRANSGENIA"):SetHeaderSize(.t.)
	oSec2:Cell( "VRDESC1"	):SetHeaderSize(.t.)
	oSec2:Cell( "DESC1"		):SetHeaderSize(.t.)
	oSec2:Cell( "VRDESC2"	):SetHeaderSize(.t.)
	oSec2:Cell( "DESC2"		):SetHeaderSize(.t.)
	oSec2:Cell( "VRDESC3"	):SetHeaderSize(.t.)
	oSec2:Cell( "DESC3"		):SetHeaderSize(.t.)
	oSec2:Cell( "VRDESC4"	):SetHeaderSize(.t.)
	oSec2:Cell( "DESC4"		):SetHeaderSize(.t.)
	oSec2:Cell( "VRDESC5"	):SetHeaderSize(.t.)
	oSec2:Cell( "DESC5"		):SetHeaderSize(.t.)
	oSec2:Cell( "VRDESC6"	):SetHeaderSize(.t.)
	oSec2:Cell( "DESC6"		):SetHeaderSize(.t.)


	/////////////
	//--Ajustando o AutoSize e Tbem, o Header Size para que possa ser fixo, o tam das colunas e pelo Tit --//
	/*
	oSec2:Cell( "Filial"		):nColSpace:=0
	oSec2:Cell( "EMISSAO"	):nColSpace:=0
	oSec2:Cell( "ROMAN" 		):nColSpace:=0
	oSec2:Cell( "TPMVTO"		):nColSpace:=0
	oSec2:Cell( "CONTRATO"	):nColSpace:=0
	oSec2:Cell( "PLACA"		):nColSpace:=0
	oSec2:Cell( "PESO1"		):nColSpace:=0
	oSec2:Cell( "PESO2" 		):nColSpace:=0
	oSec2:Cell( "PESOBRUTO"	):nColSpace:=0
	oSec2:Cell( "DESCONTOS"	):nColSpace:=0
	oSec2:Cell( "PESOLIQ"	):nColSpace:=0
	oSec2:Cell( "TRANSGENIA"):nColSpace:=0
	oSec2:Cell( "VRDESC1"	):nColSpace:=0
	oSec2:Cell( "DESC1"		):nColSpace:=1
	oSec2:Cell( "VRDESC2"	):nColSpace:=1
	oSec2:Cell( "DESC2"		):nColSpace:=1
	oSec2:Cell( "VRDESC3"	):nColSpace:=1
	oSec2:Cell( "DESC3"		):nColSpace:=1
	oSec2:Cell( "VRDESC4"	):nColSpace:=1
	oSec2:Cell( "DESC4"		):nColSpace:=1
	oSec2:Cell( "VRDESC5"	):nColSpace:=1
	oSec2:Cell( "DESC5"		):nColSpace:=1
	oSec2:Cell( "VRDESC6"	):nColSpace:=1
	oSec2:Cell( "DESC6"		):nColSpace:=1
*/		
	//////////////
	
	//--Ajustando alinhamento das Celulas e Tit;Cabeçalho dos Descontos--//
		
	oSec2:Cell( "PESO1"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "PESO1"		):SetAlign('RIGHT' )
	     
	oSec2:Cell( "PESO2" 		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "PESO2" 		):SetAlign('RIGHT' )
	     
	oSec2:Cell( "PESOBRUTO"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "PESOBRUTO"	):SetAlign('RIGHT' )
		
	//oSec2:Cell( "DESCONTOS"	):SetHeaderAlign('RIGHT' )
	//oSec2:Cell( "DESCONTOS"	):SetAlign('RIGHT' ) 
	oSec2:Cell( "QUEBRA"	):SetHeaderAlign('RIGHT' ) //CASUL
	oSec2:Cell( "QUEBRA"	):SetAlign('RIGHT' )
	oSec2:Cell( "QUEBRAT"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "QUEBRAT"	):SetAlign('RIGHT' )
		 
	oSec2:Cell( "PESOLIQ"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "PESOLIQ"	):SetAlign('RIGHT' )
	
	oSec2:Cell( "VRDESC1"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC1"	):SetAlign('RIGHT' )
		   
	oSec2:Cell( "DESC1"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC1"		):SetAlign('RIGHT' )
	     
	oSec2:Cell( "VRDESC2"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC2"	):SetAlign('RIGHT' )
		   
	oSec2:Cell( "DESC2"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC2"		):SetAlign('RIGHT' )
		     
	oSec2:Cell( "VRDESC3"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC3"	):SetAlign('RIGHT' )
		   
	oSec2:Cell( "DESC3"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC3"		):SetAlign('RIGHT' )
		     
	oSec2:Cell( "VRDESC4"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC4"	):SetAlign('RIGHT' )
		   
	oSec2:Cell( "DESC4"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC4"		):SetAlign('RIGHT' )
	     
	oSec2:Cell( "VRDESC5"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC5"	):SetAlign('RIGHT' )
	   	
	oSec2:Cell( "DESC5"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC5"		):SetAlign('RIGHT' )
		     
	oSec2:Cell( "VRDESC6"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC6"	):SetAlign('RIGHT' )
           
	oSec2:Cell( "DESC6"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC6"		):SetAlign('RIGHT' )
	
	
	/**TOTAIS**/
	oSec3:Cell( "PESO1"		):SetHeaderAlign('RIGHT' )
	oSec3:Cell( "PESO1"		):SetAlign('RIGHT' )
	     
	oSec3:Cell( "PESO2" 		):SetHeaderAlign('RIGHT' )
	oSec3:Cell( "PESO2" 		):SetAlign('RIGHT' )
	     
	oSec3:Cell( "PESOBRUTO"	):SetHeaderAlign('RIGHT' )
	oSec3:Cell( "PESOBRUTO"	):SetAlign('RIGHT' )
		
	//oSec2:Cell( "DESCONTOS"	):SetHeaderAlign('RIGHT' )
	//oSec2:Cell( "DESCONTOS"	):SetAlign('RIGHT' )
	oSec2:Cell( "QUEBRA"	):SetHeaderAlign('RIGHT' ) //CASUL
	oSec2:Cell( "QUEBRA"	):SetAlign('RIGHT' )
	oSec2:Cell( "QUEBRAT"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "QUEBRAT"	):SetAlign('RIGHT' )
		 
	oSec2:Cell( "PESOLIQ"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "PESOLIQ"	):SetAlign('RIGHT' )
	
	oSec2:Cell( "VRDESC1"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC1"	):SetAlign('RIGHT' )
		   
	oSec2:Cell( "DESC1"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC1"		):SetAlign('RIGHT' )
	     
	oSec2:Cell( "VRDESC2"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC2"	):SetAlign('RIGHT' )
		   
	oSec2:Cell( "DESC2"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC2"		):SetAlign('RIGHT' )
		     
	oSec2:Cell( "VRDESC3"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC3"	):SetAlign('RIGHT' )
		   
	oSec2:Cell( "DESC3"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC3"		):SetAlign('RIGHT' )
		     
	oSec2:Cell( "VRDESC4"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC4"	):SetAlign('RIGHT' )
		   
	oSec2:Cell( "DESC4"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC4"		):SetAlign('RIGHT' )
	     
	oSec2:Cell( "VRDESC5"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC5"	):SetAlign('RIGHT' )
	   	
	oSec2:Cell( "DESC5"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC5"		):SetAlign('RIGHT' )
		     
	oSec2:Cell( "VRDESC6"	):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "VRDESC6"	):SetAlign('RIGHT' )
           
	oSec2:Cell( "DESC6"		):SetHeaderAlign('RIGHT' )
	oSec2:Cell( "DESC6"		):SetAlign('RIGHT' )
	

	oBreak1 := TRBreak():New( oSec2, {||QryNJM->(NJM_CODENT + NJM_LOJENT+NJM_CODPRO)}	, /*{||fSaltaPage(3)}*/) 	// "Total do PRODUTO
	oBreak2 := TRBreak():New( oSec2, {||QryNJM->(NJM_CODENT + NJM_LOJENT)}, ) 	// 	"Total da Loja
	oBreak3 := TRBreak():New( oSec2, {||QryNJM->NJM_CODENT}								       , ) 	//	Total a Entidade
	
	///TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint) 
	TRFunction():New(oSec2:Cell("PESO1")		,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESO2")		,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESOBRUTO")	,,"SUM",oBreak1,,,, .f., .f. )
	//TRFunction():New(oSec2:Cell("DESCONTOS")	,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("QUEBRA")	,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("QUEBRAT")	,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESOLIQ")		,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC1")		,,"AVERAGE",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC1")		,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC2")		,,"AVERAGE",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC2")		,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC3")		,,"AVERAGE",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC3")		,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC4")		,,"AVERAGE",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC4")		,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC5")		,,"AVERAGE",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC5")		,,"SUM",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC6")		,,"AVERAGE",oBreak1,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC6")		,,"SUM",oBreak1,,,, .f., .f. )
		
	TRFunction():New(oSec2:Cell("PESO1")		,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESO2")		,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESOBRUTO")	,,"SUM",oBreak2,,,, .f., .f. )
	//TRFunction():New(oSec2:Cell("DESCONTOS")	,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("QUEBRA")	,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("QUEBRAT")	,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESOLIQ")		,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC1")		,,"AVERAGE",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC1")		,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC2")		,,"AVERAGE",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC2")		,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC3")		,,"AVERAGE",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC3")		,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC4")		,,"AVERAGE",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC4")		,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC5")		,,"AVERAGE",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC5")		,,"SUM",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC6")		,,"AVERAGE",oBreak2,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC6")		,,"SUM",oBreak2,,,, .f., .f. )
		
	TRFunction():New(oSec2:Cell("PESO1")		,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESO2")		,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESOBRUTO")	,,"SUM",oBreak3,,,, .f., .f. )
	//TRFunction():New(oSec2:Cell("DESCONTOS")	,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("QUEBRA")	,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("QUEBRAT")	,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("PESOLIQ")		,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC1")		,,"AVERAGE",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC1")		,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC2")		,,"AVERAGE",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC2")		,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC3")		,,"AVERAGE",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC3")		,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC4")		,,"AVERAGE",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC4")		,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC5")		,,"AVERAGE",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC5")		,,"SUM",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("VRDESC6")		,,"AVERAGE",oBreak3,,,, .f., .f. )
	TRFunction():New(oSec2:Cell("DESC6")		,,"SUM",oBreak3,,,, .f., .f. )

	oReport:SetLandScape()
	oReport:DisableOrientation()
	
	oReport:OnPageBreak({|| fPrnCabEsp("P") /*Cabeçalho Principal*/  })  	// Irá Forçar Imprimir o Cabeçalho Especifico
	///oReport:SetPageFooter(2, {|| fRodape()}) n. funciona como deveria
	
Return(oReport)


/** {Protheus.doc} 
    Filtra e imprime a listagem
@param: 	Nil
@author: 	Emerson coelho
@since: 	25/03/2015
@Uso: 		Agro Industria
*/

Static Function PrintReport(oReport)
	Local nI			:= 0
	Local limpLine	:= .f.
	
	Local nValor1			:= 0
	Local nDesc1			:= 0
	Local nValor2			:= 0
	Local nDesc2			:= 0
	
	Local nValor3			:= 0
	Local nDesc3			:= 0
	
	Local nValor4			:= 0
	Local nDesc4			:= 0
	
	Local nValor5			:= 0
	Local nDesc5			:= 0
	
	Local nValor6			:= 0
	Local nDesc6			:= 0
	Local nx,x,pos
	
	Local cRodape := fgerRodape() // Gera linha com os tipos de movtos da TAB K5 na SX5

	Local	 cQuery	:= ""
	Local	 cJoinFil	:= ""

	Private cFilialIni	:= MV_PAR01
	Private cFilialFim	:= MV_PAR02
	Private cEntidIni 	:= MV_PAR03
	Private cLojaIni 	:= MV_PAR04
	Private cEntidFim 	:= MV_PAR05
	Private cLojaFim 	:= MV_PAR06
	Private cCtrIni		:= MV_PAR07
	Private cCtrFim     := MV_PAR08
	Private cCodSafIni  := MV_PAR09
	Private cCodSafFim  := MV_PAR10
	Private nTpDataLst     :=MV_PAR11
	Private dDtIni        :=MV_PAR12
 Private dDtFim        :=MV_PAR13
    
	Private cGrpPrdIni	:=MV_PAR14
	Private cGrpPrdFim	:=MV_PAR15
	Private cProdutIni 	:=MV_PAR16
	Private cProdutFim	:=MV_PAR17

 Private cIdTransg    	:=MV_PAR18    //--Contera os Tps desctos Ref. a Transgenia, O usuario precisa Informar		--//
	Private cDesctos     	:=MV_PAR19   	//--Contera os Tps Desctos que devem ser impressos no Maximo 6 Para caber em A4 	--//
	Private nTpMvRom		 :=MV_PAR20
	Private nTpRom			  :=MV_PAR21
	Private cStatusLst :=MV_PAR22
	//CASUL
	Private nConsNF    :=MV_PAR25 //1=SIM  2=NAO  3=AMBOS
	
	lPlanilha := IIF(oReport:ndevice = 4, .t.,.f.)
	
	nCont	:= 0
	nPag	:= 1

	oReport:SetPageNumber(nPag)
	oReport:Page(nPag)
	
	cquery:=''
	cQuery += " SELECT "
	cQuery += "		B1_DESC, "
	cQuery += "  NJJ_DATA, NJJ_FILIAL, NJJ_TIPO, NJJ_PLACA, NJJ_PESO1, NJJ_PESO2, NJJ_PESO3, NJJ_PSLIQU, NJJ_STATUS, NJJ_STSPES, " 
	cQuery += "  NJM_TES, NJM_CODENT, NJM_LOJENT, NJM_CODPRO, NJM_FILIAL, NJM_CODROM, NJM_DOCNUM, SUM(NJM_PERDIV) NJM_PERDIV, "
	cQuery += "  NJJ_X_QBT, NJM_TIPO, "
	cQuery += " 		(CASE "
	cQuery += "  			WHEN NJM.NJM_TIPO  IN ('3' , '5', '7' , '9') THEN 'E'"	//Romaneios de Entrada
	cQuery += "  			WHEN NJM.NJM_TIPO  IN ('2' , '4' , '6', '8' ) THEN 'S'"	//Romaneios de Saida
	cQuery += "  		END) AS TPROM, "
	cQuery += " ( "
	cQuery += "	SELECT SUM(NJK.NJK_QTDDES) FROM " + RetSqlName('NJK')+ " NJK "
	cQuery += " WHERE "
	//// Tirado cQuery += " 	WHERE NJK.NJK_FILIAL = NJM.NJM_FILIAL AND NJK.NJK_CODROM = NJM.NJM_CODROM AND NJK.D_E_L_E_T_ !='*' "
	
	  //--Encontrando a Filial do Inner NJK --
    cJoinFil :=''
	If FWModeAccess("NJK") == "E" .And. FWModeAccess("NJM") == "E"
		cJoinFil += "  NJK.NJK_FILIAL = NJM.NJM_FILIAL AND "
	ElseIf FWModeAccess("NJK",3) == "E"
		cJoinFil += " NJK.NJK_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " NJK.NJK_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("NJK",2) == "E"
		cJoinFil += " NJK.NJK_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJK.NJK_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("NJK",1) == "E"
		cJoinFil += " NJK.NJK_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJK.NJK_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " NJK.NJK_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " NJK.NJK_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
   //------------------------------------------------------------------------
   	cQuery +=  cJoinfil + " NJK.NJK_CODROM = NJM.NJM_CODROM AND NJK.D_E_L_E_T_ !='*' "
	
	cQuery += " ) AS DESCONTO "
	cQuery += " FROM " + RetSqlName('NJM')+ " NJM "
	cQuery += " LEFT JOIN " + RetSqlName('SB1')+ " SB1 ON "
////Mudado rel imprime agora de FILIAL DE /ATE cQuery += " 		ON SB1.B1_FILIAL = '" + fwXfilial('SB1') 	+ "' AND SB1.B1_COD = NJM.NJM_CODPRO AND SB1.D_E_L_E_T_ = ' '"	
	
    //--Encontrando a Filial do Inner Join SB1 --
    cJoinFil :=''
	If FWModeAccess("SB1") == "E" .And. FWModeAccess("NJM") == "E"
		cJoinFil += "  SB1.B1_FILIAL = NJM.NJM_FILIAL AND "
	ElseIf FWModeAccess("SB1",3) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("SB1",2) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("SB1",1) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " SB1.B1_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
   //-----------------------------------------------------------------------
	cQuery += cJoinFil +" SB1.B1_COD = NJM.NJM_CODPRO AND SB1.D_E_L_E_T_ = ' '"   		
	
	cQuery += " LEFT JOIN " + RetSqlName('NJJ')+ " NJJ ON "
////Mudado Rel. impme agora de FILIAL DE / ATE 	cQuery += " 		ON NJJ.NJJ_FILIAL = NJM.NJM_FILIAL AND NJJ.NJJ_CODROM = NJM.NJM_CODROM AND NJM.D_E_L_E_T_ = ' '"

    //--Encontrando a Filial do Inner Join NJJ --
    cJoinFil :=''
	If FWModeAccess("NJJ") == "E" .And. FWModeAccess("NJM") == "E"
		cJoinFil += "  NJJ.NJJ_FILIAL = NJM.NJM_FILIAL AND "
	ElseIf FWModeAccess("NJJ",3) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("NJJ",2) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("NJJ",1) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
  
 	cQuery += cJoinFil + " NJJ.NJJ_CODROM = NJM.NJM_CODROM AND NJJ.D_E_L_E_T_ = ' '"
 
	cQuery += " WHERE  NJM.NJM_CODENT BETWEEN '" + cEntidIni + "' AND '" + cEntidFim	+ 	"'"
	cQuery += "  	AND NJM.NJM_LOJENT	 BETWEEN '" + cLojaIni + "' AND '" + cLojaFim	+ 	"'"
	cQuery += "  	AND NJM.NJM_CODCTR BETWEEN '" + cCtrIni + "' AND '" + cCtrFim	+	"'"
	cQuery += " 	AND SB1.B1_GRUPO BETWEEN '" + cGrpPrdIni	+ "' AND '" + cGrpPrdFim	+ 	"'"
	cQuery += "	AND NJM.NJM_CODPRO 	BETWEEN '"  	+ cProdutIni 	+ "' AND '" + cProdutFim	+	"'"
	cQuery += "	AND NJM.NJM_CODSAF 	BETWEEN '"		+ cCodSafIni  + "' AND '" + cCodSafFim	+	"'"
	
	//considera autorização
	If !empty(mv_par24)
		cQuery += "  AND NJM.NJM_CODAUT IN (" + AGRMULTOPQRY(mv_par24) + ")"
	Endif
	
	///cQuery += "	AND NJM.NJM_FILIAL 	= 	'"			+ FwXfilial('NJM') + "'"
	cQuery += "	AND NJM.NJM_FILIAL 	BETWEEN '" 	+ cFilialIni 	+ "' AND '" +	cFilialFim	 + "'"
	IF nTpMvRom == 02 //Considera somente entradas
		cQuery += " AND NJM.NJM_TIPO  IN ('3' , '5', '7' , '9') "
	ElseIF nTpMvRom == 03 //Considera somente Saidas
		cQuery += " AND NJM.NJM_TIPO  IN ('2' , '4' , '6', '8' ) "
	////ElseIF nTpMvRom == 01 // Considera todos os Romaneios //
	EndIF
	
	IF nTpRom == 4 //Considera Romaneios Simbolicos
		cQuery += " AND NJJ.NJJ_TIPENT = '2' "
	ElseIF nTpRom == 3 //Considera Romaneios Gerenciais
		cQuery += " AND NJJ.NJJ_TIPENT = '1' "
	ElseIF nTpRom == 2 //Considera Romaneios Fisicos
		cQuery += " AND NJJ.NJJ_TIPENT = '0' "
	//IF nTpRom == 1 //Considera todos os romaneios..
	EndIF
		
	//considera Paracer da qualidade
	If !empty(mv_par23)
		cQuery += "  AND NJJ.NJJ_LIBQLD IN (" + AGRMULTOPQRY(mv_par23,"N") + ")"
	Endif
	
	if nTpDataLst = 1    //"Data do Romaneio" - "NJJ_DATA";	
	   cQuery += " AND NJJ.NJJ_DATA        BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	elseif nTpDataLst = 2 // "Data da Pesagem 1" - "NJJ_DATPS1"; 
	   cQuery += " AND NJJ.NJJ_DATPS1      BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	elseif nTpDataLst = 3 //"Data da Pesagem 2" - "NJJ_DATPS2";
	   cQuery += " AND NJJ.NJJ_DATPS2       BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	elseif nTpDataLst = 4 //"Emissao do Documento Fiscal" - "NJM_DOCEMI"; 
	   cQuery += " AND NJM.NJM_DOCEMI       BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	elseif nTpDataLst = 5 // "Data da Transação" -  "NJM_DTRANS"
	   cQuery += " AND NJM.NJM_DTRANS        BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	endif
	
	//considera os status
	if !empty(cStatusLst)
		
		aListSts  := separa(cStatusLst, ';') //pega todos os status
		cAuxQuery := ""
		
		For nI := 1 to Len(aListSts) Step 1
			if cAuxQuery == ""
				cAuxQuery := "'" + allTrim(aListSts[nI]) + "'"
			else
				cAuxQuery += " , '" + allTrim(aListSts[nI]) + "'"
			endif
		nExt nI
		
		cQuery += "   AND NJJ.NJJ_STATUS IN (" + cAuxQuery + ")"
		
	else
		cQuery += "   AND NJJ_STATUS NOT IN ('4') " // n. listar Cancelados 
	endif
		
	cQuery += "	AND NJM.D_E_L_E_T_ != '*' "
	
	//CASUL
	If nConsNF == 1 //1=SIM  2=NAO 3=AMBOS
 	cQuery += "	AND NJM.NJM_DOCNUM <> '' "
	ElseIf nConsNF == 2 //1=SIM  2=NAO 3=AMBOS
 	cQuery += "	AND NJM.NJM_DOCNUM == '' "
	EndIf
	cQuery += " GROUP BY  B1_DESC,NJJ_DATA,NJJ_FILIAL,NJJ_TIPO,NJJ_PLACA,NJJ_STATUS,NJJ_STSPES,NJM_TES,"
	cQuery += "           NJM_CODENT,NJM_LOJENT,NJM_CODPRO,NJM_FILIAL,NJM_CODROM,NJM_DOCNUM,NJJ_X_QBT,NJM_TIPO,"
	cQuery += "           NJJ_PESO1,NJJ_PESO2,NJJ_PESO3,NJJ_PSLIQU "

 //Casul - Daniel - adicionar o UNION -> NF Complemento
 cQuery += RQryNFCp()
 
 //Casul - Daniel - adicionar o UNION -> NF/PV sem Romaneio -> PODER3
 cQuery += RQryNFPV()

	//cquery += " ORDER BY NJJ_FILIAL,NJM.NJM_CODENT, NJM.NJM_LOJENT, NJM.NJM_CODCTR, 1 , NJJ_DATA ASC" //1 é a coluna Calculada por tp.movto Entrada ou Saida
 cquery += " ORDER BY NJJ_FILIAL,NJM.NJM_CODENT, NJM.NJM_LOJENT, NJJ_DATA ASC, 1, NJM_DOCNUM " //1 é a coluna Calculada por tp.movto Entrada ou Saida
	cQuery:= ChangeQuery(cQuery)

	If select("QryNJM") <> 0
		QryNJM->( dbCloseArea() )
	endif

	TCQUERY cQuery NEW ALIAS "QryNJM"
	
	Count To nRecCount			//Contando o registro da query
		
	oReport:SetMeter( nRecCount )

//-- Visao do Header , quebra na ordem: Entidade,Fazenda(lja),Produto, no Footer é ao contrario 1o/Produto,Fazenda(lja),Entidade --
	cQuebra1 := ''	// Quebra Por Entidade
	cQuebra2 := ''	// Quebra Por Entidade e Loja
	cQuebra3 := ''	//	Quebra Por Produto
	nLine:=0
	
	///Osec2:cell('EMISSAO'):lheadersize := .f.
	oSec2:Init()
	
	QryNJM->( DbGoTop() )
	nCont := 0

	
	While (.t.)//QryNJM->(!Eof())
		IF oReport:Cancel()
			Exit
		EndIF
	
		oReport:IncMeter()
		
		//--Verificando se as Quebras iram acontecer na Proxima Linha Se Sim, forço a imprimir os totais--/
		IF oBreak1:Execute(.f.)   //Produto
			fSaltaPage(3) //Tenho q imprimir 2 linhas a do total + a linha do rodape
			oReport:SkipLine()
			oreport:PrintText (STR0018 ,oreport:row() 	, 10) //"Total do Produto"
			IIF(lPlanilha, oBreak1:Printtotal(),fTotProd() ) 
			lImpLine := .t.
		EndIF
		IF oBreak2:Execute(.f.) //Loja
			fSaltaPage(3)//Tenho q imprimir 2 linhas a do total + a linha do rodape
			oReport:SkipLine()
			oreport:PrintText ("Total da Loja (Propriedade)",oreport:row() 	, 10) //"Total da Loja"
			IIF(lPlanilha, oBreak2:Printtotal(),fTotLoja() )
			lImpLine := .t.
		EndIF
		IF oBreak3:Execute(.f.) //Entidade
			fsaltaPage(3) //Tenho q imprimir 2 linhas a do total + a linha do rodape
			oReport:SkipLine()
			oreport:PrintText ("Total da Entidade (Produtor)" ,oreport:row() 	, 10) //"Total da Entidade"
			IIF(lPlanilha, oBreak3:Printtotal(),fTotEnt() )
			lImpLine := .t.
		EndIF
		//-- Qdo Tem Quebra apos o Total , preciso imprimir uma Linha para separar o total dos titulos Entidade,Loja,Produto --//
		IF limpLine == .t.
			IF !fSaltaPage(2)
			    oReport:SkipLine()
				oReport:Fatline()
				//oreport:Skipline()
				limpline := .f.
			EndIF
		EndIF
		
		//--Se for fim de arquivo deve-se Sair do Loop-//
		IF QryNJM->(Eof())
		   Exit
		EndIf
		//--------------------------------------------//
		
		//Casul - Daniel
		cF4_PODER3 := GetAdvfVal("SF4","F4_PODER3",xFilial("SF4") + QryNJM->NJM_TES,1)
  If cF4_PODER3 == "N"
  	QryNJM->(DbSkip())
  	Loop
  EndIf		

	// -- Verificando se A Entidade Mudou Para imprimir os Dados da Entidade -- //	
		IF cQuebra1 != QryNJM->NJM_CODENT
			cQuebra1 	:= QryNJM->NJM_CODENT
			cAux		:= AlltRim(QryNJM->NJM_CODENT) + "-" + POSICIONE('NJ0',1,XFILIAL('NJ0')+QryNJM->NJM_CODENT+QryNJM->NJM_LOJENT,'NJ0_NOME')
			oreport:nFontBody 	:=08 //Aumento a Fonte Para 08
				////oSecEntd:Cell( "Entidade"	):SetValue( cAux ) N.Usei a secao, poise os spacos stao baguncando
			fSaltaPage(2) ////Verifica se precisa Saltar a Pagina
			oreport:PrintText ( cAux 			,oreport:row() 	, 10)
			oreport:SkipLine(2) //oreport:incrow(50) // Pula 25 Pixels
		EndIF
	// -- Verificando se A Entidade e Loja Mudou Para imprimir os Dados da Loja (Fazenda)-- //
		IF cQuebra2 != QryNJM->(NJM_CODENT 	+ NJM_LOJENT)
			cQuebra2 	:= QryNJM->(NJM_CODENT 	+ NJM_LOJENT)
			cAux		:= Alltrim(QryNJM->NJM_CODENT) 	+ '-' + QryNJM->NJM_LOJENT + "-" + POSICIONE('NJ0',1,XFILIAL('NJ0')+QryNJM->NJM_CODENT+QryNJM->NJM_LOJENT,'NJ0_NOMLOJ')
			cAux		+= " - " + STR0021 //"Inscrição :"
			cAux		+= Alltrim(Posicione( "NJ0", 1, xFilial( "NJ0" ) + QryNJM->( NJM_CODENT+NJM_LOJENT ), "NJ0_INSCR" ))
			
			oreport:nFontBody := 08 //Aumento a Fonte Para 08
				////oSecEntdLja:Cell( "EntdLja"		):SetValue( cAux ) N.Usei a secao, poise os spacos stao baguncando
			fSaltaPage(2) //Verifica se precisa Saltar a Pagina
			oreport:PrintText ( cAux 			,oreport:row() 	, 30)
			oreport:SkipLine(2)//oreport:incrow(50) // Pula 25 Pixels
		EndIF
			
	// -- Verificando Se o Produto Mudou Para imprimir os Dados do Produto-- //
		IF cQuebra3 != QryNJM->(NJM_CODENT + NJM_LOJENT 	+ NJM_CODPRO )
			cQuebra3	:= QryNJM->(NJM_CODENT + NJM_LOJENT 	+ NJM_CODPRO )
			cAux		:= AllTrim(QryNJM->NJM_CODPRO)  + "-"		+ QryNJM->B1_DESC

			oreport:nFontBody := 08 //Aumento a Fonte Para 08
				///oSecProd:Cell( "Produto"	):SetValue( cAux ) N.Usei a secao, poise os spacos stao baguncando
			fSaltaPage(2) //Verifica se precisa Saltar a Pagina
			oreport:PrintText ( cAux 			,oreport:row() 	, 60)
			oReport:SkipLine(2)//oreport:incrow(50) // Pula 25 Pixels
		EndIF
		
		///oReport:nLineHeight:=30
		oreport:nFontBody := 6 // Retorno a Fonte ao Tamanho Normal.
		
		cPrnFil 	:= Alltrim(QryNJM->NJM_FILIAL)
		dEmissao	:= StoD(QryNJM->NJJ_DATA)
		cFilRom 	:= QryNJM->NJJ_FILIAL	
		cTipoRo 	:= Substr(Posicione("SX5",1,xFilial("SX5")+"K5"+QryNJM->NJJ_TIPO,"X5DESCRI()"),2,1)
		cTipoRo 	+= QryNJM->NJJ_TIPO
		cCodRom 	:= QryNJM->NJM_CODROM
		cCodCtr	 := RCodCtr(QryNJM->NJJ_FILIAL, QryNJM->NJM_CODROM)//QryNJM->NJM_CODCTR 
		cPlaca		 := QryNJM->NJJ_PLACA
		cDocto		 := QryNJM->NJM_DOCNUM //QryNJM->NJM_DOCSER + " " + QryNJM->NJM_DOCNUM
		nPeso1 	 := QryNJM->NJJ_PESO1
		nPeso2 	 := QryNJM->NJJ_PESO2
		nPeso3	  := QryNJM->NJJ_PESO3
//		nDesconto 	:= QryNJM->DESCONTO
		nDesconto:= QryNJM->DESCONTO + (QryNJM->NJJ_PSLIQU - QryNJM->NJJ_PESO3)
		nPercRom := QryNJM->NJM_PERDIV
		//Verificando se o item do Romaneio e 100 % da Carga 
		IF ! nPercRom=100
			nPeso1 	*= nPercRom / 100
			nPeso2 	*= nPercRom / 100
			nDesconto 	*= nPercRom / 100
		EndIF
  nQuebraT := QryNJM->NJJ_X_QBT 
  nQuebra  := nDesconto - nQuebraT 
  		
		nPesoBruto := ( nPeso1 - nPeso2 )	
//		nPesoBruto := nPeso3
	
		//--Identifica Transgenia, o cIdTransg é o Tipo de Desconto inf. Pelo Usuario --//
		cResTransg	:=''
		dBselectArea("NJK")
		NJK->( dbSetOrder( 1 ) )	//NJK_FILIAL+NJK_CODROM+NJK_ITEM
		NJK->( dbSeek( fWxFilial( "NJK" ) + QryNJM->NJM_CODROM ) )
		While ! NJK->( Eof() ) .and. NJK->(NJK_FILIAL+NJK_CODROM)== fWxFilial( "NJK" ) + QryNJM->NJM_CODROM
			IF AllTrim(cIdTransg) == Alltrim(NJK->NJK_CODDES)
				cResTransg := NJK->NJK_DESRES
			Endif
			NJK->( DbSkip() )
		EndDo
		IF Len(Alltrim(cResTransg)) > 14  //14 Eh o tamanho q cabe no papel porem o sistema tem uma var de 40
			cResTransg := Substr(AllTrim(cResTransg),1,14)+'.'
		EndIF	
		//cResTransg := "MZMZMZMZMZMZMZ."
		//cDocto:='99999999@'
	   //--Identificando os Descontos--//
		cDesctos	:= MV_PAR19
		cCodRom 	:= QryNJM->NJM_CODROM
		
		//--O Retorno é o Vr. Já proporcional ao NJM_PERDIV--// 
		fGAnalise(cdesctos,cFilRom,cCodRom,@nValor1,@nDesc1,@nValor2,@nDesc2,@nValor3,@nDesc3,@nValor4,@nDesc4,@nValor5,@nDesc5,@nValor6,@nDesc6)
	
  //--	Como o romaneio pode ter o maior peso tanto no peso1 qto no peso2 a logica abaixo
  //-- 	é para garantir que peso bruto e liquido sejam sempre positivos qdo for romaneio 
  //--	de entrada e sempre negativos qdo for romaneio de saida
 	IF QryNJM->TpRom == 'E' .and. nPesoBruto < 1 		//Romaneio de Entrada com o PesoBruto Negativo
   nPesoBruto *= -1
 	 //  nPesoLiq 	*= -1
		ElseIF QryNJM->TpRom == 'S' .and. nPesoBruto > 0 //Romaneio de Saida com Peso Bruto Positivo
			//Casul - Daniel
			//2Pes = 0 E Status <> Confirmado E Status pesagem = 2=2Pesagem
 		If QryNJM->NJJ_PESO2 == 0 .And. QryNJM->NJJ_STATUS <> "3" .And. QryNJM->NJJ_STSPES == "2" 
	   //Nao multiplica por -1 pois ja fez 2pesagem porem de uma rotina que nao gravou NNJ_PESO2
	   //entao o PESO1 sera o Bruto
	   nDesconto := 0 	
	 	EndIf
			nPesoBruto	*= -1
		EndIF
		//-- Pronto agora sempre q for romaneio de saida tem peso bruto negativo e Entrada PesoBruto Positivo
    
  nPesoLiq := nPesoBruto - nDesconto
	       	   		
		if QryNJM->TpRom == 'S' .and.  nPesoBruto < 1  // se for romaneio de saida e o peso bruto for negativo, soma o desconto
		      nPesoLiq := nPesoBruto + nDesconto 
		endIF	
	 
	   
//--Abastecendo as Celulas da Seção--//
		oSec2:Cell( "FILIAL"		):SetValue( cPrnFil 			)
		oSec2:Cell( "EMISSAO"	):SetValue( DtoC(dEmissao) 	)
		oSec2:Cell( "TPMVTO"		):SetValue( cTipoRo 			)		
		oSec2:Cell( "ROMAN" 		):SetValue( cCodRom 			)
		oSec2:Cell( "CONTRATO"	):SetValue( cCodCtr			)
		oSec2:Cell( "PLACA"		):SetValue( cPlaca 			)
		oSec2:Cell( "PESO1"		):SetValue( nPeso1 			)
		oSec2:Cell( "PESO2" 		):SetValue( nPeso2 			)
		oSec2:Cell( "PESOBRUTO"	):SetValue( nPesoBruto 		)
		//oSec2:Cell( "DESCONTOS"	):SetValue( nDesconto  		)
		oSec2:Cell( "QUEBRA"	):SetValue( nQuebra  		)
		oSec2:Cell( "QUEBRAT"	):SetValue( nQuebraT  		)
		oSec2:Cell( "PESOLIQ"	):SetValue( nPesoLiq			)
		oSec2:Cell( "DOCTO"		):SetValue( cDocto			)		
//		oSec2:Cell( "TRANSGENIA"	):SetValue(cResTransg		)
		oSec2:Cell( "VRDESC1"	):SetValue( nValor1 			)
		oSec2:Cell( "DESC1"		):SetValue( nDesc1 			)
		oSec2:Cell( "VRDESC2"	):SetValue( nvalor2			)
		oSec2:Cell( "DESC2"		):SetValue( nDesc2			)
		oSec2:Cell( "VRDESC3"	):SetValue( nValor3			)
		oSec2:Cell( "DESC3"		):SetValue( nDesc3			)
		oSec2:Cell( "VRDESC4"	):SetValue( nValor4			)
		oSec2:Cell( "DESC4"		):SetValue( nDesc4			)
		oSec2:Cell( "VRDESC5"	):SetValue( nValor5			)
		oSec2:Cell( "DESC5"		):SetValue( nDesc5			)
		oSec2:Cell( "VRDESC6"	):SetValue( nValor6			)
		oSec2:Cell( "DESC6"		):SetValue( nDesc6			)
		
		vVetGera[1] += nPeso1
		vVetGera[2] += nPeso2
		vVetGera[3] += nPesoBruto
		//vVetGera[4] += nDesconto
		vVetGera[4] += nQuebra
		vVetGera[5] += nQuebraT
		vVetGera[6] += nPesoLiq
		lTemdado := .t.
		
		//colocar o totalizador de produto -- verifica se existe e coloca ele na posição (soma valores) 
	    nPos  := aScan(aTotalPro,{|x| AllTrim(x[1]) == "C" + Alltrim(QryNJM->NJM_CODPRO) })
	    If nPos > 0
	    	//soma dados
	    	aTotalPro[nPos][3] += nPeso1 //"PESO1"
	    	aTotalPro[nPos][4] += nPeso2 //"PESO2"
	    	aTotalPro[nPos][5] += nPesoBruto //"PESOBRUTO"
	    	aTotalPro[nPos][6] += nDesconto //"DESCONTOS"   
	    	aTotalPro[nPos][7] += nPesoLiq //"PESOLIQ"  
	    	aTotalPro[nPos][8] += nValor1 //VRDESC1
	        aTotalPro[nPos][9] += nDesc1 //DESC1
			aTotalPro[nPos][10] += nValor2 //VRDESC1
			aTotalPro[nPos][11] += nDesc2 //DESC1			
			aTotalPro[nPos][12] += nValor3 //VRDESC1
			aTotalPro[nPos][13] += nDesc3 //DESC1			
			aTotalPro[nPos][14] += nValor4 //VRDESC1
			aTotalPro[nPos][15] += nDesc4 //DESC1			
			aTotalPro[nPos][16] += nValor5 //VRDESC1
			aTotalPro[nPos][17] += nDesc5 //DESC1			
			aTotalPro[nPos][18] += nValor6 //VRDESC1
			aTotalPro[nPos][19] += nDesc6 //DESC1
			aTotalPro[nPos][20] += 1 //Contador de item	
			aTotalPro[nPos][21] += nQuebra //"DESCONTOS"   
			aTotalPro[nPos][22] += nQuebraT //"DESCONTOS"   
			 	    		
	    else
	        /*cria novo*/
	        aadd (aTotalPro, {"C"+Alltrim(QryNJM->NJM_CODPRO), QryNJM->B1_DESC, nPeso1, nPeso2 ,nPesoBruto	, nDesconto, nPesoLiq, nValor1, nDesc1, nValor2, nDesc2, nValor3, nDesc3, nValor4, nDesc4, nValor5, nDesc5, nValor6, nDesc6, 1,;
	                          nQuebra, nQuebraT  } )   
	    end.
		
		fSaltaPage(1) 	//Verifica se Salta Pagina
		oSec2:Show()		//Indica que a seçao irá aparecer
		
		IF !lPlanilha //Verifica se n. é impressão em planilha
			//--Qdo não é em planilha imprimo de forma manual devido ao ncolspace n. funcionar como necessario, forçando a quebrar
			//--a impressão em linha qdo o papel é A4 o que não queremos.
		
			oreport:PrintText (cPrnFil,			oreport:row() 			, 	nPosColA)
			oreport:PrintText (DtoC(dEmissao),	oreport:row() 			, 	nPosColB)
			oreport:PrintText (cTipoRo,			oreport:row() 			, 	nPosColC)
			oreport:PrintText (cCodRom,			oreport:row() 			, 	nPosColD)
			oreport:PrintText (cCodCtr,			oreport:row() 			, 	nPosColE)
		
			oreport:PrintText (Transform(cPlaca,						"@R! AAA-9999"),		oreport:row()	, 	nPosColF)
			oreport:PrintText (Transform(nPeso1,						"@E 9999,999,999"),	oreport:row()	, 	nPosColG)  
			oreport:PrintText (Transform(nPeso2,						"@E 9999,999,999"),	oreport:row()	, 	nPosColH)  
			oreport:PrintText (Transform(nPesoBruto,					"@E 9999,999,999"),	oreport:row()	, 	nPosColI)  
			//oreport:PrintText (Transform(nDesconto,					"@E 9999,999,999"),	oreport:row()	, 	nPosColJ)
   oreport:PrintText (Transform(nQuebra,					"@E 9999,999,999"),	oreport:row()	, 	nPosColJ) //CASUL			  
   oreport:PrintText (Transform(nQuebraT,				"@E 9999,999,999"),	oreport:row()	, 	nPosColJ1)			  
			oreport:PrintText (Transform(nPesoLiq          ,		"@E 9999,999.9999"),	oreport:row()	, 	nPosColK)  
			oreport:PrintText (cDocto,			oreport:row()	, 	nPosColK1) 
			//oreport:PrintText (cResTransg,		oreport:row() , 	nPosColL)
		
			AaUX := {}
			aAux 	:= separa(MV_PAR19, ';')
			For	nI:=Len(aAux) to 6
				aAdd(aAux,'')
			nExt nI
			IF ! Empty(aAux[1] )
				oreport:PrintText (Transform(nValor1 	,"@E 99,999.99"),oreport:row() 	, 	nPosColM)  	//80
				oreport:PrintText (Transform(nDesc1 	,"@E 9999,999" ),oreport:row() 	, 	nPosColN)	// 110
			EndIF

			IF ! Empty(aAux[2] )
				oreport:PrintText (Transform(nValor2	,"@E 99,999.99"),oreport:row() 	, 	nPosColO)  	//80
				oreport:PrintText (Transform(nDesc2 	,"@E 9999,999" ),oreport:row() 	, 	nPosColP)	// 110
			EndIF

			IF ! Empty(aAux[3] )
				oreport:PrintText (Transform(nValor3	,"@E 99,999.99"),oreport:row() 	, 	nPosColQ)  	//80
				oreport:PrintText (Transform(ndesc3		,"@E 9999,999" ),oreport:row() 	, 	nPosColR)	// 110
			EndIF
		
			IF ! Empty(aAux[4] )
				oreport:PrintText (Transform(nValor4	,"@E 99,999.99"),oreport:row() 	, 	nPosColS)  	//80
				oreport:PrintText (Transform(nDesc4		,"@E 9999,999" ),oreport:row() 	, 	nPosColT)	// 110
			EndIF
		
			IF ! Empty(aAux[5] )
				oreport:PrintText (Transform(nValor5	,"@E 99,999.99"),oreport:row() 	, 	nPosColU)  	//80
				oreport:PrintText (Transform(nDesc5		,"@E 9999,999" ),oreport:row() 	, 	nPosColV)	// 110
			EndIF

			IF ! Empty(aAux[6] )
				oreport:PrintText (Transform(nValor6	,"@E 99,999.99"),oreport:row() 	, 	nPosColX)  	//80
				oreport:PrintText (Transform(nDesc6		,"@E 9999,999" ),oreport:row() 	, 	nPosColZ)	// 110
			EndIF
			oSec2:Hide()
			oReport:SkipLine(1)	
		EndIF
		
		oSec2:Printline()
		QryNJM->(DbSkip())	
	Enddo

	QryNJM->( dbCloseArea() )
	
	/*busca os totais*/
	if ! Empty(aTotalPro)
		oReport:OnPageBreak({|| fPrnCabEsp("T") /*Cabeçalho Principal*/  })  
		oReport:SkipLine(1) 
				
		IF ! fSaltaPage(3)  //Verifica se precisa Saltar a Pagina
  		   oreport:PrintText ( "TOTAIS POR PRODUTO" ,oreport:row() 	, 10)
  		   oReport:SkipLine(1)
		   fPrnCabEsp("T") /*Cabeçalho total*/
		Else
		 oreport:PrintText ( "TOTAIS POR PRODUTO" ,oreport:row() 	, 10)
		 oReport:SkipLine(1)
		EndIf
		   
		oSec3:Init()   
		oSec3:show()
		
		for  nx := 1 To Len(aTotalPro) 
		
		    oSec3:Cell("PRODUTO"):SetValue( aTotalPro[nx][2] )
			oSec3:Cell("PESO1"):SetValue( aTotalPro[nx][3] )
	    	oSec3:Cell("PESO2"):SetValue( aTotalPro[nx][4] )
	    	oSec3:Cell("PESOBRUTO"):SetValue( aTotalPro[nx][5] )
	    	//oSec3:Cell("DESCONTOS"):SetValue( aTotalPro[nx][6] )
	    	oSec3:Cell("QUEBRA"):SetValue( aTotalPro[nx][21] ) //CASUL
	    	oSec3:Cell("QUEBRAT"):SetValue( aTotalPro[nx][22] ) //CASUL
	    	oSec3:Cell("PESOLIQ"):SetValue( aTotalPro[nx][7] )  
	    	oSec3:Cell("VRDESC1"):SetValue( aTotalPro[nx][8] / aTotalPro[nX, 20] ) //average
	        oSec3:Cell("DESC1"):SetValue( aTotalPro[nx][9] )
			oSec3:Cell("VRDESC2"):SetValue( aTotalPro[nx][10] / aTotalPro[nX, 20] ) //average
			oSec3:Cell("DESC2"):SetValue( aTotalPro[nx][11] )		
			oSec3:Cell("VRDESC3"):SetValue( aTotalPro[nx][12] / aTotalPro[nX, 20] ) //average
			oSec3:Cell("DESC3"):SetValue( aTotalPro[nx][13] )	 
			oSec3:Cell("VRDESC4"):SetValue( aTotalPro[nx][14] / aTotalPro[nX, 20] ) //average
			oSec3:Cell("DESC4"):SetValue( aTotalPro[nx][15] )			
			oSec3:Cell("VRDESC5"):SetValue( aTotalPro[nx][16] / aTotalPro[nX, 20] ) //average
			oSec3:Cell("DESC5"):SetValue( aTotalPro[nx][17] )			
			oSec3:Cell("VRDESC6"):SetValue( aTotalPro[nx][18] / aTotalPro[nX, 20] ) //average
			oSec3:Cell("DESC6"):SetValue( aTotalPro[nx][19] )	 
			
			IF !lPlanilha
				
				oreport:PrintText (aTotalPro[nx][2],			oreport:row() 			, 	nPosColA) /*produto*/
			    oreport:PrintText (Transform( aTotalPro[nx][3],		"@E 9999,999,999"),	oreport:row()	, 	nPosColG)  
				oreport:PrintText (Transform( aTotalPro[nx][4],		"@E 9999,999,999"),	oreport:row()	, 	nPosColH)  
				oreport:PrintText (Transform( aTotalPro[nx][5],		"@E 9999,999,999"),	oreport:row()	, 	nPosColI)  
				//oreport:PrintText (Transform( aTotalPro[nx][6],		"@E 9999,999,999"),	oreport:row()	, 	nPosColJ)
				oreport:PrintText (Transform( aTotalPro[nx][21],		"@E 9999,999,999"),	oreport:row()	, 	nPosColJ)  
				oreport:PrintText (Transform( aTotalPro[nx][22],		"@E 9999,999,999"),	oreport:row()	, 	nPosColJ1)  
				oreport:PrintText (Transform( aTotalPro[nx][7],		"@E 9999,999,999"),	oreport:row()	, 	nPosColK)  
			
				AaUX := {}
				aAux 	:= separa(MV_PAR19, ';')
				For	nI:=Len(aAux) to 6
					aAdd(aAux,'')
				nExt nI
				IF ! Empty(aAux[1] )
					oreport:PrintText (Transform(aTotalPro[nx][8] / aTotalPro[nX, 20]  	,"@E 99,999.99"),oreport:row() 	, 	nPosColM)  	//80
					oreport:PrintText (Transform(aTotalPro[nx][9] 						,"@E 9999,999" ),oreport:row() 	, 	nPosColN)	// 110
				EndIF
	
				IF ! Empty(aAux[2] )
					oreport:PrintText (Transform(aTotalPro[nx][10] / aTotalPro[nX, 20] 	,"@E 99,999.99"),oreport:row() 	, 	nPosColO)  	//80
					oreport:PrintText (Transform(aTotalPro[nx][11] 						,"@E 9999,999" ),oreport:row() 	, 	nPosColP)	// 110
				EndIF
	
				IF ! Empty(aAux[3] )
					oreport:PrintText (Transform(aTotalPro[nx][12] / aTotalPro[nX, 20] 	,"@E 99,999.99"),oreport:row() 	, 	nPosColQ)  	//80
					oreport:PrintText (Transform(aTotalPro[nx][13]						,"@E 9999,999" ),oreport:row() 	, 	nPosColR)	// 110
				EndIF
			
				IF ! Empty(aAux[4] )
					oreport:PrintText (Transform(aTotalPro[nx][14] / aTotalPro[nX, 20] 	,"@E 99,999.99"),oreport:row() 	, 	nPosColS)  	//80
					oreport:PrintText (Transform(aTotalPro[nx][15]						,"@E 9999,999" ),oreport:row() 	, 	nPosColT)	// 110
				EndIF
			
				IF ! Empty(aAux[5] )
					oreport:PrintText (Transform(aTotalPro[nx][16] / aTotalPro[nX, 20] 	,"@E 99,999.99"),oreport:row() 	, 	nPosColU)  	//80
					oreport:PrintText (Transform(aTotalPro[nx][17]						,"@E 9999,999" ),oreport:row() 	, 	nPosColV)	// 110
				EndIF
	
				IF ! Empty(aAux[6] )
					oreport:PrintText (Transform(aTotalPro[nx][18] / aTotalPro[nX, 20] 	,"@E 99,999.99"),oreport:row() 	, 	nPosColX)  	//80
					oreport:PrintText (Transform(aTotalPro[nx][19]						,"@E 9999,999" ),oreport:row() 	, 	nPosColZ)	// 110
				EndIF
				oSec3:Hide()
				oReport:SkipLine(1)	
			
			endif
			
			oSec3:PrintLine( )	
		end.
		
		oSec3:Finish()
	end.
	
	If lTemdado 
  vVetColG := {nPosColG,nPosColH,nPosColI,nPosColJ,nPosColJ1,nPosColK}	
 	For nx := 1 To 6
 		oreport:PrintText("____________",oreport:row(),vVetColG[nx])
 	Next nx
 	oReport:SkipLine(1)
 	oreport:PrintText("TOTAIS GERAL",oreport:row(),10)
 	For nx := 1 To 6
 		If nx == 6 
 		 oreport:PrintText(Transform(vVetGera[nx],"@E 999,999.9999"),oreport:row(),vVetColG[nx])
 		Else
 		 oreport:PrintText(Transform(vVetGera[nx],"@E 9999,999,999"),oreport:row(),vVetColG[nx])
 		EndIf 
 	Next nx
 EndIf   		
Return oReport

/*
@param: String cPerg -- String com o nome da pergunta
@description: Funcao para criacao das perguntas
@author: Emerson Coelho
@since: 09/09/2013
@return: empty
*/
Static Function AjustaSX1( )
///Local cPerg	:= 'OGR295'

	Local ahelpPor	:= {}
	
//--Filial de / Até
	aTam 		:= TamSX3("NJJ_FILIAL")
	ahelpPor	:= {}
	
	aAdd(aHelpPor,STR0023) //"Informe a filial inicial"
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"01", STR0024,"","","mv_chA",aTam[3],aTam[1],aTam[2],0,"G","","XM0","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Filial  de?"	
	
	ahelpPor	:= {}
	aAdd(aHelpPor, STR0025) //"Informe a filial final "
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos	
	
	PutSx1(cPerg,"02",STR0026	,"","","mv_chB",aTam[3],aTam[1],aTam[2],0,"G","","XM0","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Filial até?"

//Entidade/loja de	
	aTam 		:= TamSX3("NJ0_CODENT")
	aHelpPor 	:= {}
	aAdd(aHelpPor,STR0027) // "Informe a entidade inicial "
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos	 
	PutSx1(cPerg,"03",STR0028 ,"","","mv_chC",aTam[3],aTam[1],aTam[2],0,"G","","NJ0","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Entidade  de?"
	aTam 		:= TamSX3("NJ0_LOJENT")
	aHelpPor 	:= {}
	
	aAdd(aHelpPor,STR0029) //"Informe a loja inicial"
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"04",STR0030 ,"","","mv_chD",aTam[3],aTam[1],aTam[2],0,"G","",/*"NJ0"*/,"","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Loja de?"

//Enditade/loja até	
	aTam 		:= TamSX3("NJ0_CODENT")
	aHelpPor 	:= {}
	aAdd(aHelpPor, STR0031) //"Informe a entidade final   "
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"05", STR0032 ,"","","mv_chE",aTam[3],aTam[1],aTam[2],0,"G","","NJ0","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Entidade até?"

	aTam := TamSX3("NJ0_LOJENT")
	aHelpPor := {}
	aAdd(aHelpPor,STR0033) //"Informe a loja final "
    aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"06",STR0034 ,"","","mv_chF",aTam[3],aTam[1],aTam[2],0,"G","",/*"NJ0"*/,"","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Loja até?"

//--<< Contrato De ? Até ?
	aTam 		:= TamSX3("NJR_CODCTR")
	aHelpPor 	:= {}
	aAdd(aHelpPor,STR0035 ) //"Informe o contrato inicial que será    "
	aAdd(aHelpPor,STR0074) //que será considerado
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"07",STR0036 ,"","","mv_chG",aTam[3],aTam[1],aTam[2],0,"G","","NJR","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Contrato  de?"

	aTam 		:= TamSX3("NJR_CODCTR")
	aHelpPor 	:= {}
	aAdd(aHelpPor,STR0037) //"Informe o contrato final que será      "
    aAdd(aHelpPor,STR0074) //que será considerado
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"08",STR0038 ,"","","mv_chH",aTam[3],aTam[1],aTam[2],0,"G","","NJR","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Contrato até?"

//--<< Safra De?/Até >>--
	aTam := TamSX3("NJR_CODSAF")
	aHelpPor := {}
	
	aAdd(aHelpPor, STR0039 ) //"Informe a safra inicial "
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"09",STR0040,"","","mv_chI",aTam[3],aTam[1],aTam[2],0,"G","","NJU","","","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,{},{}) // "Safra De?"
	
	aHelpPor := {}
	aAdd(aHelpPor,STR0041 ) //"Informe a safra final  "
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"10",STR0042,"","","mv_chJ",aTam[3],aTam[1],aTam[2],0,"G","","NJU","","","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,{},{}) // "Safra Até?   "

//--Data a ser considerada{ Todos,Fisico,Gerencial,Simbolico }
    aHelpPor := {}
    aAdd(aHelpPor,STR0085 ) //"Informe o tipo de romaneio"
    aAdd(aHelpPor,STR0074) //que será considerado
    aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
    PutSx1(cPerg,"11",STR0086 ,"","","mv_chk",'N',1,0,0,"C","","","","","mv_par11",STR0087,"","","",STR0088,"","",STR0089,"","",STR0090,"","",STR0091,"","",aHelpPor,{},{}) //"Data do Romaneio" - "NJJ_DATA"; "Data da Pesagem 1" - "NJJ_DATPS1"; "Data da Pesagem 2" - "NJJ_DATPS2"; "Emissao do Documento Fiscal" - "NJM_DOCEMI"; "Data da Transação" -  "NJM_DTRANS"
    //"Data do Romaneio" - "NJJ_DATA"; "Data da Pesagem 1" - "NJJ_DATPS1"; "Data da Pesagem 2" - "NJJ_DATPS2"; "Emissao do Documento Fiscal" - "NJM_DOCEMI"; "Data da Transação" -  "NJM_DTRANS"

//--<< Data De/até >>--
	aTam := TamSX3("NJR_DATA")
	aHelpPor := {}
	aAdd(aHelpPor,STR0043 ) //"Informe a data inicial       "
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"12",STR0044,"","","mv_chl",aTam[3],aTam[1],aTam[2],0,"G","","","","","mv_par12","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Data  de?"
	aHelpPor := {}
	
	aAdd(aHelpPor,STR0045 ) //"Informe a data final "
	aAdd(aHelpPor,STR0073) //que será considerada
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos                                                                                 
	//aAdd(aHelpPor,"")
	PutSx1(cPerg,"13",STR0046 ,"","","mv_chm",aTam[3],aTam[1],aTam[2],0,"G","","","","","mv_par13","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Data Até?"


//--Grupo de/ate
	aTam := TamSX3("BM_GRUPO")
	aHelpPor := {}
	aAdd(aHelpPor,STR0047 ) //"Informe  o grupo de produtos inicial   "
	aAdd(aHelpPor,STR0074) //que será considerado
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"14",STR0048 ,"","","mv_chn",aTam[3],aTam[1],aTam[2],0,"G","","SBM","","","mv_par14","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Grupo  de?"

	aHelpPor := {}
	aAdd(aHelpPor,STR0049 ) //"Informe  o grupo  de  produtos final   "
	aAdd(aHelpPor,STR0074) //que será considerado
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"15",STR0050 ,"","","mv_cho",aTam[3],aTam[1],aTam[2],0,"G","","SBM","","","mv_par15","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Grupo Ate?"
	
	
//--<< Produto De?/Até >>--
	aTam := TamSX3("NJM_CODPRO")
	aHelpPor := {}
	aAdd(aHelpPor,STR0051 ) //"Informe o produto inicial    "
	aAdd(aHelpPor,STR0074) //que será considerado
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"16",STR0052 ,"","","mv_chp",aTam[3],aTam[1],aTam[2],0,"G","","SB1","","","mv_par16","","","","","","","","","","","","","","","","",aHelpPor,{},{})  //"Produto De?"
		
	aHelpPor := {}
	aAdd(aHelpPor,STR0053 ) //"Informe o produto final     "
	aAdd(aHelpPor,STR0074) //que será considerado
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"17",STR0054 ,"","","mv_chq",aTam[3],aTam[1],aTam[2],0,"G","","SB1","","","mv_par17","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Produto Até?   "

//--<< Cod. Classif.Transgenia >>--	
		
	aTam := TamSX3("NJK_CODDES")
	aHelpPor := {}
	aAdd(aHelpPor,STR0055 ) //"Informe o item de classificação  que  "
	aAdd(aHelpPor,STR0075) //identifica o resultado transgenea
	PutSx1(cPerg,"18",STR0056 ,"","","mv_chr",aTam[3],aTam[1],aTam[2],0,"G","","NNH","","","mv_par18","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Cod.da Transgenia?"
	
//--<< Cod. Descontos a Listar >>--
	aHelpPor := {}
	aAdd(aHelpPor,STR0057 )//"Informe 6 itens de descontos separados  "
	aAdd(aHelpPor,STR0076) //por (;) para serem listados.n Ex:01,02 
	PutSx1(cPerg,"19",STR0058 ,"","","mv_chs",aTam[3],80,aTam[2],0,"G","U_fOgrvldA()","NNH1","","","mv_par19","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Descontos a listar?"
//--Tipos de romaneios qto ao movimento {Todos,Entrada,Saida}
	aHelpPor := {}
	aAdd(aHelpPor,STR0059 ) //"Informe  que tipos  de movimentos       "
    aAdd(aHelpPor,STR0077) //ser considerados na impressao
	PutSx1(cPerg,"20",STR0060 ,"","","mv_cht",'N',1,0,0,"C","","/*F3*/","","","mv_par20",STR0063,"","","",STR0064,"","",STR0065,"","","","","","","","",aHelpPor,{},{}) //"Romaneio C/Movtos de?"//todos//entrada//saida

//--Tipos de romaneios { Todos,Fisico,Gerencial,Simbolico }
	aHelpPor := {}
	aAdd(aHelpPor,STR0061 ) //"Informe o tipo de romaneio"
	aAdd(aHelpPor,STR0074) //que será considerado
	aAdd(aHelpPor,STR0022) //na seleção dos dados impressos
	PutSx1(cPerg,"21",STR0062 ,"","","mv_chu",'N',1,0,0,"C","","/*F3*/","","","mv_par21",STR0063,"","","",STR0066,"","",STR0067,"","",STR0068,"","","","","",aHelpPor,{},{}) //"Tipos de Romaneio?"//todos//fisico//gerencial//simbolico

//--<< Cod. Status a Listar >>--
	aHelpPor := {}
	aAdd(aHelpPor,STR0082 )//"Informe 6 itens de descontos separados  "
	aAdd(aHelpPor,STR0076) //por (;) para serem listados.n Ex:0;1;2 
	PutSx1(cPerg,"22",STR0083 ,"","","mv_chv",aTam[3],80,aTam[2],0,"G","U_fOgr295vdB()","NJJSTS","","","mv_par22","","","","","","","","","","","","","","","","",aHelpPor,{},{}) //"Descontos a listar?"

//--Parecer da qualidade { 1=Nao se aplica,2=Aprovado,3=Reprovado,4=Requer Parecer,5=Todos }
//                         0=Nao se aplica;1=Aprovado;2=Reprovado;3=Requer Parecer
	aHelpPor := {}
//	aAdd(aHelpPor,STR0092)
//	PutSx1(cPerg,"23",STR0093,"","","mv_chx",'C',80,0,0,"G","fOgr295PQU()","NJJPQU","","","mv_par23","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	
	aHelpPor := {}
//	aAdd(aHelpPor,STR0094)
//	PutSx1(cPerg,"24",AGRTITULO("NJM_CODAUT"),"","","mv_chx",'C',80,0,0,"G","AGRSEQUEPV(mv_par24,3)","","","","mv_par24","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	
	AGRALTCONDIC("SX1",cPerg+"23",1,"X1_VALID",'AGRF3OPBOX("NJJ_LIBQLD")')
	AGRALTCONDIC("SX1",cPerg+"23",1,"X1_F3",'AGRBOX')
	
 //CASUL
	aHelpPor := {}
	aAdd(aHelpPor,"Informe se considera apenas Romaneios") 
	aAdd(aHelpPor,"com Notas Geradas") 
	aAdd(aHelpPor,"") 
	PutSx1(cPerg,"25","Apenas Com NF","","","mv_chy",'N',1,0,0,"C","","","","","mv_par25","SIM","","","","NAO","","","AMBOS","","","","","","","","",aHelpPor,{},{}) 


Return

/*
@param: Nil
@description: Funcao para Impressão de Cabeçalho especifico
				esta função ajusta o kbeçalho da seção
@author: Emerson Coelho
@since: 09/09/2013
@return: Impressao do kbeçalho conforme solicitado
*/


//--<< Imprime Cabeçalho Especifico na Pagina >>--
Static Function fPrnCabEsp(cModo)
***********************************

	Local aAux	:= {}
	Local nI	:= {}
																			
	aAux 	:= separa(MV_PAR19, ';')
	For	nI:=Len(aAux) to 6
		aAdd(aAux,'')
	nExt nI

	IF ! lPlanilha 	//Qdo não for impressão em Planilha
		//--Ajusta o Header da seção qdo será impresso --//
       //Printing Cod dos Desctos escolhidos Cab. dinamico//
		IIf(!Empty( aAux[1] ),oreport:PrintText (PADC( Alltrim(aAux[1]) ,14),oreport:row() 	, 	nPosColM),'')
		IIf(!Empty( aAux[2] ),oreport:PrintText (PADC( Alltrim(aAux[2]) ,14),oreport:row() 	, 	nPosColO),'')
		IIf(!Empty( aAux[3] ),oreport:PrintText (PADC( Alltrim(aAux[3]) ,14),oreport:row() 	, 	nPosColQ),'')
		IIf(!Empty( aAux[4] ),oreport:PrintText (PADC( Alltrim(aAux[4]) ,14),oreport:row() 	, 	nPosColS),'')
		IIf(!Empty( aAux[5] ),oreport:PrintText (PADC( Alltrim(aAux[5]) ,14),oreport:row() 	, 	nPosColU),'')
		IIf(!Empty( aAux[6] ),oreport:PrintText (PADC( Alltrim(aAux[6]) ,14),oreport:row() 	, 	nPosColX),'')

		oreport:SkipLine(1)
		
		IIf(!Empty( aAux[1] ),oreport:PrintText ("==============",oreport:row() 	, 	nPosColM),'')
		IIf(!Empty( aAux[2] ),oreport:PrintText ("==============",oreport:row() 	, 	nPosColO),'')
		IIf(!Empty( aAux[3] ),oreport:PrintText ("==============",oreport:row() 	, 	nPosColQ),'')
		IIf(!Empty( aAux[4] ),oreport:PrintText ("==============",oreport:row() 	, 	nPosColS),'')
		IIf(!Empty( aAux[5] ),oreport:PrintText ("==============",oreport:row() 	, 	nPosColU),'')
		IIf(!Empty( aAux[6] ),oreport:PrintText ("==============",oreport:row() 	, 	nPosColX),'')

		oreport:Skipline(1)
		
		if cModo = "P" /*Principal*/
			oreport:PrintText (PadR(STR0003,6),oreport:row() 			, 	nPosColA) //Filial
			oreport:PrintText (PadR(STR0004,8),oreport:row() 			, 	nPosColB) //Emissao
			oreport:PrintText (PadR(STR0005,2),oreport:row() 			, 	nPosColC) //TP
			oreport:PrintText (PadR(STR0006,10),oreport:row() 			, 	nPosColD) //Romaneio
			oreport:PrintText (PadR(STR0007,8),oreport:row() 			, 	nPosColE) //Contrato
			oreport:PrintText (PadR(STR0008,10),oreport:row() 			, 	nPosColF) //Placa
	
			oreport:PrintText (PadL(STR0009,12),oreport:row() 			, 	nPosColG)  //210 //1a Pesagem
			oreport:PrintText (PadL(STR0010,12),oreport:row() 			, 	nPosColH) //910  //2a Pesagem
			oreport:PrintText (PadL(STR0011,12),oreport:row() 			, 	nPosColI) //1120 //Liq.S/Descto
			//oreport:PrintText (PadL(STR0012,12),oreport:row() 			, 	nPosColJ) //1330 //Descontos
			oreport:PrintText (PadL("Quebra",12),oreport:row() 			, 	nPosColJ) //1330 //Descontos CASUL
			oreport:PrintText (PadL("Quebra Tecnica",12),oreport:row() 			, 	nPosColJ1) //1330 //Descontos CASUL
			oreport:PrintText (PadL(STR0013,12),oreport:row() 			, 	nPosColK) //1540 //Peso Liquido
			oreport:PrintText (PadR(STR0069,10),oreport:row() 			, 	nPosColK1) //1540 //Docto(NF)
		//	oreport:PrintText (PadR(STR0015,30),oreport:row() 			, 	nPosColL) //Transgenia
		
		elseif cModo = "T" /*Total*/
		
			oreport:PrintText (PadR("Produto",44),oreport:row() 		, 	nPosColA) //Filial

			oreport:PrintText (PadL(STR0009,12),oreport:row() 			, 	nPosColG)  //210 //1a Pesagem
			oreport:PrintText (PadL(STR0010,12),oreport:row() 			, 	nPosColH) //910  //2a Pesagem
			oreport:PrintText (PadL(STR0011,12),oreport:row() 			, 	nPosColI) //1120 //Liq.S/Descto
			//oreport:PrintText (PadL(STR0012,12),oreport:row() 			, 	nPosColJ) //1330 //Descontos
			oreport:PrintText (PadL("Quebra",12),oreport:row() 			, 	nPosColJ) //1330 //Descontos
			oreport:PrintText (PadL("Quebra Tecninca",12),oreport:row() 			, 	nPosColJ1) //1330 //Descontos
			oreport:PrintText (PadL(STR0013,12),oreport:row() 			, 	nPosColK) //1540 //Peso Liquido

		end.
		
		If !Empty( aAux[1] ) 
			oreport:PrintText (PadL(STR0070,5),oreport:row() 			, 	nPosColM)  	//80 //Resul
			oreport:PrintText (PadL(STR0071,8),oreport:row() 			, 	nPosColN)	// 110 //Descto
		EndIf

		If !Empty( aAux[2] )
			oreport:PrintText (PadL(STR0070,5),oreport:row() 			, 	nPosColO)  	//80 //Resul
			oreport:PrintText (PadL(STR0071,8),oreport:row() 			, 	nPosColP)	// 110 //Descto
		EndIF
		If !Empty( aAux[3] )
			oreport:PrintText (PadL(STR0070,5),oreport:row() 			, 	nPosColQ)  	//80 //Resul
			oreport:PrintText (PadL(STR0071,8),oreport:row() 			, 	nPosColR)	// 110 //Descto
		EndIF
		If !Empty( aAux[4] )
			oreport:PrintText (PadL(STR0070,5),oreport:row() 			, 	nPosColS)  	//80 //Resul
			oreport:PrintText (PadL(STR0071,8),oreport:row() 			, 	nPosColT)	// 110 //Descto
		EndIF
		If !Empty( aAux[5] )
			oreport:PrintText (PadL(STR0070,5),oreport:row() 			, 	nPosColU)  	//80 //Resul
			oreport:PrintText (PadL(STR0071,8),oreport:row() 			, 	nPosColV)	// 110 //Descto
		EndIF
		If !Empty( aAux[6] )
			oreport:PrintText (PadL(STR0070,5),oreport:row() 			, 	nPosColX)  	//80 //Resul
			oreport:PrintText (PadL(STR0071,8),oreport:row() 			, 	nPosColZ)	// 110 //Descto
		EndIF
		oReport:SkipLine(2)
		oReport:Fatline()
	
	Else
		if cModo = "P" /*Principal*/
			oSec2:SetHeaderSection(.t.)
			oSeC2:PrintHeader()
			oSec2:SetHeaderSection(.f.)
		elseif cModo = "T" /*Total*/
			oSec3:SetHeaderSection(.t.)
			oSeC3:PrintHeader()
			oSec3:SetHeaderSection(.f.)
		end.		
	EndIF

Return

/*
@param: 
		cDesctos 			= MV_PAR19, com os 6 codigos dos discontos a serem listados.
		cCodrom 			= Codigo do romaneio que está sendo impresso
		nValor1 a nValor6	= % de desconto que será retornado (passado via ponteiro)
		ndesc1  a nDesc6	= Qtd. do desconto	(Passado via Ponteiro)
@description: Função que encontra os descontos informados a serem listados pelo usuario
@author: Emerson Coelho
@since: 09/09/2013
@return: empty
*/

//--<<Abastece as 6 possibilidades de impressão de análise com os Dados, As mesmas viram como Ponteiros >>--

Static Function  fGAnalise(cdesctos,cFilRom,cCodRom,nValor1,nDesc1,nValor2,nDesc2,nValor3,nDesc3,nValor4,nDesc4,nValor5,nDesc5,nValor6,nDesc6)
	Local cquery	:= 0
	Local cAlias1	:= GetNextAlias()
	Local nI		:=0

	nValor1	:=0
	nDesc1		:=0
	nValor2	:=0
	nDesc2		:=0
	nValor3	:=0
	nDesc3		:=0
	nValor4	:=0
	nDesc4		:=0
	nValor5	:=0
	nDesc5		:=0
	nValor6	:=0
	nDesc6		:=0


	aAux :=  separa(cDesctos , ';')  //cDesctos (MV_PAR19) Descontos a serem listados.
	cTpDesctos	:=	""
	For nI:=1 to Len(aAux) sTep 1  // Tenho os Tps Movtos no formato: '001','002','003','501','503','504','550','551','600'
		cTpDesctos += "'" + Trim(aAux[nI]) + "'"
		IF ! nI = Len(aAux)
			cTpDesctos += " , "
		EndIF
	next nI
	cQuery:=''

	cQuery := " SELECT NJK_CODDES, NJK_PERDES, NJK_READES, NJK_QTDDES FROM " + RETSQLTAB("NJK")
	cQuery += " WHERE	NJK_CODROM	= '" 	+ cCodRom 				+ "'"
	cQuery += " AND NJK_CODDES	IN (" 	+ cTpDesctos 			+ ")"
	cQuery += " AND 	NJK_FILIAL = '" 	+ cFilRom 	+ "'"
	cQuery += " AND 	D_E_L_E_T_ !='*'"

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias1,.T.,.T.)
    
	aDesctos := {} // Array q conterá  6 Linhas com  Percentual de Desconto e a Qtd. de desconto.
   
	aAdd(aDesctos,{0,0})
	aAdd(aDesctos,{0,0})
	aAdd(aDesctos,{0,0})
	aAdd(aDesctos,{0,0})
	aAdd(aDesctos,{0,0})
	aAdd(aDesctos,{0,0})
	For nI := 1 to Len(aAux)
   
		While !(cAlias1)->(EOF())
	   
			IF Alltrim( aAux[nI] ) == Alltrim( (cAlias1)->NJK_CODDES )
				///aDesctos[nI,1] :=	(cAlias1)->NJK_READES // N. IRA MAIS PEGAR O PERCENTUAL DESCONTATO E SIM O QTO DEU DE UMIDADE
				aDesctos[nI,1] :=	(cAlias1)->NJK_PERDES
				aDesctos[nI,2] :=	(cAlias1)->NJK_QTDDES
				Exit
			EndIF
	
			(cAlias1)->(dbSkip())
		EndDo
	
		(cAlias1)->(DbGoTop())
	
	nExt nI
	
	(cAlias1)->( dBCloseArea() )

//--Abastecendo Variaveis de impressao --//	   
	nValor1 	:= 	aDesctos[1,1] 	//Percentual
	nDesc1		:=	aDesctos[1,2] 	//Qtd Desctada

	nValor2		:= 	aDesctos[2,1]
	nDesc2		:=	aDesctos[2,2]

	nValor3 	:= 	aDesctos[3,1]
	nDesc3		:=	aDesctos[3,2]

	nValor4 	:= 	aDesctos[4,1]
	nDesc4		:=	aDesctos[4,2]

	nValor5 	:= 	aDesctos[5,1]
	nDesc5		:=	aDesctos[5,2]

	nValor6 	:= 	aDesctos[6,1]
	nDesc6		:=	aDesctos[6,2]
	
//--Ajustando a Qtd. de Desconto Com a percentagem do Item no Romaneio --//
	IF !QryNJM->NJM_PERDIV = 100
		nDesc1		:=	Round((nDesc1 * QryNJM->NJM_PERDIV / 100), 0 )
		nDesc2		:=	Round((nDesc2 * QryNJM->NJM_PERDIV / 100), 0 )
		nDesc3		:=	Round((nDesc3 * QryNJM->NJM_PERDIV / 100), 0 )
		nDesc4		:=	Round((nDesc4 * QryNJM->NJM_PERDIV / 100), 0 )
		nDesc5		:=	Round((nDesc5 * QryNJM->NJM_PERDIV / 100), 0 )
		nDesc6		:=	Round((nDesc6 * QryNJM->NJM_PERDIV / 100), 0 )
	EndIF
//--Tenho Agora o % de Desconto e descontos, a listar --//	
Return()

//--Valida as Análises a Serem Impressas, Garante que o Array contenha 6 Tps Desctos Válidos --//
/*
@param: nil
@description: Função que Valida a pergunta ref. aos 6 descontos , garantindo que
              o MV_PAR19 sempre tenha 6 descontos separados por (;)
@author: Emerson Coelho
@since: 09/09/2013
@return: empty
*/

User Function fOgrvldA()
	Local lOk 		:= .t.
	Local nI		:=0
	local aAux 	:= Separa(MV_PAR19,';')
	
	//Casul - retirado par poder deixar em branco e nao imprimir nenhum desconto
	If lOk .And. !Empty(MV_PAR19)
		NNH->( dbSetOrder( 1 ) )
		For nI := 1 to Len(aAux) Step 1
			IF !NNH->( dbSeek( fWxFilial( "NNH" ) + aAux[nI] ))
				lok := .f.
				Exit
			EndIF
		nExt
	EndIF
	IF !lOk
		Help( ,, "HELP" ,, STR0072, 1, 0) //Selecione 6 tipos de decontos válidos para listar. Separe-os com (;) Ex: UMI;TRA;ARD
	EndIF

Return( lOk )

/*
@param: nil
@description: Função que Valida a pergunta ref. aos status.
@author: Equipe Agroindústria
@since: 13/08/2015
@return: empty
*/

User Function fOgr295vdB()
	Local lOk 		:= .t.
	Local nI		:= 0
	local aLstSts := gGetStsNJJ() //obtem lista de status
	local aAux 	:= Separa(MV_PAR22,';')
	local nPos    := 0   
		
	If !empty(MV_PAR22)
		For nI := 1 to Len(aAux) Step 1
			nPos  := aScan(aLstSts,{|x| AllTrim(x[1]) == Alltrim(aAux[nI]) })
			If nPos < 1 //não encontrou o status
				lok := .f.
				Exit
			EndIF
		nExt
	EndIF
	IF !lOk
		Help( ,, "HELP" ,, STR0084, 1, 0) //Selecione status válidos para listar. Separe-os com (;) Ex: UMI;TRA;ARD
	EndIF

Return( lOk )

/*
+=================================================================================================+
| Função    : fOgr295PQU                                                                          |
| Descrição : Validação o parecer da qualidade                                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/03/2016                                                                          |
+=================================================================================================+ 
| Referência: Dicionário de dados SX1                                                             |
+=================================================================================================+ 
*/ 
User Function fOgr295PQU()
Local lOk := .t., nI,nPos
Local aLstSts := gGetPQUNJJ() //obtem lista de PARECER
Local aAux 	 := Separa(MV_PAR23,';')
		
If !Empty(MV_PAR23)
	For nI := 1 to Len(aAux) Step 1
		nPos  := aScan(aLstSts,{|x| AllTrim(x[1]) == Alltrim(aAux[nI]) })
		If nPos < 1 //não encontrou o status
			lOk := .f.
			Exit
		EndIF
	Next nI
EndIF
If !lOk
	Help(,,"HELP",,"Selecione parecer válidos para listar. Separe-os com (;)"+" Ex. 0;1;2;...",1,0)
EndIf
Return lOk 

/*
+=================================================================================================+
| Função    : gGetPQUNJJ                                                                          |
| Descrição : Monta matriz com as opções do parecer da qualidade                                  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 16/03/2016                                                                          |
+=================================================================================================+ 
*/ 
Static Function gGetPQUNJJ()
Local aPQUNJJ := {},aAux2 := {}
Local nI,aAux := Separa(AGRRETSX3BOX("NJJ_LIBQLD"),';')
        
For nI := 1 to Len(aAux) Step 1
   aAux2 = separa(aAux[nI],'=')
   aAdd(aPQUNJJ,{alltrim(aAux2[1]),alltrim(aAux2[2])})
Next
Return aPQUNJJ

/*
@param: nil
@description: Função que obtem os dados dos status da NJJ.
@author: Equipe Agroindústria
@since: 13/08/2015
@return: array
*/

static function gGetStsNJJ()
    local aStsNJJ := {}
    Local nI        := 0
    local aAux  := Separa(AGRRETSX3BOX("NJJ_STATUS"),';')
    local aAux2   := {}
        
    For nI := 1 to Len(aAux) Step 1
          aAux2 = separa(aAux[nI],'=')
          aAdd(aStsNJJ,{alltrim(aAux2[1]),alltrim(aAux2[2])})
    nExt
    
return (aStsNJJ)

/*
@param: nil 
@description: Funcao que le os tipos de movtos possiveis no romaneio
   				e retorna em uma linha para que possam ser impressos no
   				rodape
@author: Emerson Coelho
@since: 09/09/2013
@return: array com 3 linhas contendo as descrições do tipo de movto.
*/

//-- Lendo os Tipos de movtos do romaneio para imprimir no Rodape --//
Static Function fGerRodape()
	Local cRodape :=''

//GetAdvFVal(<cAlias>,<cCampo/Alias>,cStringBusca,<nIndice>,[cDefault]))


	dbSelectArea("SX5")
	dbSetOrder(1)
	
	dbSeek(xFilial("SX5")+"K5")
	While !Eof() .And. X5_FILIAL+X5_TABELA == xFilial("SX5")+"K5"
		IF Len(cRodape) > 0
			cRodape += ","
		EndIf
		cRodape +=	Substr(SX5->X5_DESCRI,2,1) + AllTrim(SX5->X5_CHAVE) +"-" + AllTrim(SX5->X5_DESCRI)
		SX5->(dbSkip())
	End
Return(cRodape)
/*
@param: nil 
@description: Funcao que verifica se preciso imprimir o rodape
   				e pular a pagina
@author: Emerson Coelho
@since: 09/09/2013
@return: array com 3 linhas contendo as descrições do tipo de movto.
*/

Static Function fSaltaPage(nLines)
	Local lSaltou := .f.
	Local ni:=0
	ni:=1

	While oReport:ChkIncRow(nLines,.t.)
		if nI == 1
			oReport:Fatline()  //Somente essa linha como rodape
			lSaltou := .t.
		ELSE
			oReport:SkipLine(1)
		EndIF
		ni++
			
	EndDo

Return(lSaltou)


/*
@param: nil 
@description: FTotProd Print, o total do produto
@author: Emerson Coelho
@since: 09/09/2013
@return: array com 3 linhas contendo as descrições do tipo de movto.
*/

Static Function fTotProd()
	Local nI := 0
	aAux 	:= separa(MV_PAR19, ';')
	For	nI:=Len(aAux) to 6
		aAdd(aAux,'')
	nExt nI
	
	oReport:Fatline()
	oreport:PrintText (Transform(Obreak1:aFunction[01]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColG)
	oreport:PrintText (Transform(Obreak1:aFunction[02]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColH)  	//80
	oreport:PrintText (Transform(Obreak1:aFunction[03]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColI)  	//80
	//oreport:PrintText (Transform(Obreak1:aFunction[04]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ)  	//80
	oreport:PrintText (Transform(Obreak1:aFunction[04]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ)  	//80 CASUL
	oreport:PrintText (Transform(Obreak1:aFunction[05]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ1)  	//80 CASUL
	oreport:PrintText (Transform(Obreak1:aFunction[06]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColK)  	//80
	
	IF ! Empty(aAux[1] )
		oreport:PrintText (Transform(Obreak1:aFunction[07]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColM)  	//80
		oreport:PrintText (Transform(Obreak1:aFunction[08]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColN)	// 110
	EndIF
	IF ! Empty(aAux[2] )
		oreport:PrintText (Transform(Obreak1:aFunction[09]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColO)  	//80
		oreport:PrintText (Transform(Obreak1:aFunction[10]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColP)	// 110
	EndIF
	IF ! Empty(aAux[3] )
		oreport:PrintText (Transform(Obreak1:aFunction[11]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColQ)  	//80
		oreport:PrintText (Transform(Obreak1:aFunction[12]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColR)	// 110
	EndIF
	IF ! Empty(aAux[4] )
		oreport:PrintText (Transform(Obreak1:aFunction[13]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColS)  	//80
		oreport:PrintText (Transform(Obreak1:aFunction[14]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColT)	// 110
	EndIF
	IF ! Empty(aAux[5] )
		oreport:PrintText (Transform(Obreak1:aFunction[15]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColU)  	//80
		oreport:PrintText (Transform(Obreak1:aFunction[16]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColV)	// 110
	EndIF
	IF ! Empty(aAux[6] )
		oreport:PrintText (Transform(Obreak1:aFunction[17]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColX)  	//80
		oreport:PrintText (Transform(Obreak1:aFunction[18]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColZ)	// 110
	EndIF
	For ni:=1 to Len(oBreak1:aFunction)
		oBreak1:aFunction[nI]:Reset()
	nExt
	oreport:Skipline()

Return
/*
@param: nil 
@description: FTotLojaPrint, Imprime o total da Loja
@author: Emerson Coelho
@since: 09/09/2013
*/

Static Function fTotLoja()
	Local ni	:=0
	Local aAux	:= {}
	
	aAux 	:= separa(MV_PAR19, ';')
	For	nI:=Len(aAux) to 6
		aAdd(aAux,'')
	nExt nI
	

	oReport:Fatline()
	oreport:PrintText (Transform(oBreak2:aFunction[01]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColG)
	oreport:PrintText (Transform(oBreak2:aFunction[02]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColH)  	//80
	oreport:PrintText (Transform(oBreak2:aFunction[03]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColI)  	//80
	//oreport:PrintText (Transform(oBreak2:aFunction[04]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ)  	//80
	oreport:PrintText (Transform(oBreak2:aFunction[04]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ)  	//80
	oreport:PrintText (Transform(oBreak2:aFunction[05]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ1)  	//80
	oreport:PrintText (Transform(oBreak2:aFunction[06]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColK)  	//80
	IF ! Empty(aAux[1] )
		oreport:PrintText (Transform(oBreak2:aFunction[07]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColM)  	//80
		oreport:PrintText (Transform(oBreak2:aFunction[08]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColN)	// 110
	EndIF
	IF ! Empty(aAux[2] )
		oreport:PrintText (Transform(oBreak2:aFunction[09]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColO)  	//80
		oreport:PrintText (Transform(oBreak2:aFunction[10]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColP)	// 110
	EndIF
	IF ! Empty(aAux[3] )
		oreport:PrintText (Transform(oBreak2:aFunction[11]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColQ)  	//80
		oreport:PrintText (Transform(oBreak2:aFunction[12]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColR)	// 110
	EndIF
	IF ! Empty(aAux[4] )
		oreport:PrintText (Transform(oBreak2:aFunction[13]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColS)  	//80
		oreport:PrintText (Transform(oBreak2:aFunction[14]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColT)	// 110
	EndIF
	IF ! Empty(aAux[5] )
		oreport:PrintText (Transform(oBreak2:aFunction[15]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColU)  	//80
		oreport:PrintText (Transform(oBreak2:aFunction[16]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColV)	// 110
	EndIF
	IF ! Empty(aAux[6] )
		oreport:PrintText (Transform(oBreak2:aFunction[17]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColX)  	//80
		oreport:PrintText (Transform(oBreak2:aFunction[18]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColZ)	// 110
	EndIF
		
	For ni:=1 to Len(oBreak2:aFunction)
		oBreak2:aFunction[nI]:Reset()
	nExt
	oReport:SkipLine()
Return
/*
@param: nil 
@description: FTotEnt Print, Imprime o Total Entidade
@author: Emerson Coelho
@since: 09/09/2013
*/

Static Function fTotEnt()
	Local nI 	:=0
	Local aAux	:= {}
	
	aAux 	:= separa(MV_PAR19, ';')
	For	nI:=Len(aAux) to 6
		aAdd(aAux,'')
	nExt nI
	

	oReport:Fatline()
	oreport:PrintText (Transform(oBreak3:aFunction[01]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColG)
	oreport:PrintText (Transform(oBreak3:aFunction[02]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColH)  	//80
	oreport:PrintText (Transform(oBreak3:aFunction[03]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColI)  	//80
	//oreport:PrintText (Transform(oBreak3:aFunction[04]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ)  	//80
	oreport:PrintText (Transform(oBreak3:aFunction[04]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ)  	//80
	oreport:PrintText (Transform(oBreak3:aFunction[05]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColJ1)  	//80
	oreport:PrintText (Transform(oBreak3:aFunction[06]:GetValue(),	"@E 9999,999,999"),	oreport:row(), 	nPosColK)  	//80
	IF ! Empty(aAux[1] )
		oreport:PrintText (Transform(oBreak3:aFunction[07]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColM)  	//80
		oreport:PrintText (Transform(oBreak3:aFunction[08]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColN)	// 110
	EndIF
	IF ! Empty(aAux[2] )
		oreport:PrintText (Transform(oBreak3:aFunction[09]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColO)  	//80
		oreport:PrintText (Transform(oBreak3:aFunction[10]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColP)	// 110
	EndIF		
	IF ! Empty(aAux[3] )
		oreport:PrintText (Transform(oBreak3:aFunction[11]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColQ)  	//80
		oreport:PrintText (Transform(oBreak3:aFunction[12]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColR)	// 110
	EndIF
	IF ! Empty(aAux[4] )
		oreport:PrintText (Transform(oBreak3:aFunction[13]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColS)  	//80
		oreport:PrintText (Transform(oBreak3:aFunction[14]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColT)	// 110
	EndIF
	IF ! Empty(aAux[5] )
		oreport:PrintText (Transform(oBreak3:aFunction[15]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColU)  	//80
		oreport:PrintText (Transform(oBreak3:aFunction[16]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColV)	// 110
	EndIF
	IF ! Empty(aAux[6] )
		oreport:PrintText (Transform(oBreak3:aFunction[17]:GetValue(),	"@E 99,999.99"),	oreport:row(), 	nPosColX)  	//80
		oreport:PrintText (Transform(oBreak3:aFunction[18]:GetValue(),	"@E 9999,999"),		oreport:row(), 	nPosColZ)	// 110
	EndIF			
		
	For ni:=1 to Len(oBreak3:aFunction)
		oBreak3:aFunction[nI]:Reset()
	nExt

	oReport:SkipLine(1)
		
Return

Static Function RQryNFCp()
Local cQuery := ""

	cQuery += " UNION "
	cQuery += " SELECT DISTINCT "
	cQuery += "		B1_DESC, "
	cQuery += "  NJJ_DATA, NJJ_FILIAL, NJJ_TIPO, '' NJJ_PLACA, D1_QUANT NJJ_PESO1, 0 NJJ_PESO2, 0 NJJ_PESO3, 0 NJJ_PSLIQU, NJJ_STATUS, NJJ_STSPES, " 
	cQuery += "  NJM_TES, NJM_CODENT, NJM_LOJENT, NJM_CODPRO, NJM_FILIAL, '' NJM_CODROM, D1_DOC+'('+NJM_DOCNUM+')' NJM_DOCNUM, SUM(NJM_PERDIV) NJM_PERDIV, "
	cQuery += "  NJJ_X_QBT, NJM_TIPO, "
	cQuery += " 		(CASE "
	cQuery += "  			WHEN NJM.NJM_TIPO  IN ('3' , '5', '7' , '9') THEN 'E'"	//Romaneios de Entrada
	cQuery += "  			WHEN NJM.NJM_TIPO  IN ('2' , '4' , '6', '8' ) THEN 'S'"	//Romaneios de Saida
	cQuery += "  		END) AS TPROM, "
	cQuery += " 0 AS DESCONTO "
	cQuery += " FROM " + RetSqlName('NJM')+ " NJM "
	cQuery += " LEFT JOIN " + RetSqlName('SB1')+ " SB1 ON "

 //--Encontrando a Filial do Inner Join SB1 --
 cJoinFil :=''
	If FWModeAccess("SB1") == "E" .And. FWModeAccess("NJM") == "E"
		cJoinFil += "  SB1.B1_FILIAL = NJM.NJM_FILIAL AND "
	ElseIf FWModeAccess("SB1",3) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("SB1",2) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("SB1",1) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " SB1.B1_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
 //-----------------------------------------------------------------------
	cQuery += cJoinFil +" SB1.B1_COD = NJM.NJM_CODPRO AND SB1.D_E_L_E_T_ = ' '"   		
	
	cQuery += " LEFT JOIN " + RetSqlName('NJJ')+ " NJJ ON "

 //--Encontrando a Filial do Inner Join NJJ --
 cJoinFil :=''
	If FWModeAccess("NJJ") == "E" .And. FWModeAccess("NJM") == "E"
		cJoinFil += "  NJJ.NJJ_FILIAL = NJM.NJM_FILIAL AND "
	ElseIf FWModeAccess("NJJ",3) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("NJJ",2) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("NJJ",1) == "E"
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " NJJ.NJJ_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " NJJ.NJJ_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
  
	cQuery += cJoinFil + " NJJ.NJJ_CODROM = NJM.NJM_CODROM AND NJJ.D_E_L_E_T_ = ' '"

 //JOIN Complementos
	cQuery += " JOIN " + RetSqlName('SD1')+ " SD1 ON D1_FILIAL = NJM_FILIAL AND D1_NFORI = NJM_DOCNUM "
	cQuery += "   AND D1_SERIORI = NJM_DOCSER  AND D1_COD = NJM_CODPRO AND D1_FORNECE = NJM_CODENT AND D1_LOJA = NJM_LOJENT " 
 cQuery += "   AND D1_TIPO = 'C' AND SD1.D_E_L_E_T_ = ' ' " 
	
	cQuery += " WHERE  NJM.NJM_CODENT BETWEEN '" + cEntidIni + "' AND '" + cEntidFim	+ 	"'"
	cQuery += "  	AND NJM.NJM_LOJENT	 BETWEEN '" + cLojaIni + "' AND '" + cLojaFim	+ 	"'"
	cQuery += "  	AND NJM.NJM_CODCTR BETWEEN '" + cCtrIni + "' AND '" + cCtrFim	+	"'"
	cQuery += " 	AND SB1.B1_GRUPO BETWEEN '" + cGrpPrdIni	+ "' AND '" + cGrpPrdFim	+ 	"'"
	cQuery += "	AND NJM.NJM_CODPRO 	BETWEEN '"  	+ cProdutIni 	+ "' AND '" + cProdutFim	+	"'"
	cQuery += "	AND NJM.NJM_CODSAF 	BETWEEN '"		+ cCodSafIni  + "' AND '" + cCodSafFim	+	"'"
	
	//considera autorização
	If !empty(mv_par24)
		cQuery += "  AND NJM.NJM_CODAUT IN (" + AGRMULTOPQRY(mv_par24) + ")"
	Endif
	
	cQuery += "	AND NJM.NJM_FILIAL 	BETWEEN '" 	+ cFilialIni 	+ "' AND '" +	cFilialFim	 + "'"
	IF nTpMvRom == 02 //Considera somente entradas
		cQuery += " AND NJM.NJM_TIPO  IN ('3' , '5', '7' , '9') "
	ElseIF nTpMvRom == 03 //Considera somente Saidas
		cQuery += " AND NJM.NJM_TIPO  IN ('2' , '4' , '6', '8' ) "
	EndIF
	
	IF nTpRom == 4 //Considera Romaneios Simbolicos
		cQuery += " AND NJJ.NJJ_TIPENT = '2' "
	ElseIF nTpRom == 3 //Considera Romaneios Gerenciais
		cQuery += " AND NJJ.NJJ_TIPENT = '1' "
	ElseIF nTpRom == 2 //Considera Romaneios Fisicos
		cQuery += " AND NJJ.NJJ_TIPENT = '0' "
	EndIF
		
	//considera Paracer da qualidade
	If !empty(mv_par23)
		cQuery += "  AND NJJ.NJJ_LIBQLD IN (" + AGRMULTOPQRY(mv_par23,"N") + ")"
	Endif
	
	if nTpDataLst = 1    //"Data do Romaneio" - "NJJ_DATA";	
  cQuery += " AND NJJ.NJJ_DATA        BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	elseif nTpDataLst = 2 // "Data da Pesagem 1" - "NJJ_DATPS1"; 
  cQuery += " AND NJJ.NJJ_DATPS1      BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	elseif nTpDataLst = 3 //"Data da Pesagem 2" - "NJJ_DATPS2";
  cQuery += " AND NJJ.NJJ_DATPS2       BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	elseif nTpDataLst = 4 //"Emissao do Documento Fiscal" - "NJM_DOCEMI"; 
  cQuery += " AND NJM.NJM_DOCEMI       BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	elseif nTpDataLst = 5 // "Data da Transação" -  "NJM_DTRANS"
  cQuery += " AND NJM.NJM_DTRANS        BETWEEN '"      + dTOS(dDtIni)      + "' AND '" + dTOs(dDtFim)  +   "'"
	endif
	
	//considera os status
	if !empty(cStatusLst)
		aListSts  := separa(cStatusLst, ';') //pega todos os status
		cAuxQuery := ""
		
		For nI := 1 to Len(aListSts) Step 1
			if cAuxQuery == ""
				cAuxQuery := "'" + allTrim(aListSts[nI]) + "'"
			else
				cAuxQuery += " , '" + allTrim(aListSts[nI]) + "'"
			endif
		nExt nI
		
		cQuery += "   AND NJJ.NJJ_STATUS IN (" + cAuxQuery + ")"
		
	else
		cQuery += "   AND NJJ_STATUS NOT IN ('4') " // n. listar Cancelados 
	endif
		
	cQuery += "	AND NJM.D_E_L_E_T_ != '*' "
	
	//Complementos
 cQuery += " AND NJM_DOCNUM <> '' "
 
 cQuery += " GROUP BY  B1_DESC,NJJ_DATA,NJJ_FILIAL,NJJ_TIPO,NJJ_PLACA,NJJ_STATUS,NJJ_STSPES,NJM_TES,"
	cQuery += "           NJM_CODENT,NJM_LOJENT,NJM_CODPRO,NJM_FILIAL,NJM_CODROM,D1_DOC+'('+NJM_DOCNUM+')',NJJ_X_QBT,NJM_TIPO,"
	cQuery += "           D1_QUANT,NJJ_PESO2,NJJ_PESO3,NJJ_PSLIQU "
 
Return(cQuery)

Static Function RQryNFPV()
Local cQuery := ""

	cQuery += " UNION "
	cQuery += " SELECT DISTINCT "
	cQuery += "		B1_DESC, "
	cQuery += "  D2_EMISSAO NJJ_DATA, D2_FILIAL NJJ_FILIAL, '' NJJ_TIPO, '' NJJ_PLACA, D2_QUANT NJJ_PESO1, 0 NJJ_PESO2, 0 NJJ_PESO3, 0 NJJ_PSLIQU, '' NJJ_STATUS, '' NJJ_STSPES, " 
	cQuery += "  D2_TES NJM_TES, D2_CLIENTE NJM_CODENT, D2_LOJA NJM_LOJENT, D2_COD NJM_CODPRO, D2_FILIAL NJM_FILIAL, '' NJM_CODROM, D2_DOC+'(PV:'+D2_PEDIDO+')' NJM_DOCNUM, 100 NJM_PERDIV, "
	cQuery += "  0 NJJ_X_QBT, '' NJM_TIPO, "
 cQuery += "  'S' AS TPROM, "	//Romaneios de Saida
	cQuery += "  0 AS DESCONTO "
	cQuery += " FROM " + RetSqlName('SD2')+ " SD2 "
	cQuery += " LEFT JOIN " + RetSqlName('SB1')+ " SB1 ON "

 //--Encontrando a Filial do Inner Join SB1 --
 cJoinFil :=''
	If FWModeAccess("SB1") == "E" .And. FWModeAccess("SD2") == "E"
		cJoinFil += "  SB1.B1_FILIAL = D2_FILIAL AND "
	ElseIf FWModeAccess("SB1",3) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + cFilialIni + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + cFilialFim + "' AND "
	ElseIf FWModeAccess("SB1",2) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1)) +Len(FWSM0Layout(,2))),FWSizeFilial()) + "' AND "
	ElseIf FWModeAccess("SB1",1) == "E"
		cJoinFil += " SB1.B1_FILIAL >= '" + PadR(Substr(cFilialIni,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + PadR(Substr(cFilialFim,1,Len(FWSM0Layout(,1))),FWSizeFilial()) + "' AND "
	Else
		cJoinFil += " SB1.B1_FILIAL >= '" + Space(FWSizeFilial()) + "' AND "
		cJoinFil += " SB1.B1_FILIAL <= '" + Space(FWSizeFilial()) + "' AND "
	EndIf
 //-----------------------------------------------------------------------
	cQuery += cJoinFil +" SB1.B1_COD = D2_COD AND SB1.D_E_L_E_T_ = ' '"   		

	cQuery += " LEFT JOIN " + RetSqlName('NJM')+ " NJM ON NJM.D_E_L_E_T_ != '*'  AND NJM_FILIAL = D2_FILIAL "
	cQuery += "  	AND NJM_DOCNUM = D2_DOC AND NJM_DOCSER = D2_SERIE "
	cQuery += "  	AND NJM_CODENT = D2_CLIENTE AND NJM_LOJENT = D2_LOJA "

	cQuery += " WHERE D2_CLIENTE BETWEEN '" + cEntidIni + "' AND '" + cEntidFim	+ 	"'"
	cQuery += "  	AND D2_LOJA  	 BETWEEN '" + cLojaIni + "' AND '" + cLojaFim	+ 	"'"
	cQuery += "  	AND SB1.B1_GRUPO BETWEEN '" + cGrpPrdIni	+ "' AND '" + cGrpPrdFim	+ 	"'"
	cQuery += "	  AND D2_COD 	BETWEEN '"  	+ cProdutIni 	+ "' AND '" + cProdutFim	+	"'"
	
	cQuery += "	  AND D2_FILIAL 	BETWEEN '" 	+ cFilialIni 	+ "' AND '" +	cFilialFim	 + "'"
	
 cQuery += "   AND D2_EMISSAO BETWEEN '" + dTOS(dDtIni) + "' AND '" + dTOs(dDtFim)  +   "'"
	cQuery += "	  AND SD2.D_E_L_E_T_ != '*' "
	cQuery += "   AND D2_TES IN " + FormatIN("702/703", "/")
	cQuery += "  	AND NJM_DOCNUM IS NULL "

Return(cQuery)

Static Function RCodCtr(cFilRom, cCODROM)
Local aArea    := GetArea()
Local cCodCtrs := ""
Local cQuery   := ""

 cQuery := " SELECT DISTINCT NJM_CODCTR FROM " + RETSQLTAB("NJM")
	cQuery += " WHERE	NJM_CODROM	= '" 	+ cCodRom 				+ "'"
	cQuery += " AND 	NJM_FILIAL = '" 	+ cFilRom 	+ "'"
	cQuery += " AND 	D_E_L_E_T_ !='*'"

	cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "QryCTR"

	While !Eof()
	 cCodCtrs += IIF(!Empty(cCodCtrs), "/", "") + cValToChar(Val(QryCTR->NJM_CODCTR))
	
	 QryCTR->(DbSkip())
	EndDo
	
	QryCTR->( dbCloseArea() )

 RestArea(aArea)
Return(cCodCtrs)