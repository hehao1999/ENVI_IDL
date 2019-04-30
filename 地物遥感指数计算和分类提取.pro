;掩膜提取
PRO exercise1

    ;参数设置----11水体，22城区，33、44植被区
    mark = 1
    index_mark = mark

    ;选择原始影像
    filename = DIALOG_PICKFILE(title = '请选择遥感影像:')
    ENVI_OPEN_FILE, filename, r_fid=fid
    ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims
    map_info = ENVI_GET_MAP_INFO(fid=fid)
    bands = FINDGEN(ns,nl,nb)
    FOR i=0, nb-1 DO BEGIN
        bands[*,*,i] = FLOAT(ENVI_GET_DATA(fid=fid, dims=dims,pos=i))
    ENDFOR

    ;指数计算
    index_ = index(bands, index_mark)

    ;按提取地物类型掩膜
    mask = INTARR(ns,nl)+1
    SWITCH mark OF
        1:BEGIN
            mask[WHERE(index_ LT -0.16)]= 0
            FOR i=0, nb-1 DO BEGIN
                bands[*,*,i] *= mask
            ENDFOR
            BREAK
        END
        2: BEGIN
            mask[WHERE(index_ GT 0)] = 0
            FOR i=0, nb-1 DO BEGIN
                bands[*,*,i] *= mask
            ENDFOR
            BREAK
        END
        3: BEGIN
            mask[WHERE(index_ LT 0.2)] = 0
            FOR i=0, nb-1 DO BEGIN
                bands[*,*,i] *= mask
            ENDFOR
            BREAK
        END
        4: BEGIN
            mask[WHERE(index_ LT 0.55)] = 0
            FOR i=0, nb-1 DO BEGIN
                bands[*,*,i] *= mask
            ENDFOR
            BREAK
        END
    ENDSWITCH
    ;输出掩膜后的文件
    filename = DIALOG_PICKFILE(title = '影像输出：')
    ENVI_WRITE_ENVI_FILE, bands, Out_Name = filename, map_info=map_info

    ;清空缓存区
    ENVI_FILE_MNG, id=fid, /remove
    PRINT, 'Process over'
END

FUNCTION index, bands, mark
    ;各种指数计算
    CASE mark OF
        ;1：MNDWI，2：NDBI，3：EVI，4：NDVI
        1: index_ = FLOAT(bands[*,*,1]-bands[*,*,4])/FLOAT(bands[*,*,1]+bands[*,*,4])
        2: index_ = FLOAT(bands[*,*,3]-bands[*,*,4])/FLOAT(bands[*,*,3]+bands[*,*,4])
        3: index_ = 2.5*FLOAT(bands[*,*,3]-bands[*,*,2])/FLOAT(bands[*,*,3]+6.0*bands[*,*,2]-7.5*bands[*,*,0]+10000.0)
        4: index_ = FLOAT(bands[*,*,3]-bands[*,*,2])/FLOAT(bands[*,*,3]+bands[*,*,2])
        ELSE: index_ = 0
        
    ENDCASE
    RETURN, index_
END
