PRO exercise3_1
    filenames = dialog_pickfile(title='请选择遥感影像', filter='*.hdf', /multiple_files)
    file_num = n_elements(filenames)
    for i=0, file_num do begin
                                                           ` 
    endfor
    
    
    print,filenames[file_num-1]
END