create table gc.sdm$uvsmerfl
       (
 ID varchar2(50)
,ID_ZAP varchar2(36)
,DATE_GEN_NOTIF varchar2(10)
,INN_FL varchar2(12)
,DATE_BIRTH varchar2(10)
,DATE_DEATH varchar2(10)
,VEND_MNEM varchar2(13)
,NUM_ACT_DEATH varchar2(22)
,DATE_RECR_ACT_DEATH varchar2(10)
,FULL_NAME_ZAGS varchar2(1000)
,CODE_ZAGS varchar2(8)
,FIO_SURNAME varchar2(60)
,FIO_ATTR_SURNAME varchar2(1)
,FIO_NAME varchar2(60)
,FIO_ATTR_NAME varchar2(1)
,FIO_PATR varchar2(60)
,FIO_ATTR_PATR varchar2(1)
,DUL_TYPE_CODE varchar2(2)
,DUL_SERIES_NUMBER varchar2(25)
,DUL_DATE_ISSUE varchar2(10) );


create table gc.sdm$uvsmerfl_acc
       (
 ID_SVED_ACC varchar2(50)
,NUM_FIL_BANK varchar2(4)
,NUM_ACC varchar2(20)
,DATE_OPEN_ACC varchar2(10)
,CODE_CURR_ACC varchar2(3)
,CODE_TYPE_ACC varchar2(4)
 );


create table gc.sdm$uvsmerfl_protocol
       (
 ID varchar2(50)
,ID_ZAP varchar2(36)
,SUBJ_ID varchar2(12)
,STATUS varchar2(50)
 );
