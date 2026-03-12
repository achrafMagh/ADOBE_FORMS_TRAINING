
*&---------------------------------------------------------------------*
*& Report Z_TEST_PERSON_XML
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_TEST_PERSON_XML.



DATA: lv_fm_name   TYPE funcname,
      ls_output    TYPE sfpoutputparams,
      ls_docparams TYPE sfpdocparams,
      lv_xml       TYPE string,
      lv_xstring   TYPE xstring.

START-OF-SELECTION.

  lv_xml = `<?xml version="1.0" encoding="UTF-8"?>` &&
         `<PersonDocument>` &&
           `<Consultant>` &&
             `<Name>John Doe</Name>` &&
             `<Age>35</Age>` &&
             `<Poste>Chef de projet SAP</Poste>` &&
           `</Consultant>` &&
         `</PersonDocument>`.

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING text   = lv_xml
    IMPORTING buffer = lv_xstring.

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING i_name     = 'ZFF_SALES_PERSON_XML'
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
