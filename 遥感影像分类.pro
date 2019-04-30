;影像最大似然比分类
PRO exercise1_3
    ;读入需要分类的遥感影像
    filename = DIALOG_PICKFILE(title = '请选择分类影像:')
    ENVI_OPEN_FILE, filename, r_fid=fid
    ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims
    pos=INDGEN(nb)

    ;读入ROI文件
    filename_roi = DIALOG_PICKFILE(title = 'ROI文件:')
    ENVI_RESTORE_ROIS, filename_roi
    roi_ids = ENVI_GET_ROI_IDS(fid=fid, roi_colors=roi_colors, roi_names=class_names)

    ;设置分类参数
    classnames = ['class1', 'class2', 'class3']
    num_classes = N_ELEMENTS(roi_ids)
    lookup = BYTARR(3, num_classes+1)
    lookup[*, 1:num_classes] = roi_colors

    ;获取每个类别的ROI统计信息
    means = FLTARR(nb, num_classes)
    stdv = FLTARR(nb, num_classes)
    cov = FLTARR(nb, nb, num_classes)
    FOR j=0, num_classes-1 do BEGIN
        roi_dims = [ENVI_GET_ROI_DIMS_PTR(roi_ids[j]), 0, 0, 0, 0]
        ENVI_DOIT, 'envi_stats_doit', fid=fid, dims=roi_dims, pos=pos, $
            comp_flag=4, mean=c_mean, stdv=c_stdv, cov=c_cov
        means[*, j] = c_mean
        stdv[*, j] = c_stdv
        cov[*, *, j] = c_cov
    ENDFOR

    ;进行分类
    outname = DIALOG_PICKFILE(title = '输出影像:')
    ENVI_DOIT, 'class_doit', fid=fid, dims=dims, pos=pos, r_fid=r_fid, out_name=outname, $
        method=2, mean=means, stdv=stdv,cov=cov,num_classes=num_classes, lookup=lookup, class_names=classnames
     
    ;清空缓存区
    ENVI_FILE_MNG, id=fid, /remove
    ENVI_FILE_MNG, id=r_fid, /remove
    PRINT, 'Process over'
END