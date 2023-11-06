-- Start of DDL Script for Package GC.SDM$UVSMERFL_438_FZ
-- Generated 06-ноя-2023 17:43:49 from GC@BANK

CREATE OR REPLACE 
package sdm$uvsmerfl_438_fz is


type sdm$uvsmerfl_row is RECORD (
     c1 varchar2(4000),
     c2 varchar2(4000),
     c3 varchar2(4000),
     c4 varchar2(4000),
     c5 varchar2(4000),
     c6 varchar2(4000),
     c7 varchar2(4000),
     c8 varchar2(4000),
     c9 varchar2(4000),
     c10 varchar2(4000),
     c11 varchar2(4000),
     c12 varchar2(4000),
     c13 varchar2(4000),
     c14 varchar2(4000),
     c15 varchar2(4000),
     c16 varchar2(4000),
     c17 varchar2(4000),
     c18 varchar2(4000),
     c19 varchar2(4000),
     c20 varchar2(4000)          
    );



type sdm$uvsmerfl_row_table is table of sdm$uvsmerfl_row;


type sdm$uvsmerfl_acc_row is RECORD (
     c1 varchar2(4000),
     c2 varchar2(4000),
     c3 varchar2(4000),
     c4 varchar2(4000),
     c5 varchar2(4000),
     c6 varchar2(4000)
     
     
    );


type sdm$uvsmerfl_acc_row_table is table of sdm$uvsmerfl_acc_row;

                      
function sdm$uvsmerfl_csv(
    p_filename varchar2,
    p_dir varchar2,
    p_charset varchar2 default 'CL8MSWIN1251',
    p_sep varchar2 default ';',
    p_newline varchar2 default chr(13)||chr(10)
) return sdm$uvsmerfl_row_table pipelined ;                 


function sdm$uvsmerfl_acc_csv(
    p_filename varchar2,
    p_dir varchar2,
    p_charset varchar2 default 'CL8MSWIN1251',
    p_sep varchar2 default ';',
    p_newline varchar2 default chr(10)--chr(13)||chr(10)
) return sdm$uvsmerfl_acc_row_table pipelined ;   
  
end SDM$UVSMERFL_438_FZ;
/



-- End of DDL Script for Package GC.SDM$UVSMERFL_438_FZ
