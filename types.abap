TYPES: BEGIN OF ty_header,
         vbeln TYPE vbeln_va, " Sales Document
         erdat TYPE erdat,    " Date of creation
         erzet TYPE erzet,    " Entry Time
         ernam TYPE ernam,    " Person who created the Object
         vbtyp TYPE vbtyp,    " SD category
       END OF ty_header,


       BEGIN OF ty_item,
         vbeln TYPE vbeln_va,   " Sales Document
         posnr TYPE posnr_va,   " Sales Document Item
         netwr TYPE netwr_ap,   " Net value of the order item in document currency
         waerk TYPE waerk,      " SD Document Currency
       END OF ty_item,

       tty_items TYPE TABLE OF ty_item.
