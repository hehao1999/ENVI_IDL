PRO exercise3
    ;读取多个hdf4文件
    filenames = DIALOG_PICKFILE(title='请选择遥感影像', filter='*.hdf', /multiple_files)
    file_num = N_ELEMENTS(filenames)

    ;获取影像信息
    ENVI_OPEN_FILE, filenames[0], R_FID = hdf_fid
    ENVI_FILE_QUERY, hdf_fid, ns=ns, nl=nl, data_type=data_type, dims=dims
    map_info = ENVI_GET_MAP_INFO(fid=hdf_fid)

    ;构造影像数组
    ;根据文件类型打开遥感影像
    CASE data_type OF
        1:ImgData = BYTARR(ns, nl, file_num)        ;  BYTE  Byte
        2:ImgData = INTARR(ns, nl, file_num)        ;  INT  Integer
        3:ImgData = LONARR(ns, nl, file_num)        ;  LONG  Longword integer
        4:ImgData = FLTARR(ns, nl, file_num)        ;  FLOAT  Floating point
        5:ImgData = DBLARR(ns, nl, file_num)        ;  DOUBLE  Double-precision floating
        6:ImgData = COMPLEXARR(ns, nl ,file_num)    ;  complex, single-precision, floating-point
        9:ImgData = DCOMPLEXARR(ns, nl, file_num)   ;  complex, double-precision, floating-point
        12:ImgData = UINTARR(ns, nl, file_num)      ;  unsigned integer vector or array
        13:ImgData = ULONARR(ns, nl, file_num)      ;  unsigned longword integer vector or array
        14:ImgData = LON64ARR(ns, nl, file_num)     ;  a 64-bit integer vector or array
        15:ImgData = ULON64ARR(ns, nl, file_num)    ;  an unsigned 64-bit integer vector or array
    ENDCASE
    images_1 = ImgData
    images_2 = ImgData
    images_ndvi = ImgData

    FOR i=0, file_num-1 DO BEGIN
        ;读取数据集1，即第1波段
        ENVI_OPEN_DATA_FILE, filenames[i], r_fid=fid, /hdf_sd, hdfsd_dataset = 0
        ENVI_FILE_QUERY, fid, ns=ns, nl=nl, dims=dims
        b1 = ENVI_GET_DATA(fid=fid, dims=dims, pos=0)

        ;读取数据集2，即第2波段
        ENVI_OPEN_DATA_FILE, filenames[i], r_fid=fid, /hdf_sd, hdfsd_dataset = 1
        ENVI_FILE_QUERY, fid, ns=ns, nl=nl, dims=dims
        b2 = ENVI_GET_DATA(fid=fid, dims=dims, pos=0)

        ;第1波段和第2波段单独保存为ENVI标准格式数据
        strpos = STRPOS(filenames[i], '.', /REVERSE_SEARCH)
        out_name = STRMID(filenames[i], 0, strpos)
        ENVI_WRITE_ENVI_FILE, b1, Out_Name = out_name+'_b1.img', map_info=map_info
        ENVI_WRITE_ENVI_FILE, b2, Out_Name = out_name+'_b2.img', map_info=map_info

        images_1[*,*,i] = b1
        images_2[*,*,i] = b2

        images_ndvi[*,*,i] = (FLOAT(b2)-FLOAT(b1))/(FLOAT(b2)+FLOAT(b1))

        ;清理缓存
        ENVI_FILE_MNG, id=fid, /remove
    ENDFOR

    ;保存合成文件
    ENVI_WRITE_ENVI_FILE, images_1, Out_Name = out_name+'_b1s.img', map_info=map_info, r_fid = fid_1
    ENVI_WRITE_ENVI_FILE, images_2, Out_Name = out_name+'_b2s.img', map_info=map_info, r_fid = fid_2
    ENVI_WRITE_ENVI_FILE, images_2, Out_Name = out_name+'_ndvis.img', map_info=map_info, r_fid = fid_2
    ;定义Albers投影

    params = [6378245, 6356863, 0, 105, 0, 0, 25, 47]
    name = 'Albers_105'
    o_proj = ENVI_PROJ_CREATE(type=9,name=name, params=params)

    ;投影转换,并输出转换后的文件
    pos = LINDGEN(file_num)
    o_ps = [250, 250]  ;分辨率
    grid = [50, 50]    ;控制点数目
    ENVI_CONVERT_FILE_MAP_PROJECTION, fid=fid_1, o_proj=o_proj, dims=dims, pos=pos, out_name=out_name+'b1s_proj.img', background=0, $
        o_pixel_size=o_ps, grid=grid, warp_method=2, /zero_edge, resampling=0
    ENVI_CONVERT_FILE_MAP_PROJECTION, fid=fid_2, o_proj=o_proj, dims=dims, pos=pos, out_name=out_name+'b2s_proj.img', background=0, $
        o_pixel_size=o_ps, grid=grid, warp_method=2, /zero_edge, resampling=0

    ;清空缓存
    ENVI_FILE_MNG, id=fid1, /remove
    ENVI_FILE_MNG, id=fid2, /remove
    PRINT, 'process over'
END