PRO exercise1_2
    
    ;1植被区，2水体，3城区
    mark = 1

    ;掩膜运输
    filename = DIALOG_PICKFILE(title = '请选择遥感影像:')
    ENVI_OPEN_FILE, filename, r_fid=fid
    ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims
    map_info = ENVI_GET_MAP_INFO(fid=fid)
    band = FLOAT(ENVI_GET_DATA(fid=fid, dims=dims, pos=0))

    ;按要求掩膜
    CASE mark OF
        1: band[WHERE(band GT -0.5)] = 0
        2: band[WHERE(band LE 0)] = 0
        3: band[WHERE(band GT -0.5)] = 0
    ENDCASE
    
    ;输出掩膜后的文件
    filename = DIALOG_PICKFILE(title = '影像输出：')
    ENVI_WRITE_ENVI_FILE, band, Out_Name = filename, map_info=map_info
    
    ;清空缓存区
    ENVI_FILE_MNG, id=fid, /remove
    PRINT, 'Process over'
END