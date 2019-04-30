;********************************pan波段滤波，测试环境：ENVI-5.1, IDL-8.3******************************************************
PRO exercise2_1

    ;0：平滑滤波，1：中值滤波，2：roberts锐化，3：sobel锐化，4：prewitt锐化，5：laplacian算法
    flag = 0
    window_half_size = 2

    ;提取影像矩阵并滤波
    window_size = window_half_size*2 + 1
    filename = DIALOG_PICKFILE(title='选择图像文件')
    ENVI_OPEN_FILE, filename, r_fid=fid
    ENVI_FILE_QUERY, fid, dims=dims
    map_info = ENVI_GET_MAP_INFO(fid=fid)
    band = FLOAT(ENVI_GET_DATA(fid=fid, dims=dims, pos=0))
    CASE flag OF
        0:img_smooth = SMOOTH(band, window_size, /edge_truncate)
        1:img_smooth = MEDIAN(band, window_size)
        2:img_smooth = ROBERTS(band)
        3:img_smooth = SOBEL(band)
        4:img_smooth = PREWITT(band)
        5:img_smooth = laplacian(band)
    ENDCASE

    ;输出影响
    filename = DIALOG_PICKFILE(title = '影像输出')
    ENVI_WRITE_ENVI_FILE,  img_smooth, Out_Name = filename, map_info= map_info

    ;清空内存
    ENVI_FILE_MNG, id=fid, /remove
    PRINT, 'over'
END