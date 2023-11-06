-- Start of DDL Script for Procedure GC.SDM$LOADFILE_438FZ
-- Generated 06-ноя-2023 17:43:02 from GC@BANK

CREATE OR REPLACE 
PROCEDURE sdm$loadfile_438fz IS
--vFILENAME_INFO_CL VARCHAR(40);
--vFILENAME_INFO_ACC VARCHAR(40);
vCOUNT_LINE_CL NUMBER; 
vCOUNT_LINE_ACC NUMBER; 


BEGIN
vCOUNT_LINE_CL:=0;
vCOUNT_LINE_ACC:=0;


FOR I IN (
--Грузим файл с клиентами
--Функция list_files ищет файлы в директории /u/sdm в наименовании которых есть FL
SELECT replace(column_value,'/u/sdm/','') FILENAME_INFO_CL
    FROM TABLE(list_files('FL'))
WHERE 1=1
  AND COLUMN_VALUE NOT LIKE '%A%FL%'
)

LOOP


INSERT INTO GC.SDM$UVSMERFL
select * from table(SDM$UVSMERFL_438_FZ.sdm$uvsmerfl_csv(i.FILENAME_INFO_CL, '/u/sdm'));
commit;



--После обработки файла - удаляем его из директории
--Подумать по поводу копирования!! 
BEGIN
UTL_FILE.FREMOVE('/u/sdm',i.FILENAME_INFO_CL);
EXCEPTION WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
COMMIT;

END LOOP;






FOR II IN (
--Грузим файл с счетами
--Функция list_files ищет файлы в директории /u/sdm в наименовании которых есть A%FL
SELECT replace(column_value,'/u/sdm/','') FILENAME_INFO_ACC
    FROM TABLE(list_files('A%FL'))
WHERE 1=1
)

loop


INSERT INTO GC.SDM$UVSMERFL_ACC
select * from table(SDM$UVSMERFL_438_FZ.sdm$uvsmerfl_acc_csv(ii.FILENAME_INFO_ACC, '/u/sdm'));
commit;
  

--После обработки файла - удаляем его из директории
--Подумать по поводу копирования!! 
BEGIN
UTL_FILE.FREMOVE('/u/sdm',ii.FILENAME_INFO_ACC);
EXCEPTION WHEN OTHERS THEN
NULL;
END;
COMMIT;

END LOOP;


--Запуск процедуры по блокировке
GC.SDM$PROCFILE_438FZ;


END;
/

-- Grants for Procedure
GRANT EXECUTE ON sdm$loadfile_438fz TO public
/


-- End of DDL Script for Procedure GC.SDM$LOADFILE_438FZ
