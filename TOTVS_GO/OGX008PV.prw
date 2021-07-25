/*
======================================================================================================================================
ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
======================================================================================================================================
Autor	|	Data	 |										Motivo															
------------:------------:-----------------------------------------------------------------------------------------------------------:
|            | 																	
------------:------------:-----------------------------------------------------------------------------------------------------------:
|		   	 | 	   																										 
======================================================================================================================================
*/
#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'TopConn.ch'
#include 'parmtype.ch'

/*
===============================================================================================================================
Programa----------: OGX008PV
Autor-------------: Ricardo Mendes
Data da Criacao---: 31/05/2017
===============================================================================================================================
Descricao..       : P.E. Permite controlar dados específicos do pedido de venda
===============================================================================================================================
Uso---------------: Gestão Agricola
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Gestão Agricola
===============================================================================================================================
*/

user function OGX008PV()
	Local aCab   	:= aClone(PARAMIXB[1])
	Local aItens 	:= aClone(PARAMIXB[2])
	Local aRet   	:= {} //Customizações do usuário
	Local lMsg		:= .F.
	Local lNature	:= .F.
	Local cCentCust := NJJ->NJJ_X_CC
	Local cCtrOg	:= NJJ->NJJ_CODCTR
	Local lAchouC6	:= .F.
	Local nPos2		:= 0
	Local nFaz		:= 0

	IF Len(aCab) > 0
		For nPos2 := 1 to Len(aCab)
/*
			IF aCab[nPos2,1] == "C5_XMSGNF"
				lMsg:= .T.
				aCab[nPos2,2]:= 	NJJ->NJJ_XMSGNF
			EndIF
*/			
			IF aCab[nPos2,1] == "C5_NATUREZ"
				lNature:= .T.
				aCab[nPos2,2]:= 	NJJ->NJJ_X_NATU
			EndIF		

			IF aCab[nPos2,1] == "C5_CTROG"
				lNature:= .T.
				aCab[nPos2,2]:= 	NJJ->NJJ_CODCTR
			EndIF
			
			IF NJM->NJM_CONDPG = GetMv('MV_AGRCPVD')
				IF aCab[nPos2,1] == "C5_DATA1"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'001','NN7_DTVENC')
				EndIF	
				IF aCab[nPos2,1] == "C5_PARC1"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'001','NN7_VALOR')
				EndIF
				IF aCab[nPos2,1] == "C5_DATA2"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'002','NN7_DTVENC')
				EndIF	
				IF aCab[nPos2,1] == "C5_PARC2"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'002','NN7_VALOR')
				EndIF		
				IF aCab[nPos2,1] == "C5_DATA3"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'003','NN7_DTVENC')
				EndIF	
				IF aCab[nPos2,1] == "C5_PARC3"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'003','NN7_VALOR')
				EndIF
				IF aCab[nPos2,1] == "C5_DATA4"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'004','NN7_DTVENC')
				EndIF	
				IF aCab[nPos2,1] == "C5_PARC4"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'004','NN7_VALOR')
				EndIF
				IF aCab[nPos2,1] == "C5_DATA5"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'005','NN7_DTVENC')
				EndIF	
				IF aCab[nPos2,1] == "C5_PARC5"
					lNature:= .T.
					aCab[nPos2,2]:= 	POSICIONE('NN7',1,XFILIAL('NN7')+NJM->NJM_CODCTR+'005','NN7_VALOR')
				EndIF				
						
			EndIF

		Next nPos2
/*
		IF !lMsg
			aAdd( aCab, { "C5_XMSGNF"	, NJJ->NJJ_XMSGNF, Nil } )
			lMsg	:= .F.
		EndIF
*/
		IF !lNature
			aAdd( aCab,{ "C5_NATUREZ"	, NJJ->NJJ_X_NATU, Nil } )
			lNature	:= .F.
		EndIF	

		IF !lNature
			aAdd( aCab,{ "C5_CTROG"	, NJJ->NJJ_CODCTR, Nil } )
			lNature	:= .F.
		EndIF
	EndIF

	//Itens
	 IF Len(aItens) > 0
 		For nPos2 := 1 to Len(aItens)
			For nFaz := 1 to Len(aItens[nPos2])
				IF aItens[nPos2,nFaz,1] == "C6_CC"
					lAchouC6:= .T.
					aItens[nPos2,nFaz,2]:= 	cCentCust
				EndIF	
			Next nFaz
			IF !lAchouC6
				aAdd( aItens[nPos2],{ "C6_CC"	, cCentCust		 	, Nil } )
				lAchouC6	:= .F.
			EndIF
		Next nPos2
		
 	EndIF
	
	
	aRet := {aCab,aItens}

Return(aRet)