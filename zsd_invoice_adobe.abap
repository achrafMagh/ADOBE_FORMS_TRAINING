TABLES: nast. "NACE remplit automatiquement nast-objky avec le numéro de la facture à imprimer

DATA: lv_fm_name      TYPE funcname,
      ls_outputparams TYPE sfpoutputparams,
      ls_docparams    TYPE sfpdocparams,
      ls_formoutput   TYPE fpformoutput,
      ls_vbrk         TYPE vbrk,
      lt_vbrp         TYPE ztt_vbrp,
      gv_title        TYPE string.

FORM entry USING us_retco TYPE sy-subrc "Routine utiliser pour imprimer le formulaire
                 us_screen TYPE c.

  " ── 1. N° document depuis NAST ──────────────
  lv_vbeln = nast-objky.

  " ── 2. Lire données métier ──────────────────
  SELECT SINGLE * FROM vbrk
    INTO ls_vbrk
    WHERE vbeln = lv_vbeln.

  IF sy-subrc <> 0.          " ← Vérifier ICI !
    us_retco = 1.
    RETURN.
  ENDIF.

  SELECT * FROM vbrp
    INTO TABLE lt_vbrp
    WHERE vbeln = lv_vbeln.

  " ── 3. Préparer le titre ────────────────────   "Exercice
"DATA: lv_vbeln        TYPE vbeln_vf,  "Exercice, on veut 
        "lv_dd           TYPE c LENGTH 2,
        "lv_mm           TYPE c LENGTH 2,
        "lv_yyyy         TYPE c LENGTH 4.
 " lv_dd   = sy-datum+6(2). "Exercice
  "lv_mm   = sy-datum+4(2).
  "lv_yyyy = sy-datum(4).
 " CONCATENATE 'Facture: ' lv_dd '/' lv_mm '/' lv_yyyy
 "   INTO gv_title.

  " ── 4. FM généré par SFP ────────────────────
  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME' "SAP traduit le nom du formulaire SFP en nom du FM technique généré /1BCDWB/..
    EXPORTING
      i_name     = 'ZFF_SD_INVOICE_FORM'
    IMPORTING
      e_funcname = lv_fm_name.

  " ── 5. Paramètres output ──────────────────── (Optionnel)
  IF us_screen = 'X'.          "Décide si le PDF s'affiche à l'écran (aperçu) ou part à l'imprimante 
    ls_outputparams-preview  = 'X'.
  ELSE.
    ls_outputparams-dest     = nast-ldest.
  ENDIF.
  ls_outputparams-nodialog = 'X'.

  " ── 6. Paramètres document ──────────────────
  ls_docparams-langu   = nast-spras.     "Définit la langue et le pays du document PDF
  ls_docparams-country = 'FR'.

  " ── 7. Ouvrir job Adobe ─────────────────────
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

  " ── 8. Appeler le formulaire ────────────────
  CALL FUNCTION lv_fm_name
    EXPORTING
      /1bcdwb/docparams  = ls_docparams
      is_vbrk            = ls_vbrk "Passe toutes les données au formulaire Adobe qui génère le PDF
  "    it_vbrp            = lt_vbrp
 "     iv_title           = gv_title
    IMPORTING
      /1bcdwb/formoutput = ls_formoutput
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.

  IF sy-subrc <> 0.
    us_retco = 1.
    CALL FUNCTION 'FP_JOB_CLOSE'.
    RETURN.
  ENDIF.

  " ── 9. Fermer job Adobe ─────────────────────
  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error = 1
      OTHERS      = 2.

  us_retco = 0.

ENDFORM.
