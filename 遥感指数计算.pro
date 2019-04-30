PRO exercise1_1

    ;0：不执行，1：MNDWI，2：NDBI，3：EVI，4：NDVI
    mark = 1;

    ;读取影像
    filename = DIALOG_PICKFILE(title = '请选择遥感影像:')
    ENVI_OPEN_FILE, filename, r_fid=fid
    ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims
    map_info = ENVI_GET_MAP_INFO(fid=fid)
    b1 = FLOAT(ENVI_GET_DATA(fid=fid, dims=dims, pos=0))    ;蓝
    b2 = FLOAT(ENVI_GET_DATA(fid=fid, dims=dims, pos=1))    ;绿
    b3 = FLOAT(ENVI_GET_DATA(fid=fid, dims=dims, pos=2))    ;红
    b4 = FLOAT(ENVI_GET_DATA(fid=fid, dims=dims, pos=3))    ;近红外
    b5 = FLOAT(ENVI_GET_DATA(fid=fid, dims=dims, pos=4))    ;短波红外


    ;各种指数计算
    CASE mark OF
        0: index = []
        1: index = FLOAT(b2-b5)/FLOAT(b2+b5)
        2: index = FLOAT(b4-b5)/FLOAT(b4+b5)
        3: index = 2.5*FLOAT(b4-b3)/FLOAT(b4+6.0*b3-7.5*b1+1.0)
        4: index = FLOAT(b4-b3)/FLOAT(b4+b3)
    ENDCASE
    IF N_ELEMENTS(index) NE 0 THEN BEGIN
        filename = DIALOG_PICKFILE(title = '影像输出：')
        ENVI_WRITE_ENVI_FILE, index, Out_Name = filename, map_info=map_info
    ENDIF

    ;清空缓存
    ENVI_FILE_MNG, id=fid, /remove
    PRINT, 'Process over'
END