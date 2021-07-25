#Include 'Protheus.ch'
#Include "Topconn.ch"
#include 'parmtype.ch'
#DEFINE ENTER Chr(10)+Chr(13)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460FIM   บAutor  ณ                    บ Data ณ  03/06/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada chamado ap๓s a gravaca็ใo da nota fiscal  บฑฑ
ฑฑบ          ณ nele serแ realizado as grava็๕es e impressใo do receituแrioบฑฑ
ฑฑบ          ณ agr๔nomico  						                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function M460FIM()
  Local aArea := GetArea()

  //If !IsInCallStack("A311Efetiv")
     U_Fn460Fim()//Fun็ใo para preparar o uso da Receita Agron๔mica
  //EndIf

  cSql := " SELECT SE1.R_E_C_N_O_ RECNOSE1 "
  cSql += " FROM " + RetSqlName("SE1") + " SE1 "
  cSql += " WHERE SE1.D_E_L_E_T_    <> '*' AND SE1.E1_FILIAL  =  '" + xFilial("SE1") + "' "
  cSql += "  AND SE1.E1_PREFIXO =  '" + SF2->F2_SERIE   +  "' "
  cSql += "  AND SE1.E1_NUM     =  '" + SF2->F2_DUPL  + "' "
  cSql += " ORDER BY SE1.E1_NUM, SE1.E1_PREFIXO, SE1.E1_PARCELA "

  TCQuery cSql NEW ALIAS "TMPSE1"
			
  While !TMPSE1->(Eof())
     
	 If SE1->(FieldPos("E1_X_VLFUT")) > 0 .And. SC5->(FieldPos("C5_X_VLRPR")) > 0
  		DBSelectArea("SE1")
	 	SE1->(dbGoto(TMPSE1->RECNOSE1))
        RecLock("SE1", .F.)
 	    SE1->E1_X_VLFUT := SC5->C5_X_VLRPR 
 	    SE1->E1_X_PERJA := SC5->C5_X_PERJA
		MsUnLock()	
     EndIf
	 TMPSE1->(DbSkip())
  EndDo
  TMPSE1->(DbCloseArea())			
  RestArea(aArea)
return .T.

//Ajuste Dados nao gravar nos Titulos -> Calc.Futuro x PV
User Function SetE1CaF()
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()

	BEGINSQL ALIAS cAliasQry
	
		SELECT C5_X_PERJA, C5_X_VLRPR, SE1.R_E_C_N_O_ RECNOE1
		FROM %TABLE:SE1% SE1
		JOIN %TABLE:SF2% SF2 ON F2_DUPL = E1_NUM AND F2_SERIE = E1_PREFIXO 
		   AND F2_FILIAL = E1_FILIAL AND SF2.%NotDel%
		JOIN %TABLE:SC5% SC5 ON C5_NUM = E1_PEDIDO AND C5_FILIAL = E1_FILIAL AND SC5.%NotDel%
		   AND C5_X_VLRPR > 0
		WHERE SE1.%NotDel%
		 	AND E1_X_VLFUT = 0

	ENDSQL

 While !Eof()
  DBSelectArea("SE1")
		dbGoto((cAliasQry)->RECNOE1)
	
	 RecLock("SE1", .F.)
	  SE1->E1_X_VLFUT := (cAliasQry)->C5_X_VLRPR 
	  SE1->E1_X_PERJA := (cAliasQry)->C5_X_PERJA
		MsUnLock()

		(cAliasQry)->(DbSkip())
	EndDo
 (cAliasQry)->(DbCloseArea())

 RestArea(aArea)
Return()
