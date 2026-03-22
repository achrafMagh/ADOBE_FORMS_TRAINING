REPORT ZSD_INVOICE_ADOBE_EMPTY.

TABLES: nast, vbrk, vbrp.

DATA: lv_fm_name      TYPE funcname,
      ls_outputparams TYPE sfpoutputparams,
      ls_docparams    TYPE sfpdocparams,
      ls_formoutput   TYPE fpformoutput,
      lv_vbeln        TYPE vbeln_vf,
      ls_vbrk         TYPE vbrk,
      lt_vbrp         TYPE ztt_vbrp,
      lv_title        TYPE string.

FORM entry USING us_retco TYPE sy-subrc
                 us_screen TYPE c.

  lv_vbeln = nast-objky.

  SELECT SINGLE * FROM vbrk
    INTO @ls_vbrk
    WHERE vbeln = @lv_vbeln.

  SELECT * FROM vbrp
    INTO TABLE @lt_vbrp
    WHERE vbeln = @lv_vbeln.

  DATA(lv_dd)   = sy-datum+6(2).
  DATA(lv_mm)   = sy-datum+4(2).
  DATA(lv_yyyy) = sy-datum(4).
  CONCATENATE 'Facture: ' lv_dd '/' lv_mm '/' lv_yyyy
    INTO lv_title.

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

  CALL FUNCTION lv_fm_name
    EXPORTING
      /1bcdwb/docparams  = ls_docparams
      is_vbrk            = ls_vbrk
      it_vbrp            = lt_vbrp
      iv_title           = lv_title
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
