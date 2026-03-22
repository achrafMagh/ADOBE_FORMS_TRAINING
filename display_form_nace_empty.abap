TABLES: nast.

DATA: lv_fm_name      TYPE funcname,
      ls_outputparams TYPE sfpoutputparams,
      ls_docparams    TYPE sfpdocparams,
      ls_formoutput   TYPE fpformoutput.
      //déclaration des variables

FORM entry USING us_retco TYPE sy-subrc
                 us_screen TYPE c.
  "Récupération des données


  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'ZFF_SD_INVOICE_FORM_V10'
    IMPORTING
      e_funcname = lv_fm_name.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = ls_outputparams
    EXCEPTIONS
      cancel          = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    us_retco = 1.
    RETURN.
  ENDIF.
  BREAK-POINT.

  CALL FUNCTION lv_fm_name
    EXPORTING
      /1bcdwb/docparams  = ls_docparams
      //imports 
    IMPORTING
      /1bcdwb/formoutput = ls_formoutput
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
        
  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error = 1
      OTHERS      = 2.

ENDFORM.
