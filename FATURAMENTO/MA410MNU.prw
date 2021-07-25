#Include "Rwmake.ch"

User Function MA410MNU()
   aadd(aRotina,{'Impr.Rec.Agron.' ,'u_MA410Imp'     , 0, 3,0,NIL})
Return()

User Function MA410Imp
  Local cAlias := "SC5"

  DbSelectArea("ZB6")

  DbSelectArea("SF2")
  dbSetOrder(1)
  If MsSeek(xFilial("SF2")+SC5->(C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI))
     U_CSL05R01(1, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_XTECNIC, SF2->F2_FILIAL )
     DbSelectArea(cAlias)
  Endif   
Return
