;********************************多光谱影像和全色影像的融合，测试环境：ENVI-5.1, IDL-8.3********************************************
PRO exercise2_2
    ;参数设置：融合方法 0：最邻近法，1：双线性插值，2：立方卷积
    method = 0
    
    ;打开多光谱影像
    filename = DIALOG_PICKFILE(title = '请选择多光谱遥感影像:')
    ENVI_OPEN_FILE, filename, r_fid=fid_multi
    ENVI_FILE_QUERY, fid_multi, nb=nb, dims=dims_multi
    pos = INDGEN(nb)

    ;打开全色影像
    filename = DIALOG_PICKFILE(title = '请选择全色遥感影像:')
    ENVI_OPEN_FILE, filename, r_fid=fid_pan
    ENVI_FILE_QUERY, fid_pan,ns=ns_pan,nl=nl_pan, dims=dims_pan

    ;输出影像
    outname = DIALOG_PICKFILE(title = '输出影像:')
    ENVI_DOIT, 'envi_gs_sharpen_doit', fid=fid_multi, dims=dims_multi, pos=pos, $
        hires_fid=fid_pan, hires_dims=dims_pan, hires_pos=0, r_fid=fid_GS, $
        out_name=outname, method=method, interp=1
    
    ;清空内存
    ENVI_FILE_MNG, id=fid_multi, /remove
    ENVI_FILE_MNG, id=fid_pan, /remove
    PRINT, 'Process over'
END