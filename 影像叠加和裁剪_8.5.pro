PRO med_exercise
;***************************************影像叠加*****************************************************
    ;获取影像信息
    filenames = DIALOG_PICKFILE(title='请选择遥感影像', /multiple_files)
    file_num = N_ELEMENTS(filenames)
    ENVI_OPEN_FILE, filenames[0], r_fid=fid
    ENVI_FILE_QUERY, fid, ns=ns, nl=nl, dims=dims, data_type=data_type
    map_info = ENVI_GET_MAP_INFO(fid=fid)

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

    ;影像叠加
    FOR i=0, file_num-1 DO BEGIN
        ENVI_OPEN_FILE, filenames[i], r_fid=fid
        data = ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
        ImgData[*,*,i] = data
    ENDFOR

    ;输出影像
    filename = DIALOG_PICKFILE(title = '影像输出：')
    ENVI_WRITE_ENVI_FILE, ImgData, Out_Name = filename, map_info=map_info
    img_cut, filename
END

PRO img_cut, filename
;***************************************影像裁剪*****************************************************
    
    ;打开需要用到的数据
    e=ENVI()
    filename_roi = DIALOG_PICKFILE(title='请选择矢量文件')
    raster = e.OpenRaster(filename)
    file_shp = e.OpenVector(filename_roi)
     
    ;进行裁剪
    Task_MASK=ENVITASK('VectorMaskRaster')
    Task_MASK.data_ignore_value = 0
    Task_MASK.input_Mask_vector = file_shp
    Task_MASK.input_raster = raster
    
    ;输出影像，运行envi方法
    Task_MASK.output_raster_URI = filename+'_cut'
    Task_MASK.Execute
END








