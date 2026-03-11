PARAMETERS: p_vbeln TYPE vbeln_va OBLIGATORY.

DATA: lv_fm_name  TYPE funcname,
      ls_output   TYPE sfpoutputparams.

START-OF-SELECTION.

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'ZFF_SALES'
    IMPORTING
      e_funcname = lv_fm_name
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Formulaire ZFF_SALES introuvable ou non activé.' TYPE 'E'.
    RETURN.
  ENDIF.

  ls_output-nodialog = abap_true.
  ls_output-preview  = abap_true.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = ls_output.

  CALL FUNCTION lv_fm_name
    EXPORTING
      p_vbeln = p_vbeln.

  CALL FUNCTION 'FP_JOB_CLOSE'.
