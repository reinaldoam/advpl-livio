#include 'protheus.ch'
#include 'parmtype.ch'

user function IMPTXT()
	Local cPorta	:= "LPT1"				//Porta corrente
	Local nErroPrt	:= 0				//Retorna o erro, caso a impressora nao esteja conectada
	Local lRetImp	:= .T.				//Variavel que verifica se a impressora conectou
	Local nLaco		:= 0

	Private nLastKey	:= 0
	Private aReturn		:= { "", 1, "" , 2, 3, cPorta , "",IndexOrd() }

	SetPrint(Alias(),"","","",,,,.F.,,,,,,,'EPSON.DRV',.T.,.F.,cPorta)
	
	MsgAlert( "nLastKey" + cValToChar(nLastKey) )
	MsgAlert( "IsPrinter2" +cValToChar( IsPrinter2(cPorta,,1) ) )
	MsgAlert( "IsPrinter" +cValToChar( IsPrinter() ) )
	
	//³Verifica se teve exito nas configuracoes do SetPrint e se existe impressora conectada|
	If nLastKey <> 27 .AND. IsPrinter2(cPorta,,1)
		SetDEFAULT(aReturn,Alias())

		//³Verifica se teve exito nas configuracoes do SetDEFAULT			   ³
		If nLastKey <> 27
			For nLaco := 1 to 20
				@ Prow()+1,000 Psay "Texto"+cValToChar(nLaco)
			Next
			SetPrc(0,0)
		Endif
		
		SetPgEject(.F.)
		MS_FLUSH()
	
	Else
		MsgAlert( "Impressora nao conectada" + Alltrim(Str(nErroPrt) ) )
		lRetImp	:= .F.
	Endif

Return (lRetImp)