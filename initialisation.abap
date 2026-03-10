SELECT SINGLE vbeln, erdat, erzet, ernam, vbtyp
  FROM vbak
  INTO CORRESPONDING FIELDS OF @gs_header
  WHERE vbeln = @p_vbeln.

IF gs_header-vbeln IS NOT INITIAL.
  SELECT vbeln, posnr, netwr, waerk
    FROM vbap
    INTO CORRESPONDING FIELDS OF TABLE @gt_items
    WHERE vbeln = @p_vbeln.
ENDIF.


DATA lv_item TYPE ty_item.

DO 100 TIMES.
  lv_item-posnr = '10'.
  lv_item-netwr = '100'.
  lv_item-waerk = 'EUR'.
ENDDO.
