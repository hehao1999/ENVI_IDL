;********************************影像叠加和裁剪，测试环境：ENVI-5.3, IDL8.3, IDL8.5********************************************
PRO med_exercise_IDL8_3
    ;***************************************影像叠加*****************************************************
    ;获取影像信息
    filenames = DIALOG_PICKFILE(title='请选择遥感影像', /multiple_files)
    file_num = N_ELEMENTS(filenames)
    ENVI_OPEN_FILE, filenames[0], r_fid=fid
    ENVI_FILE_QUERY, fid, ns=ns, nl=nl, dims=dims, data_type=data_type
    map_info = ENVI_GET_MAP_INFO(fid=fid)
    ;判断影像类型，构造影像数组
    CASE data_type OF
        1:ImgData = BYTARR(ns, nl, file_num)
        2:ImgData = INTARR(ns, nl, file_num)
        3:ImgData = LONARR(ns, nl, file_num)
        4:ImgData = FLTARR(ns, nl, file_num)
        5:ImgData = DBLARR(ns, nl, file_num)
        6:ImgData = COMPLEXARR(ns, nl ,file_num)
        9:ImgData = DCOMPLEXARR(ns, nl, file_num)
        12:ImgData = UINTARR(ns, nl, file_num)
        13:ImgData = ULONARR(ns, nl, file_num)
        14:ImgData = LON64ARR(ns, nl, file_num)
        15:ImgData = ULON64ARR(ns, nl, file_num)
    ENDCASE

    ;影像叠加
    FOR i=0, file_num-1 DO BEGIN
        ENVI_OPEN_FILE, filenames[i], r_fid=fid
        data = ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
        ImgData[*,*,i] = data
    ENDFOR

    ;输出影像
    filename = DIALOG_PICKFILE(title = '影像输出：')
    ENVI_WRITE_ENVI_FILE, ImgData, Out_Name = filename, map_info=map_info, r_fid=fid

    ;影像裁剪
    img_cut, fid
END

;*****影像裁剪*****
PRO img_cut, fid
    ;***************************************影像裁剪-IDL8.3*****************************************************

    ;打开SHP文件，获取遥感影像和矢量数据信息及变量初始化
    shpfile = DIALOG_PICKFILE(title='请选择矢量文件',filter='*.shp')
    ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims
    oproj = ENVI_GET_PROJECTION(fid=fid)
    iproj = ENVI_PROJ_CREATE(/geographic)
    oshp = OBJ_NEW('IDLffShape',shpfile)
    oshp->GETPROPERTY,n_entities=n_ent, n_attributes=n_attr, Entity_type=ent_type
    roi_ids = LONARR(n_ent)
    
    ;读取和处理shp文件
    FOR i=0, n_ent-1 DO BEGIN
        
        ;shp数据的读取、坐标转换及ROI的生成
        entity = oshp->GETENTITY(i)
        IF PTR_VALID(entity.parts) NE 0 THEN BEGIN
            temp_Lon = REFORM((*entity.vertices)[0,*])
            temp_Lat = REFORM((*entity.vertices)[1,*])
            ENVI_CONVERT_FILE_COORDINATES, fid, xf, yf, temp_Lon, temp_Lat
            roi_ids[i] = ENVI_CREATE_ROI(ns=ns, nl=nl)
            ENVI_DEFINE_ROI, roi_ids[i], xpts=xf, ypts=yf, /polygon
        ENDIF
        
        ;记录X,Y阈值
        IF i EQ 0 THEN BEGIN
            xmin = ROUND(MIN(xf, max=xmax))
            ymin = ROUND(MIN(yf, max=ymax))
        ENDIF ELSE BEGIN
            xmin = xmin < ROUND(MIN(xf))
            xmax = xmax > ROUND(MAX(xf))
            ymin = ymin < ROUND(MIN(yf))
            ymax = ymax > ROUND(MAX(yf))
        ENDELSE

        ;销毁oshp对象
        oshp->DESTROYENTITY,entity
    ENDFOR
    
    ;获取掩模文件大小
    OBJ_DESTROY, oshp
    xmin = xmin>0
    xmax = xmax<ns
    ymin = ymin>0
    ymax = ymax<nl
    dims = [-1, xmin, xmax, ymin, ymax]

    ;掩模影像，生成裁剪影像
    pos = INDGEN(nb)
    out_name = DIALOG_PICKFILE(title='输出影像')
    ENVI_DOIT, 'envi_subset_via_roi_doit', fid=fid, dims=dims, ns=ns, nl=nl, pos=pos, $
        background=0, roi_ids=roi_ids, proj=oproj, out_name=out_name

    ;内存清理，关闭文件
    ENVI_FILE_MNG, id=fid, /remove
    ENVI_DELETE_ROIS, /all
    
    ;*********************************以下方法只能在IDL8.5及以上版本运行**********************************************
    
    ;***************************************影像裁剪-IDL8.5*****************************************************
    ;    ;打开需要用到的数据
    ;    e=ENVI()
    ;    filename_roi = DIALOG_PICKFILE(title='请选择矢量文件')
    ;    raster = e.OpenRaster(filename)
    ;    file_shp = e.OpenVector(filename_roi)
    ;
    ;    ;进行裁剪
    ;    Task_MASK=ENVITASK('VectorMaskRaster')
    ;    Task_MASK.data_ignore_value = 0
    ;    Task_MASK.input_Mask_vector = file_shp
    ;    Task_MASK.input_raster = raster
    ;
    ;    ;输出影像，运行envi方法
    ;    Task_MASK.output_raster_URI = filename+'_cut'
    ;    Task_MASK.Execute
END