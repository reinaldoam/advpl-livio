// #########################################################################################
// Modulo : 67 - Gestão Agroindústria
// Fonte  : OGX009NF
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 11/11/16 | Israel Frossard   | Ponto de Entrada executado na Confirmação do Romaneio
//          |                   | Leva informações do Romaneio para a SF1
// ---------+-------------------+-----------------------------------------------------------
 
 
#include 'protheus.ch'
#include 'parmtype.ch'
 
User Function OGX009NF()

	Local aCab   := aClone(PARAMIXB[1])
    Local aItens := aClone(PARAMIXB[2])
    Local aRet   := {} //Customizações do usuário

	Local cContrato := NJJ->NJJ_CODCTR
	Local cCentCust := POSICIONE("NN7",1,XFILIAL("NJR")+cContrato,"NN7_CCD")
	Local cEspecie1 :=  aSCAN(aCab, {|aCab| aCab[1] == "F1_ESPECI1" })
	Local nQtd		:=  aSCAN(aCab, {|aCab| aCab[1] == "F1_VOLUME1" })
	Local lAchouD1	:= .F.
	Local nFaz		:= 0
	Local nPos2		:= 0
	Local aLinha	:={}


	IF cEspecie1 > 0 // Ja stá no array
		aCab[cEspecie1,1] += 'A GRANEL'  //
	Else // Ainda n. se encontra no Array Adicionar
		aAdd( aCab, { "F1_ESPECI1" , 'A GRANEL'    } )
	EndIF

	IF nQtd > 0 // Ja stá no array
		aCab[nQtd,1] += NJJ->NJJ_PSLIQU  
	Else // Ainda n. se encontra no Array Adicionar
		aAdd( aCab, { "F1_VOLUME1" , NJJ->NJJ_PSLIQU} )
	EndIF

		aAdd( aCab, { "E2_NATUREZ" , NJJ->NJJ_X_NATU} )

//Itens
	 IF Len(aItens) > 0
 		For nPos2 := 1 to Len(aItens)
			For nFaz := 1 to Len(aItens[nPos2])
				IF aItens[nPos2,nFaz,1] == "D1_CC"
					lAchouD1:= .T.
//					aItens[nPos2,nFaz,2]:= 	cCentCust
					aItens[nPos2,nFaz,2]:= 	'17001'
				EndIF	
			Next nFaz
			IF !lAchouD1
//				aAdd( aItens[nPos2],{ "D1_CC"	, cCentCust		 	, Nil } )
				aAdd( aItens[nPos2],{ "D1_CC"	, '17001'	    	, Nil } )
				lAchouD1	:= .F.
			EndIF
		Next nPos2
		
 	EndIF


aRet := {aCab,aItens}

Return(aRet)