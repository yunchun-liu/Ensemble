
clear all;
close all;

try
    
    
    %====== Input ======%
        subjNo                = input('subjNo: ','s');
        DemoEye               = input('DomEye Right 1 Left 2:');
        keymode               = input('keymode1 MAC keymode2 Dell:');
        fName_1 = ['./Data/Ensem_result_' subjNo '.txt'];
    
    %====== initial condition =====% 
        faceOpc(1) = 0.5;
        faceOpc(2) = 0.5;
        faceOpc(3) = 0.5;
        faceOpc(4) = 0.5;
        maskOpc = 0.10;
        runTrials = 20;
        disX = 220;
        
        lowerBound = 0.02;
        upperBound = 1.0;
        stepsize = 0.1;
        stairCase_up = 2;  
        
    %====== Setup Screen ======%
        screid = max(Screen('Screens'));
        [wPtr, screenRect]=Screen('OpenWindow',screid, 0,[],32,2); % open screen
        [width, height] = Screen('WindowSize', wPtr); %get windows size 
        
    %===== Devices======%
    
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
        
        placeKey{1} = '4';
        placeKey{2} = '5';
        placeKey{3} = '1';
        placeKey{4} = '2';
 
    %====== Position ======%

        % general setup
            cenX = width/2;
            cenY = height/2-150;
            L_cenX = cenX - disX;
            R_cenX = cenX + disX;
            BoxcenY = cenY;
            faceW = 56; %face width 7:9
            faceH = 63; %face height

            boxcolor=[255 255 255];
            boxsize = 80;
            m = 3; %margin
        
        % for stimuli face
            if DemoEye == 1 %Left eye
                postList = [
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
                postList = [
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
            testPosi_L = [L_cenX-faceW BoxcenY-faceH L_cenX+faceW BoxcenY+faceH];
            testPosi_R = [R_cenX-faceW BoxcenY-faceH R_cenX+faceW BoxcenY+faceH];
        
        % for reporting seen faces
            reportboxsize = 13;        
            reportdis = 30;
            L_report = [ [L_cenX-reportdis-15 BoxcenY-reportdis-10];
                          [L_cenX+reportdis-15 BoxcenY-reportdis-10];
                          [L_cenX-reportdis-15 BoxcenY+reportdis-10];
                          [L_cenX+reportdis-15 BoxcenY+reportdis-10];
                        ];
            R_report = [ [R_cenX-reportdis-15 BoxcenY-reportdis-10];
                          [R_cenX+reportdis-15 BoxcenY-reportdis-10];
                          [R_cenX-reportdis-15 BoxcenY+reportdis-10];
                          [R_cenX+reportdis-15 BoxcenY+reportdis-10];
                        ];        
                    
    %====== Experimental Condition ======%
        
        repeat = 3;
        testface = 16;
        facesUsed = 2;
        condNum = 5;
        expTrials = repeat * testface * condNum * facesUsed;
        
        condition = [%fearful  happy
                      [ 4       0 ]    %1
                      [ 3       1 ]    %2
                      [ 2       2 ]    %3
                      [ 1       3 ]    %4
                      [ 0       4 ] ]; %5

        % set up condition lists
            %1 trialnumver 
            %2 condition
            %3 stimuli face
            %4 testface
            %5 result
            %6 isBreakTrials
        
            temp = zeros(expTrials,6); 
            
            % condNum
            for i=1:condNum
                temp((i-1)*expTrials/condNum+1 : i*expTrials/condNum , 2) = repmat(i,1,expTrials/condNum); end
            %testface
            temp(1:expTrials,4) = repmat(1:testface,1, expTrials/testface);

            %stimuli face
            i = 1;
            while i <= expTrials               
                for j = 1:testface
                   temp(i,3) = 1;
                   i = i+1; end
                for j = 1:testface
                   temp(i,3) = 2;
                   i = i+1; end
            end
           
            randInx = randperm(expTrials); % random permutation
            condList = zeros(expTrials,6);
            
            for i= 1:expTrials
                condList(i,1) = i;
                condList(i,2:4) = temp(randInx(i),2:4);
            end 

     %====== Time & Freq ======%
        monitorFlipInterval =Screen('GetFlipInterval', wPtr);
        refreshRate = round(1/monitorFlipInterval); % Monitor refreshrate
        MondFreq = 10; %Hz
        MondN  = round(refreshRate/MondFreq); % frames/img
        ConIncr= 7.5 /(10*refreshRate); % 7.5% increase per second
  
    %====== Load image ======%
    
        % stimuli faces
        folder = './faces/';
        
        for i=1:2
            faceNum = num2str(i);
            happyface.img{i} = imread([folder 'happy' faceNum '.jpg']);
            happyface.tex{i} = Screen('MakeTexture',wPtr,happyface.img{i});
            fearfulface.img{i} = imread([folder 'fearful' faceNum '.jpg']); 
            fearfulface.tex{i} = Screen('MakeTexture',wPtr,fearfulface.img{i});
        end
        
        % test faces
        
            test.file = dir([folder 'test*.jpg']);
            for i= 1:testface
               test.img{i} = imread([folder test.file(i).name]);
               test.tex{i} = Screen('MakeTexture',wPtr,test.img{i});        
            end

        % mondrians
        mon.file = dir('./Mon/*.JPG');
        for i= 1:10
           mon.img{i} = imread(['./Mon/' mon.file(i).name]);
           mon.tex{i} = Screen('MakeTexture',wPtr,mon.img{i});        
        end
        
     %====== Experiment running ======%
        
        breakRate = [];
        numReportUnseen = [0 0 0 0];
        thresholdData = zeros(expTrials,8);
     
        for i= 1:runTrials
            
             % -------hint for progress & taking break-------%
             
             if mod(i,100) == 1 && i~=1
                 while 1
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    if i== 101, Writetext(wPtr,'20% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
                    if i== 201, Writetext(wPtr,'40% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
                    if i== 301, Writetext(wPtr,'60% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
                    if i== 401, Writetext(wPtr,'80% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
                    Writetext(wPtr,'take a break',L_cenX, R_cenX,BoxcenY, 70,15, [255 255 255],20);
                    Writetext(wPtr,'press down to start',L_cenX, R_cenX,BoxcenY, 70,-25, [255 255 255],15);
                    Screen('Flip',wPtr);
                    KbEventFlush();
                    [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                    if secs(KbName(breakKey))
                        break; end 
                 end 
             
             end
            
             % --------press space to start----------%
             
                while 1
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    Writetext(wPtr,'press space to start ',L_cenX, R_cenX,BoxcenY, 70,60, [255 255 255],15);
                    
                    Screen('Flip',wPtr);
                    KbEventFlush();
                    [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                    if secs(KbName(space))
                        break; end 
                end
                
                %delay
                FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                Screen('Flip',wPtr);
                WaitSecs(1);
             
             % ------- Initialize data later to be saved--------%
             answer = 0;
             noBreak = 1;
             Seen = [0 0 0 0];
                
             % --------Show faces and Mon ------------%
               
                 % inititialize group face & Mon
                 place = randperm(4);
                 fearfulNum = condition(condList(i,2),1); % how many fearful faces
                 happyNum = condition(condList(i,2),2); % how many happy faces
                 stimuliIdx = condList(i,3); % which face to use
                 
                 MonIdx=1;
                 MonTimer = 0;
                 contrast = [0 0 0 0];%initial contrast
                 timezero = GetSecs;
                 
                 %show supressed faces for 1 sec
                 while GetSecs - timezero < 1 && noBreak
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    
                    %adjust contrast
                    for j = 1:4
                        if contrast(j)< faceOpc(j), contrast(j) = contrast(j)+ConIncr;end
                        if contrast(j)> faceOpc(j), contrast(j) = faceOpc(j); end
                    end
                    
                    %draw faces
                        j=1;
                        if fearfulNum ~= 0
                             for k=1:fearfulNum
                                Screen('DrawTexture', wPtr, fearfulface.tex{stimuliIdx}, [], postList(place(j),:),[],[],contrast(place(j)));
                                j = j+1;
                             end
                        end

                        if happyNum ~= 0
                             for k=1:happyNum
                                 Screen('DrawTexture', wPtr, happyface.tex{stimuliIdx}, [], postList(place(j),:),[],[],contrast(place(j)));
                                j = j+1;
                             end
                        end

                    %draw Mondrians
                    for j=1:4
                        Screen('DrawTexture', wPtr, mon.tex{MonIdx}, [], monPosi(j,:),[],[],maskOpc);
                    end
                    
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
                            CreateFile(fName_1, condList);
                            ListenChar(0);
                            Screen('CloseAll');
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
            
            
            % --------- show test face for 100ms ---------%
                timezero = GetSecs;
                
                while GetSecs-timezero < 0.1 && noBreak
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    Screen('DrawTexture',wPtr, test.tex{condList(i,4)}, [], testPosi_L);
                    Screen('DrawTexture',wPtr, test.tex{condList(i,4)}, [], testPosi_R);
                    Screen('Flip',wPtr);
                end
            
                % delay
                FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                Screen('Flip',wPtr);
                WaitSecs(.5);        
            
            % -------------make emotion judgement-------------%
            
                waitForAnswer = 1;
                timezero = GetSecs;
                while waitForAnswer && noBreak
                     
                    % show emotion judgement screen
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Writetext(wPtr,'Emotion',L_cenX, R_cenX,BoxcenY, 30,60, [255 255 255],15);
                        Writetext(wPtr,'very',L_cenX, R_cenX,BoxcenY, 65,10, [255 255 255],15);
                        Writetext(wPtr,'negative',L_cenX, R_cenX,BoxcenY, 70,-10, [255 255 255],15);
                        Writetext(wPtr,'very',L_cenX, R_cenX,BoxcenY, -25,10, [255 255 255],15);
                        Writetext(wPtr,'positive',L_cenX, R_cenX,BoxcenY, -20,-10, [255 255 255],15);
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

                            % space pressed
                            if secs(KbName(space))-timezero>0, waitForAnswer = 0;

                            end
                            % break key pressed
                            if secs(KbName(breakKey))-timezero > 0, noBreak = 0; end

                            % ESC pressed
                            if secs(KbName(quitkey))
                                CreateFile(fName_1, condList);
                                CreateFile_thr(fName_2, thresholdData);
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
                        Writetext(wPtr,'Location',L_cenX, R_cenX,BoxcenY, 25,70, [255 255 255],14);
                        Writetext(wPtr,'1',L_cenX, R_cenX,BoxcenY, reportdis+5,reportdis+5, [255 255 255],14);
                        Writetext(wPtr,'2',L_cenX, R_cenX,BoxcenY, -reportdis+5,reportdis+5, [255 255 255],14);
                        Writetext(wPtr,'3',L_cenX, R_cenX,BoxcenY, reportdis+5,-reportdis+5, [255 255 255],14);
                        Writetext(wPtr,'4',L_cenX, R_cenX,BoxcenY, -reportdis+5,-reportdis+5, [255 255 255],14);
                        for j = 1:4 
                            if Seen(j) SelectionBox(wPtr,L_report(j,1),R_report(j,1), L_report(j,2),reportboxsize,boxcolor); end
                        end
                        Screen('Flip',wPtr);
                    
                    %get keyboard response
                        KbEventFlush();
                        [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);

                        if  keyIsDown
                            % report seen faces
                            for j= 1:4
                               if secs(KbName(placeKey{j})) Seen(j) = ~Seen(j); end 
                            end

                            % space pressed
                            if secs(KbName(space)),  waitForAnswer = 0; end

                            % ESC pressed
                            if secs(KbName(quitkey))
                                CreateFile(fName_1, condList);
                                Screen('CloseAll'); %Closes Screen
                                return;
                            end
                        end 
                    end 
            
            
            % Save Result
                condList(i,5) = answer;
                condList(i,6) = ~noBreak;
                breakRate(end+1) = noBreak;
                for j=1:4 thresholdData(i,j) = faceOpc(j); end
                thresholdData(i,5:8) = Seen(1:4);
             
            % Monitoring
                disp('-------------------------------')
                disp('trial condition: ');
                disp(condList(i,1:6));
                disp('threshold: ');
                disp(thresholdData(i,1:4));
                disp('break rate:');
                disp(1-mean(breakRate));
                
            % Adjust Threshold
                for j = 1:4
                  % seen, decrease
                  if(Seen(j))
                     faceOpc(j) = faceOpc(j)-stepsize;
                     if faceOpc(j) <= lowerBound, faceOpc(j) = lowerBound; end
                     numReportUnseen(j) = 0;
                  end
                    
                  % unseen, increase
                  if(~Seen(j))
                     numReportUnseen(j) = numReportUnseen(j) +1;
                     if numReportUnseen(j) == stairCase_up;
                         faceOpc(j) = faceOpc(j) + stepsize;
                         if faceOpc(j) >= upperBound, faceOpc(j) = upperBound; end
                         numReportUnseen(j) = 0;
                     end
                  end
                end

        end %end of experiment

    %===== Write Results and Quit =====%
        CreateFile(fName_1, condList);
        Screen('CloseAll'); %Closes Screen  
        return;

catch
    CreateFile(fName_1, condList);
    Screen('CloseAll'); %Closes Screen
    return;
end




