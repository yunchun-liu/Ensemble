function[] = CreateCondListFile(filepath, list)


%====== Content of Result File ======%
%   column name    colunm number  
%     IS_EXP_TRIAL    =1;
%     ENSEM           =2;
%     TARGET          =3;
%     JUDGEMENT       =4;
%     DONE            =5;
%     STAIRCASE       =6;
%     CON(1)          =7;
%     CON(2)          =8;
%     CON(3)          =9;
%     CON(4)          =10;
%     SEEN(1)         =11;
%     SEEN(2)         =12;
%     SEEN(3)         =13;
%     SEEN(4)         =14;
%     REPEAT          =15;
%     PLACE(1)        =16; 
%     PLACE(2)        =17;
%     PLACE(3)        =18;
%     PLACE(4)        =19;
    

    fd = fopen(filepath, 'w');
    [row,col] = size(list);
    for i = 1:row
        fprintf(fd, '%3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d\r\n', list(i,:));
    end
    fclose(fd);

end
