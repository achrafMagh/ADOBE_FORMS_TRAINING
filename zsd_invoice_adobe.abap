*&---------------------------------------------------------------------*
*& Report ZSD_INVOICE_ADOBE_V10
*& Programme de sortie Adobe Forms — Facture SD
*& Appelé par NACE (V3/RD00) via la routine ENTRY
*&---------------------------------------------------------------------*
REPORT ZSD_INVOICE_ADOBE_V10.

*--------------------------------------------------------------*
* TABLES : NAST est remplie automatiquement par NACE
*          avec les données du message (n° doc, langue...)
*--------------------------------------------------------------*
TABLES: nast.

*--------------------------------------------------------------*
* DONNÉES GLOBALES
*--------------------------------------------------------------*
DATA: lv_fm_name      TYPE funcname,        " Nom du FM généré par SFP
      ls_outputparams TYPE sfpoutputparams, " Paramètres impression/aperçu
      ls_docparams    TYPE sfpdocparams,    " Paramètres langue/pays du PDF
      ls_formoutput   TYPE fpformoutput,    " Résultat retourné par le FM
      lv_vbeln        TYPE vbeln_vf,        " N° de facture extrait de NAST
      ls_vbrk         TYPE vbrk,            " Entête de la facture
      lt_vbrp         TYPE ztt_vbrp,        " Postes de la facture
      lv_title        TYPE string.          " Titre affiché dans le formulaire

*--------------------------------------------------------------*
* FORM ENTRY
* Point d'entrée appelé par NACE pour chaque message à traiter
* Signature imposée par SAP — ne jamais la modifier !
*   us_retco : 0 = succès | 1 = erreur
*   us_screen : 'X' = aperçu écran | ' ' = impression
*--------------------------------------------------------------*
FORM entry USING us_retco TYPE sy-subrc
                 us_screen TYPE c.

  " ── 1. Récupérer le N° de facture depuis NAST ───────────
  " nast-objky est rempli automatiquement par SAP
  " avec la clé du document à imprimer
  lv_vbeln = nast-objky.

  " ── 2. Lire l'entête de la facture ──────────────────────
  " SELECT SINGLE car on lit un seul document
  SELECT SINGLE * FROM vbrk
    INTO ls_vbrk
    WHERE vbeln = lv_vbeln.

  " Vérifier immédiatement après le SELECT !
  " Si la facture n'existe pas → signaler l'erreur à NACE
  IF sy-subrc <> 0.
    us_retco = 1.
    RETURN.
  ENDIF.

  " ── 3. Lire les postes de la facture ────────────────────
  " Tous les postes de ce document dans la table interne
  SELECT * FROM vbrp
    INTO TABLE lt_vbrp
    WHERE vbeln = lv_vbeln.

  " ── 4. Construire le titre du formulaire ────────────────
  " Formatage de la date du jour en DD/MM/YYYY
  DATA(lv_dd)   = sy-datum+6(2).  " Jour   : positions 6-7
  DATA(lv_mm)   = sy-datum+4(2).  " Mois   : positions 4-5
  DATA(lv_yyyy) = sy-datum(4).    " Année  : positions 0-3
  CONCATENATE 'Facture: ' lv_dd '/' lv_mm '/' lv_yyyy
    INTO lv_title.

  " ── 5. Récupérer le FM généré par SFP ───────────────────
  " SFP génère un FM technique (/1BCDWB/...) à partir du
  " formulaire — FP_FUNCTION_MODULE_NAME donne son nom exact
  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'ZFF_SD_INVOICE_FORM_V10'  " Nom du formulaire SFP
    IMPORTING
      e_funcname = lv_fm_name.                 " → /1BCDWB/SM0000XXXX

  " ── 6. Configurer les paramètres de sortie ──────────────
  " us_screen détermine si l'utilisateur veut un aperçu ou une impression
  IF us_screen = 'X'.
    ls_outputparams-preview = 'X'.      " Aperçu PDF à l'écran
  ELSE.
    ls_outputparams-dest = nast-ldest.  " Imprimante configurée dans NAST
  ENDIF.
  ls_outputparams-nodialog = 'X'.       " Pas de popup de dialogue

  " ── 7. Configurer les paramètres du document PDF ────────
  " La langue et le pays viennent directement de NAST
  ls_docparams-langu   = nast-spras.  " Langue du message (F, E, D...)
  ls_docparams-country = 'FR'.        " Pays pour le formatage (monnaie...)

  " ── 8. Ouvrir le moteur Adobe Forms ─────────────────────
  " Obligatoire avant tout appel de formulaire
  " Toujours en paire avec FP_JOB_CLOSE !
  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = ls_outputparams
    EXCEPTIONS
      cancel          = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    us_retco = 1.  " Erreur ouverture moteur PDF
    RETURN.
  ENDIF.

  " ── 9. Appeler le formulaire Adobe ──────────────────────
  " Appel DYNAMIQUE via lv_fm_name
  " Les noms des paramètres DOIVENT correspondre
  " exactement à ceux définis dans l'interface SFP !
  CALL FUNCTION lv_fm_name
    EXPORTING
      /1bcdwb/docparams  = ls_docparams  " Paramètres Adobe obligatoires
      is_vbrk            = ls_vbrk       " Entête facture → IS_VBRK dans SFP
      it_vbrp            = lt_vbrp       " Postes facture → IT_VBRP dans SFP
      iv_title           = lv_title      " Titre du doc  → IV_TITLE dans SFP
    IMPORTING
      /1bcdwb/formoutput = ls_formoutput " Résultat PDF retourné
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.

  IF sy-subrc <> 0.
    us_retco = 1.
    CALL FUNCTION 'FP_JOB_CLOSE'.  " Toujours fermer même en cas d'erreur !
    RETURN.
  ENDIF.

  " ── 10. Fermer le moteur Adobe Forms ────────────────────
  " Libère les ressources et finalise le PDF
  " Toujours en paire avec FP_JOB_OPEN !
  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error = 1
      OTHERS      = 2.

  us_retco = 0.  " Succès — NACE marque le message comme traité ✅

ENDFORM.
