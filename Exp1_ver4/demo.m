clear all;
close all;

try
Screen('Preference', 'SkipSyncTests', 1);
%====== Input ======%
    subjNo                = input('subjNo: ','s');
    DemoEye               = input('DomEye Right 1 Left 2:');
    keymode               = input('keymode1 MAC keymode2 Dell 3 EEG:');
    fName = ['./Data/Ensem_result_' subjNo '.txt'];

%====== initial condition =====% 
    
    faceOpc(1,1) = 0.7;  faceOpc(2,1) = 0.4;
    faceOpc(1,2) = 0.7;  faceOpc(2,2) = 0.4;
    faceOpc(1,3) = 0.7;  faceOpc(2,3) = 0.4;
    faceOpc(1,4) = 0.7;  faceOpc(2,4) = 0.4;

    maskOpc = 1;
    disX = 240;
    waitTime = 60;

    lowerBound = 0.02;
    upperBound = 1.00;     
    stepsize_down = 0.04; 
    stepsize_up = 0.02;    
    stairCase_up = 2;

%====== Setup Screen & Keyboard ======%
    screid = max(Screen('Screens'));
    [wPtr, screenRect]=Screen('OpenWindow',screid, 0,[],32,2); % open screen
    [width, height] = Screen('WindowSize', wPtr); %get windows size 

    if keymode==1,
        targetUsageName = 'Keyboard';
        targetProduct = 'Apple Keyboard';
        dev=PsychHID('Devices');
        devInd = find(strcmpi(targetUsageName, {dev.usageName}) & strcmpi(targetProduct, {dev.product}));
    elseif keymode==2, 
        targetUsageName = 'Keyboard';
        targetProduct = 'USB Keykoard';
        dev=PsychHID('Devices');
        devInd = find(strcmpi(targetUsageName, {dev.usageName}) & strcmpi(targetProduct, {dev.product}));
    elseif keymode==3,
        targetUsageName = 'Keyboard';
        targetProduct = 'Dell USB Keyboard';
        dev=PsychHID('Devices');
        devInd = find(strcmpi(targetUsageName, {dev.usageName}) & strcmpi(targetProduct, {dev.product}));
    end
    KbQueueCreate(devInd);  
    KbQueueStart(devInd);

%======Keyboard======%

        KbName('UnifyKeyNames');
        quitkey = 'ESCAPE';
        space   = 'space';
        breakKey = 'DownArrow';

        leftkey = 'LeftArrow';
        rightkey = 'RightArrow';
        
        placeKey{1} = 'a';
        placeKey{2} = 's';
        placeKey{3} = 'z';
        placeKey{4} = 'x';
        
        notSure = 'UpArrow';
    
%====== Position ======%

    % general setup
        cenX = width/2;
        cenY = height/2-150;
        L_cenX = cenX - disX;
        R_cenX = cenX + disX;
        BoxcenY = cenY;
        faceW = 112; %face width 7:9
        faceH = 126; %face height

        boxcolor=[255 255 255];
        boxsize = 160;
        m = 3; %margin

    % for stimuli face
        if DemoEye == 1 %Left eye
            facePosi = [
                [L_cenX-faceW BoxcenY-faceH L_cenX-m BoxcenY-m];   %  face1 face2 
                [L_cenX+m BoxcenY-faceH L_cenX+faceW BoxcenY-m];   %     center
                [L_cenX-faceW BoxcenY+m   L_cenX-m BoxcenY+faceH]; %  face3 face4
                [L_cenX+m BoxcenY+m   L_cenX+faceW BoxcenY+faceH];
            ];
            %monPosi = [R_cenX-faceW BoxcenY-faceH R_cenX+faceW BoxcenY+faceH];
            monPosi = [
                [R_cenX-faceW BoxcenY-faceH R_cenX-m BoxcenY-m];
                [R_cenX+m BoxcenY-faceH R_cenX+faceW BoxcenY-m];
                [R_cenX-faceW BoxcenY+m   R_cenX-m BoxcenY+faceH]; 
                [R_cenX+m BoxcenY+m   R_cenX+faceW BoxcenY+faceH];
            ];
        end        

        if DemoEye == 2 % Right eye
            facePosi = [
                [R_cenX-faceW BoxcenY-faceH R_cenX-m BoxcenY-m];
                [R_cenX+m BoxcenY-faceH R_cenX+faceW BoxcenY-m];
                [R_cenX-faceW BoxcenY+m   R_cenX-m BoxcenY+faceH];
                [R_cenX+m BoxcenY+m   R_cenX+faceW BoxcenY+faceH];
            ];
            %monPosi = [L_cenX-faceW BoxcenY-faceH L_cenX+faceW BoxcenY+faceH];
            monPosi = [
                [L_cenX-faceW BoxcenY-faceH L_cenX-m BoxcenY-m];   %  face1 face2 
                [L_cenX+m BoxcenY-faceH L_cenX+faceW BoxcenY-m];   %     center
                [L_cenX-faceW BoxcenY+m   L_cenX-m BoxcenY+faceH]; %  face3 face4
                [L_cenX+m BoxcenY+m   L_cenX+faceW BoxcenY+faceH];
            ];
        end     

    % for test faces
        targetPosi_L = [L_cenX-faceW BoxcenY-faceH L_cenX+faceW BoxcenY+faceH];
        targetPosi_R = [R_cenX-faceW BoxcenY-faceH R_cenX+faceW BoxcenY+faceH];

    % for reporting seen faces
        reportboxsize = 13;        
        reportdis = 60;
        L_reportbox = [ [L_cenX-reportdis-15 BoxcenY-reportdis-10];
                      [L_cenX+reportdis-15 BoxcenY-reportdis-10];
                      [L_cenX-reportdis-15 BoxcenY+reportdis-10];
                      [L_cenX+reportdis-15 BoxcenY+reportdis-10];
                    ];
        R_reportbox = [ [R_cenX-reportdis-15 BoxcenY-reportdis-10];
                      [R_cenX+reportdis-15 BoxcenY-reportdis-10];
                      [R_cenX-reportdis-15 BoxcenY+reportdis-10];
                      [R_cenX+reportdis-15 BoxcenY+reportdis-10];
                    ];
    
%====== Experimental Condition ======%

    targetFaceNum = 6;
    catchFaceNum = 10;
    conditionNum = 5;
    rep = 6;
    catch_rep = 5;
    expTrialNum = targetFaceNum*conditionNum*rep;
    catchTrialNum = catchFaceNum*catch_rep;
    
    trials = expTrialNum + catchTrialNum;
    
    EXP_CATCH   =1;
    ENSEM       =2;
    TARGET      =3;
    RESPONSE    =4;
    DONE        =5;
    STAIR       =6;
    OPC(1)      =7;
    OPC(2)      =8;
    OPC(3)      =9;
    OPC(4)      =10;
    SEEN(1)     =11;
    SEEN(2)     =12;
    SEEN(3)     =13;
    SEEN(4)     =14;
    REPEAT      =15;
    PLACE(1)    =16;
    PLACE(2)    =17;
    PLACE(3)    =18;
    PLACE(4)    =19;
    
    
    condList = cell(5);
    for block = 1:5
        temp = zeros(trials/5,19);
        temp(1:expTrialNum/5,EXP_CATCH) = 1;
        temp(1:trials/5,ENSEM) = block;
        temp(1:expTrialNum/5,TARGET) = repmat(1:6,1,expTrialNum/(5*6));
        temp(1:expTrialNum/5,STAIR) = repmat(1:2,1,expTrialNum/(5*2));
        
        temp(expTrialNum/5+1:trials/5,EXP_CATCH) = 0;
        temp(expTrialNum/5+1:trials/5,TARGET) =  repmat(1:catchFaceNum,1,1);
        temp(expTrialNum/5+1:trials/5,STAIR) = 1;
       
        temp_random = randperm(trials/5);
        
        for i = 1:trials/5
            condList{block}(end+1,:) = temp(temp_random(i),:);
        end
    end
    
    resultList = zeros(0,19);
    
%====== Time & Freq ======%
    monitorFlipInterval =Screen('GetFlipInterval', wPtr);
    refreshRate = round(1/monitorFlipInterval); % Monitor refreshrate
    MondFreq = 10; %Hz
    MondN  = round(refreshRate/MondFreq); % frames/img
    ConIncr= 7.5 /(10*refreshRate); % 7.5% increase per second

%====== Load image ======%

    % target faces and mask
    folder = './faces/target/';
    load mandrill
        targetFace.file = dir([folder 'target*.jpg']);
        for i= 1:length(targetFace.file)
           targetFace.img{i} = imread([folder targetFace.file(i).name]);
           targetFace.tex{i} = Screen('MakeTexture',wPtr,targetFace.img{i});
           
           im =  double(targetFace.img{i})/255;
           targetMask.img{i} = imscramble(im,0.75,'range');
           im = uint8(targetMask.img{i}*255);
           targetMask.tex{i} = Screen('MakeTexture',wPtr,im);
        end
    
    % catch faces and mask
    folder = './faces/catch/';
    load mandrill
        catchFace.file = dir([folder 'catch*.jpg']);
        for i= 1:length(catchFace.file)
           catchFace.img{i} = imread([folder catchFace.file(i).name]);
           catchFace.tex{i} = Screen('MakeTexture',wPtr,catchFace.img{i});
           
           im =  double(catchFace.img{i})/255;
           catchMask.img{i} = imscramble(im,0.75,'range');
           im = uint8(catchMask.img{i}*255);
           catchMask.tex{i} = Screen('MakeTexture',wPtr,im);
        end   
     
    % ensumble faces
    folder = './faces/ensem/';
        for i = 1:5
            ensemFace.file = dir([folder 'con' num2str(i) '_*.jpg']);
            for j = 1:4
            ensemFace.img{i,j} = imread([folder ensemFace.file(j).name]);
            ensemFace.tex{i,j} = Screen('MakeTexture',wPtr,ensemFace.img{i,j});
            end
        end
        
    % mondrians
    mon.file = dir('./Mon/*.JPG');
    for i= 1:10
       mon.img{i} = imread(['./Mon/' mon.file(i).name]);
       mon.tex{i} = Screen('MakeTexture',wPtr,mon.img{i});        
    end
    
%====== Experiment running ======%
    
    breakRate = [];
    numReportUnseen{1} = [0 0 0 0];
    numReportUnseen{2} = [0 0 0 0];
    
    block_rand = randperm(5);
    block_done = 0;
    for block = block_rand
        
        timeLimit = GetSecs+waitTime;
        
        %---- taking break between blocks ---%
        resting = 1;
        while resting && block_done ~= 0
            remain = ceil(timeLimit-GetSecs);
            FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
            if block_done == 1, Writetext(wPtr,'20% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
            if block_done == 2, Writetext(wPtr,'40% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
            if block_done == 3, Writetext(wPtr,'60% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
            if block_done == 4, Writetext(wPtr,'80% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
            Writetext(wPtr,'take a rest',L_cenX, R_cenX,BoxcenY, 70,15, [255 255 255],20);
            
            if remain > 0
                Writetext(wPtr,[num2str(remain) 's'],L_cenX, R_cenX,BoxcenY, 30,-25, [255 255 255],20);
            else
                Writetext(wPtr,'press down to start',L_cenX, R_cenX,BoxcenY, 70,-25, [255 255 255],15);  
                KbEventFlush();
                [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                if secs(KbName(breakKey)) resting = 0; end 
            end
            
            Screen('Flip',wPtr);
        end
        
        %======== start of the block =======% 
        
        while(sum(condList{block}(:,DONE)) ~= trials/5)
            for i = 1:trials/5
                
                if condList{block}(i,DONE) continue; end
                
                % --------press space to start----------%
                while 1
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    Writetext(wPtr,'press space to start ',L_cenX, R_cenX,BoxcenY, 100,60, [255 255 255],15);
                    Screen('Flip',wPtr);
                    KbEventFlush();
                    [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                    if secs(KbName(space)) break; end 
                end
                
                %delay
                FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                Screen('Flip',wPtr);
                WaitSecs(1);
                
                
                % --------Show faces and Mon ------------%
                
                     answer = 0;
                     noBreak = 1;
                     seen = [0 0 0 0];

                     % inititialize group face & Mon
                     randPlace = randperm(4);
                     ensemIdx = condList{block}(i,ENSEM);
                     targetIdx = condList{block}(i,TARGET);
                     stair = condList{block}(i,STAIR);
                     isExp = condList{block}(i,EXP_CATCH);

                     MonIdx=1;
                     MonTimer = 0;
                     contrast = [0 0 0 0];%initial contrast
                     timezero = GetSecs;

                     %show supressed faces for 1 sec
                     while GetSecs - timezero < 1 && noBreak
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

                        %adjust contract and draw faces
                        if isExp
                            for p = 1:4
                                if contrast(p)< faceOpc(stair,p), contrast(p) = contrast(p)+ConIncr;end
                                if contrast(p)>= faceOpc(stair,p), contrast(p) = faceOpc(stair,p); end
                                Screen('DrawTexture', wPtr, ensemFace.tex{ensemIdx,p}, [], facePosi(randPlace(p),:),[],[],contrast(randPlace(p)));
                            end
                        end

                        %draw and adjust mondrians
                        for p = 1:4
                            Screen('DrawTexture', wPtr, mon.tex{MonIdx}, [], monPosi(p,:),[],[],maskOpc); end
                        if MonTimer == 0
                            MonIdx = MonIdx+1 ;
                            if MonIdx == 11, MonIdx = 1; end         
                        end
                        MonTimer = MonTimer +1;
                        MonTimer = mod(MonTimer,MondN);

                        % make visible on Screen
                        Screen('Flip',wPtr);

                        % catch response
                        KbEventFlush();
                        [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                        if secs(KbName(breakKey))-timezero > 0, noBreak = 0; end
                        if secs(KbName(quitkey))
                            
                            CreateFile(fName, resultList);
                            Screen('CloseAll'); %Closes Screen  
                            return;
                        end
                     end
                 
            
                    % delay 500ms
                    while GetSecs-timezero < 1.5 && noBreak
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('Flip',wPtr);
                        KbEventFlush();

                        % catch response
                        [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                        if secs(KbName(breakKey))-timezero > 0, noBreak = 0; end
                    end
                
                % --------- show target face and mask---------%
                    timezero = GetSecs;
                    while GetSecs-timezero < 0.1 && noBreak && isExp
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('DrawTexture',wPtr, targetFace.tex{targetIdx}, [], targetPosi_L);
                        Screen('DrawTexture',wPtr, targetFace.tex{targetIdx}, [], targetPosi_R);
                        Screen('Flip',wPtr);
                    end
                    
                    while GetSecs-timezero < 0.2 && noBreak &&  ~isExp
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('DrawTexture',wPtr, catchFace.tex{targetIdx}, [], targetPosi_L);
                        Screen('DrawTexture',wPtr, catchFace.tex{targetIdx}, [], targetPosi_R);
                        Screen('Flip',wPtr);
                    end
                       
                    timezero = GetSecs;
                    while GetSecs-timezero < 0.1 && noBreak && isExp
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('DrawTexture',wPtr, targetMask.tex{targetIdx}, [], targetPosi_L);
                        Screen('DrawTexture',wPtr, targetMask.tex{targetIdx}, [], targetPosi_R);
                        Screen('Flip',wPtr);
                    end

                    while GetSecs-timezero < 0.1 && noBreak && ~isExp
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('DrawTexture',wPtr, catchMask.tex{targetIdx}, [], targetPosi_L);
                        Screen('DrawTexture',wPtr, catchMask.tex{targetIdx}, [], targetPosi_R);
                        Screen('Flip',wPtr);
                    end
                    
                    % delay
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    Screen('Flip',wPtr);
                    WaitSecs(.5);
                    
                % -------------make emotion judgement-------------%
                    forget = 0;
                    waitForAnswer = 1;
                    timezero = GetSecs;
                    while waitForAnswer && noBreak
                        % show emotion judgement screen
                            FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                            Writetext(wPtr,'Emotion',L_cenX, R_cenX,BoxcenY, 30,60, [255 255 255],15);
                            Writetext(wPtr,'very',L_cenX, R_cenX,BoxcenY, 115,10, [255 255 255],15);
                            Writetext(wPtr,'negative',L_cenX, R_cenX,BoxcenY, 120,-10, [255 255 255],15);
                            Writetext(wPtr,'very',L_cenX, R_cenX,BoxcenY, -75,10, [255 255 255],15);
                            Writetext(wPtr,'positive',L_cenX, R_cenX,BoxcenY, -70,-10, [255 255 255],15);
                            Writetext(wPtr, num2str(answer), L_cenX, R_cenX, BoxcenY, 5-answer*(boxsize-20)/10,-60, [255 255 255],15);
                            SelectionBar(wPtr,L_cenX,R_cenX,BoxcenY, boxsize, answer);
                            Screen('Flip',wPtr);

                        % get keyboard response
                            KbEventFlush();
                            [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);

                            if  keyIsDown
                                % left right
                                if secs(KbName(leftkey))-timezero > 0
                                    if answer > -10, answer = answer-1; end
                                end
                                if secs(KbName(rightkey))-timezero > 0
                                    if answer < 10, answer = answer+1; end
                                end

                                % not sure
                                if secs(KbName(notSure))-timezero>0, forget = ~forget;end
                                    
                                % space pressed
                                if secs(KbName(space))-timezero>0, waitForAnswer = 0;end

                                % break key pressed
                                if secs(KbName(breakKey))-timezero > 0, noBreak = 0; end

                                % ESC pressed
                                if secs(KbName(quitkey))
                                    CreateFile(fName, resultList);
                                    Screen('CloseAll'); %Closes Screen  
                                    return;
                                end

                            end 
                    end
                     
                    
                    
                %-------Break Trials & Report visible locations------%
            
                    waitForAnswer = 1; 
                    while waitForAnswer && ~noBreak
                       % show visibility report screen
                            FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                            Writetext(wPtr,'Location',L_cenX, R_cenX,BoxcenY, 50,100, [255 255 255],14);
                            Writetext(wPtr,'1',L_cenX, R_cenX,BoxcenY, reportdis+5,reportdis+5, [255 255 255],14);
                            Writetext(wPtr,'2',L_cenX, R_cenX,BoxcenY, -reportdis+5,reportdis+5, [255 255 255],14);
                            Writetext(wPtr,'3',L_cenX, R_cenX,BoxcenY, reportdis+5,-reportdis+5, [255 255 255],14);
                            Writetext(wPtr,'4',L_cenX, R_cenX,BoxcenY, -reportdis+5,-reportdis+5, [255 255 255],14);
                            for j = 1:4 
                                if seen(j) SelectionBox(wPtr,L_reportbox(j,1),R_reportbox(j,1), L_reportbox(j,2),reportboxsize,boxcolor); end
                            end
                            Screen('Flip',wPtr);

                        %get keyboard response
                            KbEventFlush();
                            [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);

                            if  keyIsDown
                                % report seen faces
                                for j= 1:4
                                   if secs(KbName(placeKey{j})) seen(j) = ~seen(j); end 
                                end

                                % space pressed
                                if secs(KbName(space)),  waitForAnswer = 0; end

                                % ESC pressed
                                if secs(KbName(quitkey))
                                    CreateFile(fName, resultList);
                                    Screen('CloseAll'); %Closes Screen  
                                    return;
                                end
                            end 
                    end 
                    
                    
                %--------- Save Result ----------%
                    condList{block}(i,RESPONSE) = answer;
                    condList{block}(i,DONE) = noBreak;
                    condList{block}(i,SEEN(:)) = seen(:);
                    condList{block}(i,PLACE(:)) = randPlace(:);
                    if isExp condList{block}(i,OPC(:)) = faceOpc(stair,:); end
                    condList{block}(i,REPEAT)= condList{block}(i,REPEAT)+1;
                    resultList(end+1,:) = condList{block}(i,:);
                    
                    
                %---------- Monitoring ----------%
                    disp('-------------------------------')
                    disp('trial condition: ');
                    disp(condList{block}(i,1:6));
                    disp('threshold: ');
                    disp(condList{block}(i,OPC(:)));
                    disp(condList{block}(i,SEEN(:)));
                    disp('block complete');
                    disp([num2str(block_done) '   ' num2str(sum(condList{block}(:,DONE))) '/' num2str(trials/5)]);
                    disp('break rate')
                    disp(1-mean(resultList(:,DONE)));
                    
                %---------- Adjust Threshold ----------%
                    for j = 1:4
                      % seen, decrease
                      if(seen(j)) && isExp
                         faceOpc(stair,j) = faceOpc(stair,j)-stepsize_down;
                         if faceOpc(stair,j) <= lowerBound, faceOpc(stair,j) = lowerBound; end
                         numReportUnseen{stair}(j) = 0;
                      end

                      % unseen, increase
                      if(~seen(j)) && isExp
                         numReportUnseen{stair}(j) = numReportUnseen{stair}(j) +1;
                         if numReportUnseen{stair}(j) == stairCase_up;
                             faceOpc(stair,j) = faceOpc(stair,j) + stepsize_up;
                             if faceOpc(stair,j) >= upperBound, faceOpc(stair,j) = upperBound; end
                             numReportUnseen{stair}(j) = 0;
                         end
                      end
                    end     
                
            end %end of trials
        end %end of the block
        block_done = block_done+1;
    end
        
    
%===== Write Results and Quit =====%
    
    CreateFile(fName, resultList);
    Screen('CloseAll'); %Closes Screen  
    return;

catch
    Screen('CloseAll'); %Closes Screen  
    condListAll = zeros(0,15);
    for block  =1:5 condListAll(end+1:end+trials/5,:) = condList{block}; end
    CreateFile(fName, condListAll);
    CreateFile(fName_thr, thrList);
    return;
end