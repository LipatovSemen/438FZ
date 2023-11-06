-- Start of DDL Script for Procedure GC.SDM$PROCFILE_438FZ
-- Generated 06-ноя-2023 17:43:20 from GC@BANK

CREATE OR REPLACE 
PROCEDURE sdm$procfile_438fz IS
vSUBJ_ID VARCHAR(12);
vCNT_ALREADY_PROC number;
vIDC VARCHAR(10);
vTXT clob;

BEGIN
--ОБРАБОТКА ФАЙЛА ИЗ СМЭВ
GC.P_SUPPORT.ARM_START();

vCNT_ALREADY_PROC:=0;

FOR I IN (
--Найдем не обработанную запись
--Если несколько счетов поступили, то найдем максимальный, чтобы просто идентифицировать subj_id.
--Счета насчитаем позже
SELECT DISTINCT 
       U.ID
      ,U.ID_ZAP
      ,MAX(UA.NUM_ACC) NUM_ACC
      ,TO_DATE(U.DATE_DEATH,'YYYY-MM-DD') DATE_DEATH 
      FROM GC.SDM$UVSMERFL U
          ,GC.SDM$UVSMERFL_ACC UA
WHERE 1=1
  AND U.ID = UA.ID_SVED_ACC          
  AND NOT EXISTS (SELECT 1 FROM GC.SDM$UVSMERFL_PROTOCOL S
                      WHERE 1=1
                        AND S.ID = U.ID
                        AND S.ID_ZAP = U.ID_ZAP
                        AND S.STATUS in ('Обработана','Клиент не идентифицирован')
                        )
  GROUP BY U.ID,U.ID_ZAP,U.DATE_DEATH                          
   )                        
LOOP
INSERT INTO GC.SDM$UVSMERFL_PROTOCOL     
SELECT I.ID,I.ID_ZAP,NULL,'Начало обработки' FROM DUAL;  

--Идентифицируем клиента по номеру счета, который нам прислали ФНС
BEGIN
SELECT max(s.ID)
into vSUBJ_ID
   FROM GC.NNS_LIST N
       ,GC.VW$ACC_ACCA A
       ,GC.SUBJ S
WHERE 1=1
  AND N.NNS = i.NUM_ACC   
  AND A.S = N.S
  AND A.CUR = N.CUR
  AND S.ID = A.SUBJ_ID;
EXCEPTION WHEN NO_DATA_FOUND THEN  
vSUBJ_ID :='';
END;


IF vSUBJ_ID = '' or vSUBJ_ID is null  THEN   
UPDATE GC.SDM$UVSMERFL_PROTOCOL 
SET SUBJ_ID = vSUBJ_ID
   ,STATUS = 'Клиент не идентифицирован'
WHERE ID = i.ID
  AND ID_ZAP = i.ID_ZAP;
END IF;     

--Проверим вдруг мы этого клиента уже обрабатывали
IF vSUBJ_ID is not null THEN
dbms_output.put_line(vSUBJ_ID);
SELECT COUNT(*)
 INTO vCNT_ALREADY_PROC
   FROM GC.SDM$UVSMERFL_PROTOCOL
WHERE 1=1
  AND SUBJ_ID = vSUBJ_ID
  AND STATUS = 'Обработана';
END IF;  

--Помечаем запись как обработанную  
IF vCNT_ALREADY_PROC > 0 THEN
UPDATE GC.SDM$UVSMERFL_PROTOCOL 
SET SUBJ_ID = vSUBJ_ID
   ,STATUS = 'Обработана'
WHERE ID = i.ID
  AND ID_ZAP = i.ID_ZAP;
END IF;  


--Если идентификация пройдена и нет обработанных записей, то начинаем блокировать
IF vSUBJ_ID is not null and vCNT_ALREADY_PROC = 0 THEN
dbms_output.put_line(vSUBJ_ID);
update gc.human 
set date_out = i.DATE_DEATH
   ,date_death = i.DATE_DEATH
where subj_id = vSUBJ_ID;
--Дата выбытия
gc.JOUR_PACK.add_to_journal('HUMAN', vSUBJ_ID, 'JDS00071', 'U', '', to_char(i.DATE_DEATH,'dd-mm-yyyy'), 'На основании данных полученных от ФНС через СМЭВ');
--Дата смерти
gc.JOUR_PACK.add_to_journal('HUMAN', vSUBJ_ID, 'JDS00124', 'U', '', to_char(i.DATE_DEATH,'dd-mm-yyyy'), 'На основании данных полученных от ФНС через СМЭВ');  

update gc.dog d
set tex = tex||chr(13)||chr(10)||'Клиент умер '||to_char(i.DATE_DEATH,'dd-mm-yyyy')||' - поступила информация от ФНС о клиенте, снятом с учета по причине смерти'
where 1=1
  and d.subj_id = vSUBJ_ID;

------------БЛОКИРОВКА КАРТ----------------------------------
            FOR III IN (SELECT C.ID,C.PAN,D.OBJID 
                        FROM GC.UC$CARDS C
                            ,GC.UC$CARD_ACCOUNTS UC
                            ,GC.DOG D
                            ,GC.RBD$CARDS RC
                        WHERE UC.ID=C.ID_ACCOUNT
                        AND RC.ID=C.ID
                        AND RC.ID_STATE IN ('19106271')
                        AND UC.ID_DOG = D.OBJID
                        AND D.SUBJ_ID = vSUBJ_ID)
   
            LOOP
    
            vIDC := GC.RBD_CARD_BLOCK(PID_CARD       => iii.id,
                           PID_PROCESSING => '19106685',
                           PCOMMENT_TEXT  => 'Получены данные из ФНС о смерти клиента',
                           PID_STATE      => '19106272',
                           pSTATE_CODE_PC => 'SDMIBK',   --- по требованию клиента (отправляется корректная СМС!!!) Возможно не правильно
                           pF_ONLINE      => 'Y',
                           pF_IMMEDIATE   => 'Y').ID;
    
            COMMIT;
            END LOOP;
------------БЛОКИРОВКА КАРТ---------------------------------- 

--Поменяем статус 
UPDATE GC.SDM$UVSMERFL_PROTOCOL 
SET SUBJ_ID = vSUBJ_ID
   ,STATUS = 'Обработана'
WHERE ID = i.ID
  AND ID_ZAP = i.ID_ZAP;
  
  
END IF;
--Конец блокировки клиента   






COMMIT;


vTXT:='                     Внимание!    Поступили данные по умершим клиентам! 
       <br>
       <table width="70%" sellpadding="25" border="1">
        ';

vTXT:=vTxt||'
    <tr>
      <td width="90%" align="left">'||'ФИО'||'</td>
      <td width="15%" align="center">'||'Дата рождения'||'</td>
      <td width="15%" align="right">'||'ИНН'||'</td>
      <td width="20%" align="center">'||'Номер счета'||'</td>
      <td width="120%" align="center">'||'Филиал/Отделение'||'</td>
      <td width="20%" align="left">'||'Результат'||'</td>
      <td width="15%" align="left">'||'Дата'||'</td>
      </tr>'
      ;   

FOR II IN (
SELECT DISTINCT 
       U.ID
      ,U.ID_ZAP
      ,UA.NUM_ACC
      ,(SELECT max(gc.a_otdelenie_fil(decode(a.filial,'M','382',a.filial))||'/'||decode(ss.name,'0','ОТДЕЛЕНИЕ "ЦЕНТРАЛЬНОЕ"',a.filial,'ОТДЕЛЕНИЕ "ЦЕНТРАЛЬНОЕ"',null,'ОТДЕЛЕНИЕ "ЦЕНТРАЛЬНОЕ"',ss.Name)) FIL FROM GC.NNS_LIST N,GC.ACC A,GC.SUBJ SS WHERE N.NNS = UA.NUM_ACC AND N.ENDDAT > SYSDATE AND A.S = N.S AND A.OTDEL = SS.ID(+)) OTD_FIL
      ,TO_CHAR(TO_DATE(U.DATE_DEATH,'YYYY-MM-DD'),'DD.MM.YYYY') DATE_DEATH
      ,TO_CHAR(TO_DATE(U.DATE_BIRTH,'YYYY-MM-DD'),'DD.MM.YYYY') DATE_BIRTH
      ,UPPER(U.FIO_SURNAME||' '||U.FIO_NAME||' '||U.FIO_PATR) FIO 
      ,U.INN_FL
      ,P.STATUS
      FROM GC.SDM$UVSMERFL U
          ,GC.SDM$UVSMERFL_ACC UA
          ,GC.SDM$UVSMERFL_PROTOCOL P
WHERE 1=1
  AND U.ID = I.ID
  AND U.ID = UA.ID_SVED_ACC
  AND P.ID (+)= U.ID
  )
  LOOP

     

vTXT:=vTxt||'
    <tr>
      <td width="90%" align="left">'||ii.FIO||'</td>
      <td width="15%" align="center">'||ii.DATE_BIRTH||'</td>
      <td width="15%" align="right">'||ii.INN_FL||'</td>
      <td width="20%" align="center">'||ii.NUM_ACC||'</td>
      <td width="120%" align="center">'||ii.OTD_FIL||'</td>
      <td width="20%" align="left">'||ii.STATUS||'</td>
      <td width="15%" align="left">'||to_char(sysdate,'DD.MM.YYYY')||'</td>
      </tr>'
      ;
      
  END LOOP;      
      
IF ORA_DATABASE_NAME = 'BANK' THEN

gc.mail_pkg.SEND ('arhipova.yb@sdm.ru,bugrov.mm@sdm.ru,Glebova.ma@sdm.ru,lipatov.syu@sdm.ru,Malinovskiy.ay@sdm.ru,OLaritskiyVP@sdm.ru,Bubenkov.na@sdm.ru'
                , 'Внимание! Поступили данные по умершим клиентам'
                , vTXT
                , 'noreply_rbs@sdm.ru'
                ,'text/html'
                );
END IF;                      
        


  
END LOOP;

END;
/

-- Grants for Procedure
GRANT EXECUTE ON sdm$procfile_438fz TO public
/


-- End of DDL Script for Procedure GC.SDM$PROCFILE_438FZ
