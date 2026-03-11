REPORT test_form_xml.

DATA: lv_fm_name   TYPE funcname,
      ls_output    TYPE sfpoutputparams,
      ls_docparams TYPE sfpdocparams,
      lv_xml       TYPE string,
      lv_xstring   TYPE xstring.

START-OF-SELECTION.

  lv_xml = `<?xml version="1.0" encoding="UTF-8"?>` &&
           `<SalesDocument><Header>` &&
           `<VBELN>0000012345</VBELN>` &&
           `<ERDAT>15.01.2024</ERDAT>` &&
           `<ERZET>10:30:00</ERZET>` &&
           `<ERNAM>TESTUSER</ERNAM>` &&
           `<VBTYP>C</VBTYP>` &&
           `</Header><Items>` &&
           `<Item><POSNR>000010</POSNR><NETWR>250.00</NETWR><WAERK>EUR</WAERK></Item>` &&
           `<Item><POSNR>000020</POSNR><NETWR>130.50</NETWR><WAERK>EUR</WAERK></Item>` &&
           `</Items></SalesDocument>`.

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING text   = lv_xml
    IMPORTING buffer = lv_xstring.

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING i_name     = 'ZFF_SALES_XM_2'
    IMPORTING e_funcname = lv_fm_name.

  ls_output-preview  = abap_true.
  ls_output-nodialog = abap_true.
  ls_docparams-langu = 'F'.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING ie_outputparams = ls_output.

  CALL FUNCTION lv_fm_name
    EXPORTING
      /1bcdwb/docparams = ls_docparams
      /1bcdwb/docxml    = lv_xstring.

  CALL FUNCTION 'FP_JOB_CLOSE'.
