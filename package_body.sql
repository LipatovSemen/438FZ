-- Start of DDL Script for Package Body GC.SDM$UVSMERFL_438_FZ
-- Generated 06-ноя-2023 17:44:02 from GC@BANK

CREATE OR REPLACE 
PACKAGE BODY sdm$uvsmerfl_438_fz is

 function sdm$uvsmerfl_csv(
    p_filename varchar2,
    p_dir varchar2,
    p_charset varchar2 default 'CL8MSWIN1251',
    p_sep varchar2 default ';',
    p_newline varchar2 default chr(13)||chr(10)
) return sdm$uvsmerfl_row_table pipelined
is
    MAXCOLS constant pls_integer := 5;
    -- для загрузки файла в clob
    l_clob clob;
    l_bfile bfile;
    l_dest_offset number;
    l_src_offset number;
    l_lang_ctx number := 0; -- the default
    l_warning number;
    -- для обработки строк
    l_here pls_integer;
    l_there pls_integer;
    l_line varchar2(32767);
    -- для обработки полей
    l_here1 pls_integer;
    l_there1 pls_integer;
    l_cols dbms_sql.varchar2_table;
begin
    --
    -- загрузка файла в clob
    --
    l_bfile := bfilename(p_dir, p_filename);
    dbms_lob.fileopen(l_bfile);

    dbms_lob.createtemporary(l_clob, true);

    l_dest_offset := 1; -- с начала
    l_src_offset := 1;  -- с начала
    dbms_lob.loadclobfromfile(
        dest_lob    => l_clob,
        src_bfile   => l_bfile,
        amount      => dbms_lob.lobmaxsize,
        dest_offset => l_dest_offset,
        src_offset  => l_src_offset,
        bfile_csid  => nls_charset_id(p_charset),
        lang_context => l_lang_ctx,
        warning     => l_warning
    );
    dbms_lob.fileclose(l_bfile);

    if l_warning != 0 then
        raise_application_error(-20037, 'Error loading file to clob');
    end if;

    --
    -- разбор содержимого файла
    --
    l_here := 1;
    -- для всех строк
    loop
        l_there := instr(l_clob, p_newline, l_here);
        if l_there = 0 then
            l_there := dbms_lob.getlength(l_clob) + 1;
        end if;
        l_line := substr(l_clob, l_here, l_there - l_here);

        l_here1 := 1;
        l_cols.delete;
        -- для всех полей
        loop
            l_there1 := instr(l_line, p_sep, l_here1);
            if l_there1 = 0 then
                l_there1 := length(l_line) + 1;
            end if;
            l_cols(l_cols.count+1) := substr(l_line, l_here1, l_there1 - l_here1);
            l_here1 := l_there1 + length(p_sep);
            exit when l_here1 > length(l_line);
        end loop;
        for i in l_cols.count+1 .. MAXCOLS loop
            l_cols(i) := NULL;
        end loop;
        -- вернуть строку таблицы
        pipe row(sdm$uvsmerfl_row(l_cols(1), l_cols(2), l_cols(3), l_cols(4), l_cols(5),l_cols(6),l_cols(7),l_cols(8),l_cols(9),l_cols(10),l_cols(11),l_cols(12),l_cols(13),l_cols(14),l_cols(15),l_cols(16),l_cols(17),l_cols(18),l_cols(19),l_cols(20) ));

        l_here := l_there + length(p_newline);
        exit when l_here > dbms_lob.getlength(l_clob);
    end loop;
    dbms_lob.freetemporary(l_clob);
    
exception
when no_data_needed then
    dbms_lob.freetemporary(l_clob);
    raise;
end;


function sdm$uvsmerfl_acc_csv(
    p_filename varchar2,
    p_dir varchar2,
    p_charset varchar2 default 'CL8MSWIN1251',
    p_sep varchar2 default ';',
    p_newline varchar2 default chr(10)--chr(13)||chr(10)
) return sdm$uvsmerfl_acc_row_table pipelined
is
    MAXCOLS constant pls_integer := 6;
    -- для загрузки файла в clob
    l_clob clob;
    l_bfile bfile;
    l_dest_offset number;
    l_src_offset number;
    l_lang_ctx number := 0; -- the default
    l_warning number;
    -- для обработки строк
    l_here pls_integer;
    l_there pls_integer;
    l_line varchar2(32767);
    -- для обработки полей
    l_here1 pls_integer;
    l_there1 pls_integer;
    l_cols dbms_sql.varchar2_table;
begin
    --
    -- загрузка файла в clob
    --
    l_bfile := bfilename(p_dir, p_filename);
    dbms_lob.fileopen(l_bfile);

    dbms_lob.createtemporary(l_clob, true);

    l_dest_offset := 1; -- с начала
    l_src_offset := 1;  -- с начала
    dbms_lob.loadclobfromfile(
        dest_lob    => l_clob,
        src_bfile   => l_bfile,
        amount      => dbms_lob.lobmaxsize,
        dest_offset => l_dest_offset,
        src_offset  => l_src_offset,
        bfile_csid  => nls_charset_id(p_charset),
        lang_context => l_lang_ctx,
        warning     => l_warning
    );
    dbms_lob.fileclose(l_bfile);

    if l_warning != 0 then
        raise_application_error(-21001, 'Error loading file to clob');
    end if;

    --
    -- разбор содержимого файла
    --
    l_here := 1;
    -- для всех строк
    loop
        l_there := instr(l_clob, p_newline, l_here);
        if l_there = 0 then
            l_there := dbms_lob.getlength(l_clob) + 1;
        end if;
        l_line := substr(l_clob, l_here, l_there - l_here);

        l_here1 := 1;
        l_cols.delete;
        -- для всех полей
        loop
            l_there1 := instr(l_line, p_sep, l_here1);
            if l_there1 = 0 then
                l_there1 := length(l_line) + 1;
            end if;
            l_cols(l_cols.count+1) := substr(l_line, l_here1, l_there1 - l_here1);
            l_here1 := l_there1 + length(p_sep);
            exit when l_here1 > length(l_line);
        end loop;
        for i in l_cols.count+1 .. MAXCOLS loop
            l_cols(i) := NULL;
        end loop;
        -- вернуть строку таблицы
        pipe row(sdm$uvsmerfl_acc_row(l_cols(1), l_cols(2), l_cols(3), l_cols(4), l_cols(5),l_cols(6) ));

        l_here := l_there + length(p_newline);
        exit when l_here > dbms_lob.getlength(l_clob);
    end loop;
    dbms_lob.freetemporary(l_clob);
    
exception
when no_data_needed then
    dbms_lob.freetemporary(l_clob);
    raise;
end;


end SDM$UVSMERFL_438_FZ;
/



-- End of DDL Script for Package Body GC.SDM$UVSMERFL_438_FZ
