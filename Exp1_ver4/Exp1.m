
% ============================== INTRODUCTION ====================================%
% Parameters to adjust for each subject are put in "Parameter" section.
% The program will store the experimental condition for each subject in 'Data/condList' folder
% You can restart any block if there is something wrong, but the program wont let you start a block if any previous block is not done.
% ex: you cant start block 4 if only block 1,2 is done
% The program will generate 5 small result file for each block, and combine them into one file automatically upon all blocks are done.
% ================================================================================%

clear all;
close all;
addpath('./Function/');

Screen('Preference', 'SkipSyncTests', 1);

try
    
%====== Parameters =====% 

    roughThr    = [0.5 0.5 0.5 0.5];
    maskOpc     = 1;
    boxDistance = 210;

    faceCon = zeros(2,4);
    for posi = 1:4
        faceCon(1,posi) = roughThr(posi)+0.2;
        faceCon(2,posi) = roughThr(posi)-0.2;
    end
    
%====== Input ======%
    subjID          = input('subjID: ','s');
    dominantEye     = input('DonimantEye (1/Right 2/Left):');
    keyboard        = input('keyboard (1/MAC 2/Dell 3/EEG):');
    startingBlock   = input('starting from block:');
    
%====== Constants ======%
    
    RIGHT   = 1;
    LEFT    = 2;
    TRUE    = 1;
    FALSE   = 0;

%====== Content of Result File ======%

%   column name    colunm number  
    IS_EXP_TRIAL    =1;
    ENSEM           =2;
    TARGET          =3;
    JUDGEMENT       =4;
    DONE            =5;
    STAIRCASE       =6;
    CON             =7:10;
    SEEN            =11:14;
    REPEAT          =15;
    PLACE           =16:19; 
    
    resultFileColNum = 19;
 
%====== Experimental Condition ======%
    
    %--- Thresholding Procedure ---%
    lowerBound      = 0.02;
    upperBound      = 1.00;     
    stepsize_down	= 0.04; 
    stepsize_up     = 0.02;    
    stairCase_up	= 2; %2up1down
    stairCaseNum    = 2;
    
    waitTime        = 60;
    
    %--- Experiment Condition ---%
    targetFaceNum       = 6;
    blankFaceNum        = 10;
    ensemConditionNum   = 5;
    exp_rep             = 6;
    blank_rep           = 5;
    expTrialNumInBlock      = targetFaceNum*exp_rep;
    blankTrialNumInBlock    = blankFaceNum*blank_rep/ensemConditionNum;
    trialPerBlock         = expTrialNumInBlock + blankTrialNumInBlock;
    
    blockIndex = cell(5);
    for block = 1:5
        blockIndex{block} = trialPerBlock*(block-1)+1 : trialPerBlock*block;
    end
    
    %--- Read or Generate Condition List ---%
    
    condList = zeros(trialPerBlock*5,resultFileColNum);
    
    try
        condFilePath = ['./Data/condList/Ensem_condList_' subjID '.txt']; 
        formatSpec = '%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d';
        [isExp,ensem,target,judgement ,noBreak ,stairCase ,t1 ,t2 ,t3 ,t4 ,s1 ,s2 ,s3 ,s4 ,rep ,p1 ,p2 ,p3 ,p4]= textread(condFilePath,formatSpec);
        fileLength = length(isExp);
        for i = 1:fileLength
            condList(i,IS_EXP_TRIAL) = isExp(i);
            condList(i,ENSEM) = ensem(i);
            condList(i,TARGET) = target(i);
            condList(i,STAIRCASE) = stairCase(i);
        end
        disp('ConditionList for this subject exist. Read from file successful');
        
    catch exception
        disp(getReport(exception));
        temp_condList = cell(5);
        for block = 1:ensemConditionNum
            expTrialIndex   = 1:expTrialNumInBlock;
            blankTrialIndex = expTrialNumInBlock+1:trialPerBlock;

            temp = zeros(trialPerBlock,resultFileColNum);
            temp(1:trialPerBlock,ENSEM)         = block;
            temp(expTrialIndex    ,IS_EXP_TRIAL)  = 1;
            temp(expTrialIndex    ,TARGET)        = repmat(1:targetFaceNum,1,expTrialNumInBlock/targetFaceNum);
            temp(expTrialIndex    ,STAIRCASE)     = repmat(1:stairCaseNum,1,expTrialNumInBlock/stairCaseNum);

            temp(blankTrialIndex  ,IS_EXP_TRIAL) = 0;
            temp(blankTrialIndex  ,TARGET)       = repmat(1:blankFaceNum,1,blank_rep/ensemConditionNum);
            temp(blankTrialIndex  ,STAIRCASE)    = 0;

            randomIndex = randperm(trialPerBlock);
            for i = randomIndex
                temp_condList{block}(end+1,:) = temp(i,:);
            end
        end

        randomIndex = randperm(5);
        for i = 1:5
            condList(blockIndex{i},:) = temp_condList{randomIndex(i)}(:,:);
        end
        
        CreateCondListFile(condFilePath, condList)
        disp('condition for this subject does not exist. Generate a new one and save file');
    end
    
    %--- Check Experiment Progress ---%
        doneBlockNum = GetDoneBlockNumFromResultFile(subjID);
        while startingBlock > doneBlockNum +1
            disp(['Previous block is not done yet. Number of done blocks:' num2str(doneBlockNum) ]);
            startingBlock   = input('starting from block:');
        end
    
%====== Setup Screen & Keyboard ======%

    screid = max(Screen('Screens'));
    [wPtr, screenRect]=Screen('OpenWindow',screid, 0,[],32,2);
    [width, height] = Screen('WindowSize', wPtr);
    
    if keyboard==1, targetProduct = 'Apple Keyboard'; end
    if keyboard==2, targetProduct = 'USB Keykoard'; end
    if keyboard==3, targetProduct = 'Dell USB Keyboard'; end
    
    targetUsageName = 'Keyboard';
    dev=PsychHID('Devices');
    devInd = find(strcmpi(targetUsageName, {dev.usageName}) & strcmpi(targetProduct, {dev.product}));
    KbQueueCreate(devInd);  
    KbQueueStart(devInd);

%======Keyboard Setup======%

    KbName('UnifyKeyNames');
    quitkey     = 'ESCAPE';
    space       = 'space';
    breakKey    = 'DownArrow';
    leftkey     = 'LeftArrow';
    rightkey	= 'RightArrow';

    placeKey(1) = '4';
    placeKey(2) = '5';
    placeKey(3) = '1';
    placeKey(4) = '2';
    
%====== Position ======%

    % general setup
    cenX = width/2;
    cenY = height/2-150;
    L_cenX = cenX - boxDistance;
    R_cenX = cenX + boxDistance;
    BoxcenY = cenY;

    ensumFaceWidth = 56;
    ensumFaceHeight = 63;
    boxcolor=[255 255 255];
    boxsize = 80;
    margin = 3;
   
    if dominantEye == RIGHT
        ensemFacePosi = [
            [L_cenX-ensumFaceWidth	BoxcenY-ensumFaceHeight	L_cenX-margin           BoxcenY-margin];
            [L_cenX+margin          BoxcenY-ensumFaceHeight	L_cenX+ensumFaceWidth   BoxcenY-margin];
            [L_cenX-ensumFaceWidth	BoxcenY+margin          L_cenX-margin           BoxcenY+ensumFaceHeight];
            [L_cenX+margin          BoxcenY+margin          L_cenX+ensumFaceWidth	BoxcenY+ensumFaceHeight];
        ];

        monPosi = [
            [R_cenX-ensumFaceWidth  BoxcenY-ensumFaceHeight R_cenX-margin           BoxcenY-margin];
            [R_cenX+margin          BoxcenY-ensumFaceHeight R_cenX+ensumFaceWidth	BoxcenY-margin];
            [R_cenX-ensumFaceWidth  BoxcenY+margin          R_cenX-margin           BoxcenY+ensumFaceHeight]; 
            [R_cenX+margin          BoxcenY+margin          R_cenX+ensumFaceWidth	BoxcenY+ensumFaceHeight];
        ];
    end        

    if dominantEye == LEFT
        ensemFacePosi = [
            [R_cenX-ensumFaceWidth  BoxcenY-ensumFaceHeight	R_cenX-margin           BoxcenY-margin];
            [R_cenX+margin          BoxcenY-ensumFaceHeight	R_cenX+ensumFaceWidth	BoxcenY-margin];
            [R_cenX-ensumFaceWidth	BoxcenY+margin          R_cenX-margin           BoxcenY+ensumFaceHeight];
            [R_cenX+margin          BoxcenY+margin          R_cenX+ensumFaceWidth	BoxcenY+ensumFaceHeight];
        ];
        monPosi = [
            [L_cenX-ensumFaceWidth	BoxcenY-ensumFaceHeight	L_cenX-margin           BoxcenY-margin];
            [L_cenX+margin          BoxcenY-ensumFaceHeight	L_cenX+ensumFaceWidth	BoxcenY-margin];
            [L_cenX-ensumFaceWidth	BoxcenY+margin          L_cenX-margin           BoxcenY+ensumFaceHeight];
            [L_cenX+margin          BoxcenY+margin          L_cenX+ensumFaceWidth	BoxcenY+ensumFaceHeight];
        ];
    end     

    targetFacePosi_L = [L_cenX-ensumFaceWidth BoxcenY-ensumFaceHeight L_cenX+ensumFaceWidth BoxcenY+ensumFaceHeight];
    targetFacePosi_R = [R_cenX-ensumFaceWidth BoxcenY-ensumFaceHeight R_cenX+ensumFaceWidth BoxcenY+ensumFaceHeight];

    % the selection box for reporting seen faces
    reportBoxSize = 13;        
    reportdis = 30;
    L_reportBoxPosi = [ [L_cenX-reportdis-15 BoxcenY-reportdis-10];
                        [L_cenX+reportdis-15 BoxcenY-reportdis-10];
                        [L_cenX-reportdis-15 BoxcenY+reportdis-10];
                        [L_cenX+reportdis-15 BoxcenY+reportdis-10];
                      ];
    R_reportBoxPosi = [ [R_cenX-reportdis-15 BoxcenY-reportdis-10];
                        [R_cenX+reportdis-15 BoxcenY-reportdis-10];
                        [R_cenX-reportdis-15 BoxcenY+reportdis-10];
                        [R_cenX+reportdis-15 BoxcenY+reportdis-10];
                      ];

%====== Time & Freq ======%

    monitorFlipInterval =Screen('GetFlipInterval', wPtr);
    refreshRate = round(1/monitorFlipInterval); % Monitor refreshrate
    MondFreq = 10; %Hz
    MondN  = round(refreshRate/MondFreq); % frames/img
    ConIncr= 7.5 /(10*refreshRate); % 7.5% increase per second

%====== Load image ======%

    % ------Target Faces(exp trials)-----%
    folder = './Face/target/';
    
        targetFace.file = dir([folder 'target*.jpg']);
        for i= 1:length(targetFace.file)
           targetFace.img{i} = imread([folder targetFace.file(i).name]);
           targetFace.tex{i} = Screen('MakeTexture',wPtr,targetFace.img{i});
           
           %create scramble mask
           image_double =  double(targetFace.img{i})/255;
           targetMask.img{i} = imscramble(image_double,0.75,'range');
           image = uint8(targetMask.img{i}*255);
           targetMask.tex{i} = Screen('MakeTexture',wPtr,image);
        end
    
    % ------ Target Faces(blank trials) ------%
    folder = './Face/blank/';
        blankFace.file = dir([folder 'blank*.jpg']);
        for i= 1:length(blankFace.file)
           blankFace.img{i} = imread([folder blankFace.file(i).name]);
           blankFace.tex{i} = Screen('MakeTexture',wPtr,blankFace.img{i});
           
           %create scramble mask
           image_double =  double(blankFace.img{i})/255;
           blankMask.img{i} = imscramble(image_double,0.75,'range');
           image = uint8(blankMask.img{i}*255);
           blankMask.tex{i} = Screen('MakeTexture',wPtr,image);
        end   
     
    % -------- Ensemble Faces ---------%
    folder = './Face/ensem/';
        for i = 1:5
            ensemFace.file = dir([folder 'con' num2str(i) '_*.jpg']);
            for p = 1:4
            ensemFace.img{i,p} = imread([folder ensemFace.file(p).name]);
            ensemFace.tex{i,p} = Screen('MakeTexture',wPtr,ensemFace.img{i,p});
            end
        end
        
    % --------Mondrians--------%
    mon.file = dir('./Mondrian/*.JPG');
    for i= 1:10
       mon.img{i} = imread(['./Mondrian/' mon.file(i).name]);
       mon.tex{i} = Screen('MakeTexture',wPtr,mon.img{i});        
    end
    
%====== Start of the Experiment ======%

    numReportUnseen{1} = [0 0 0 0];
    numReportUnseen{2} = [0 0 0 0];
    
    for block = startingBlock:5
        disp(['starting block ' num2str(block)]);
        
        %======== start of the block =======% 
        
        resultList = zeros(0,resultFileColNum);
        resultFilePath = ['./Data/Ensem_result_' subjID '_block' num2str(block) '.txt'];
        
        blockUnDone = TRUE;
        break_thisBlock = cell(4);
        breakRate_thisBlock = [0 0 0 0];
        
        while blockUnDone
            for i = blockIndex{block}
                if condList(i,DONE)
                    continue;
                end
                
                %-----Initialize Trial----%

                     ensemCon       = condList(i,ENSEM);
                     targetFaceIdx  = condList(i,TARGET);
                     stair          = condList(i,STAIRCASE);
                     isExp          = condList(i,IS_EXP_TRIAL);
                     
                     answer     = 0;
                     noBreak    = TRUE;
                     seen       = [FALSE FALSE FALSE FALSE];
                     randPosi   = randperm(4);
                
                % --------Press Space To Start----------%
                while TRUE
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    Writetext(wPtr,'press space to start ',L_cenX, R_cenX,BoxcenY, 70,60, [255 255 255],15);
                    Screen('Flip',wPtr);
                    
                    KbEventFlush();
                    [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                    if secs(KbName(space))
                        break;
                    end
                    
                    %ESC pressed
                    if secs(KbName(quitkey))
                        Screen('CloseAll');
                        return;
                    end
                end
                
                %delay
                FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                Screen('Flip',wPtr);
                WaitSecs(1);
                
                % -------- Show Ensembles Faces & CFS -----------%
                
                 MonIdx     = 1;
                 MonTimer   = 0;
                 contrast   = [0 0 0 0];
                 timezero   = GetSecs;

                 %show supressed faces for 1 sec
                 while GetSecs-timezero < 1 && noBreak
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

                    %adjust contract and draw faces
                    if isExp
                        for p = 1:4
                            if contrast(p)< faceCon(stair,p), contrast(p) = contrast(p)+ConIncr;end
                            if contrast(p)>= faceCon(stair,p), contrast(p) = faceCon(stair,p); end
                            Screen('DrawTexture', wPtr, ensemFace.tex{ensemCon,p}, [], ensemFacePosi(randPosi(p),:),[],[],contrast(randPosi(p)));
                        end
                    end

                    %Draw Mondrians
                    for p = 1:4
                        Screen('DrawTexture', wPtr, mon.tex{MonIdx}, [], monPosi(p,:),[],[],maskOpc);
                    end
                    
                    % Adjust Mondrians
                    if MonTimer == 0
                        MonIdx = MonIdx+1 ;
                        if MonIdx == 11, MonIdx = 1; end         
                    end
                    MonTimer = MonTimer +1;
                    MonTimer = mod(MonTimer,MondN);

                    Screen('Flip',wPtr);

                    % catch response
                    KbEventFlush();
                    [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                    if secs(KbName(breakKey))-timezero > 0, noBreak = FALSE; end
                    if secs(KbName(quitkey))
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
                
                % --------- show target face and scramble mask---------%
                
                    timezero = GetSecs;
                    while GetSecs-timezero < 0.1 && noBreak && isExp
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('DrawTexture',wPtr, targetFace.tex{targetFaceIdx}, [], targetFacePosi_L);
                        Screen('DrawTexture',wPtr, targetFace.tex{targetFaceIdx}, [], targetFacePosi_R);
                        Screen('Flip',wPtr);
                    end
                    
                    while GetSecs-timezero < 0.2 && noBreak &&  ~isExp
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('DrawTexture',wPtr, blankFace.tex{targetFaceIdx}, [], targetFacePosi_L);
                        Screen('DrawTexture',wPtr, blankFace.tex{targetFaceIdx}, [], targetFacePosi_R);
                        Screen('Flip',wPtr);
                    end
                       
                    timezero = GetSecs;
                    while GetSecs-timezero < 0.1 && noBreak && isExp
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('DrawTexture',wPtr, targetMask.tex{targetFaceIdx}, [], targetFacePosi_L);
                        Screen('DrawTexture',wPtr, targetMask.tex{targetFaceIdx}, [], targetFacePosi_R);
                        Screen('Flip',wPtr);
                    end

                    while GetSecs-timezero < 0.1 && noBreak && ~isExp
                        FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                        Screen('DrawTexture',wPtr, blankMask.tex{targetFaceIdx}, [], targetFacePosi_L);
                        Screen('DrawTexture',wPtr, blankMask.tex{targetFaceIdx}, [], targetFacePosi_R);
                        Screen('Flip',wPtr);
                    end
                    
                    % delay
                    FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                    Screen('Flip',wPtr);
                    WaitSecs(.5);
                    
                % -------------make emotion judgement-------------%

                    waitForAnswer = TRUE;
                    timezero = GetSecs;
                    while waitForAnswer && noBreak
                        % show emotion judgement screen
                            FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                            Writetext(wPtr,'Emotion',L_cenX, R_cenX,BoxcenY, 30,60, [255 255 255],15);
                            Writetext(wPtr,'very',L_cenX, R_cenX,BoxcenY, 65,10, [255 255 255],15);
                            Writetext(wPtr,'negative',L_cenX, R_cenX,BoxcenY, 70,-10, [255 255 255],15);
                            Writetext(wPtr,'very',L_cenX, R_cenX,BoxcenY, -25,10, [255 255 255],15);
                            Writetext(wPtr,'positive',L_cenX, R_cenX,BoxcenY, -20,-10, [255 255 255],15);
                            Slider(wPtr,L_cenX,R_cenX,BoxcenY, boxsize, answer);
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
                                if secs(KbName(space))-timezero>0, waitForAnswer = 0;end

                                % break key pressed
                                if secs(KbName(breakKey))-timezero > 0, noBreak = 0; end

                                % ESC pressed
                                if secs(KbName(quitkey))
                                    Screen('CloseAll');
                                    return;
                                end
                            end 
                    end

                %-------Break Trials & Report visible locations------%
            
                    waitForAnswer = TRUE; 
                    while waitForAnswer && ~noBreak
                       % show visibility report screen
                            FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
                            Writetext(wPtr,'Location',L_cenX, R_cenX,BoxcenY, 25,70, [255 255 255],14);
                            Writetext(wPtr,'1',L_cenX, R_cenX,BoxcenY, reportdis+5,reportdis+5, [255 255 255],14);
                            Writetext(wPtr,'2',L_cenX, R_cenX,BoxcenY, -reportdis+5,reportdis+5, [255 255 255],14);
                            Writetext(wPtr,'3',L_cenX, R_cenX,BoxcenY, reportdis+5,-reportdis+5, [255 255 255],14);
                            Writetext(wPtr,'4',L_cenX, R_cenX,BoxcenY, -reportdis+5,-reportdis+5, [255 255 255],14);
                            for p = 1:4 
                                if seen(p)
                                    SelectionBox(wPtr,L_reportBoxPosi(p,1),R_reportBoxPosi(p,1), L_reportBoxPosi(p,2),reportBoxSize,boxcolor);
                                end
                            end
                            Screen('Flip',wPtr);

                        %get keyboard response
                            KbEventFlush();
                            [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);

                            if  keyIsDown
                                % report seen faces
                                for p= 1:4
                                   if secs(KbName(placeKey(p)))
                                       seen(p) = ~seen(p);
                                   end 
                                end

                                % space pressed
                                if secs(KbName(space)),  waitForAnswer = 0; end

                                % ESC pressed
                                if secs(KbName(quitkey))
                                    Screen('CloseAll'); 
                                    return;
                                end
                            end 
                    end 
                    
                %--------- Save Result to Result List----------%
                    condList(i,JUDGEMENT)        = answer;
                    condList(i,DONE)             = noBreak;
                    condList(i,SEEN(:))          = seen(:);
                    condList(i,PLACE(:))         = randPosi(:);
                    if isExp condList(i,CON(:))  = faceCon(stair,:); end
                    condList(i,REPEAT)           = condList(i,REPEAT)+1;
                    resultList(end+1,:)                 = condList(i,:);
                    for posi = 1:4
                        break_thisBlock{posi}(end+1) = seen(posi);
                        breakRate_thisBlock(posi) = mean(break_thisBlock{posi});
                    end
                    
                %---------- Monitoring ----------%
                    disp('-------------------------------')
                    disp('   isExp Ensem Targ.  Ans. Done  Staircase');
                    disp(condList(i,1:6));
                    disp('Threshold: ');
                    disp(condList(i,CON(:)));
                    disp(condList(i,SEEN(:)));
                    disp('Blk DoneTrials');
                    disp([num2str(doneBlockNum+1) '   ' num2str(sum(condList(:,DONE))) '/' num2str(trialPerBlock)]);
                    disp('Breaking rate for each quadrant in this block')
                    disp(breakRate_thisBlock);
                    
                %---------- Adjust Threshold ----------%
                    for p = 1:4
                      % seen, decrease
                      if(seen(p)) && isExp
                         faceCon(stair,p) = faceCon(stair,p)-stepsize_down;
                         if faceCon(stair,p) <= lowerBound, faceCon(stair,p) = lowerBound; end
                         numReportUnseen{stair}(p) = 0;
                      end

                      % unseen, increase
                      if(~seen(p)) && isExp
                         numReportUnseen{stair}(p) = numReportUnseen{stair}(p) +1;
                         if numReportUnseen{stair}(p) == stairCase_up;
                             faceCon(stair,p) = faceCon(stair,p) + stepsize_up;
                             if faceCon(stair,p) >= upperBound, faceCon(stair,p) = upperBound; end
                             numReportUnseen{stair}(p) = 0;
                         end
                      end
                    end     
                
            end %end of trials
            
            if sum(condList(blockIndex{block},DONE)) == trialPerBlock
                blockUnDone = FALSE;
                doneBlockNum = doneBlockNum+1;
                WriteToResultFile(resultFilePath, resultList);
            end
        end %end of the block
        
        %===== Conpulsory Resting Between Blocks =====%
        keepWaiting = TRUE;
        timeLimit = GetSecs+waitTime;
        while keepWaiting
            remainingTime = ceil(timeLimit-GetSecs);
            FixationBox(wPtr,L_cenX,R_cenX, BoxcenY,boxsize,boxcolor);
            if doneBlockNum == 1, Writetext(wPtr,'20% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
            if doneBlockNum == 2, Writetext(wPtr,'40% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
            if doneBlockNum == 3, Writetext(wPtr,'60% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
            if doneBlockNum == 4, Writetext(wPtr,'80% done',L_cenX, R_cenX,BoxcenY, 70,50, [255 255 255],20); end
            if doneBlockNum == 5, break; end
            Writetext(wPtr,'take a rest',L_cenX, R_cenX,BoxcenY, 70,15, [255 255 255],20);

            if remainingTime > 0
                Writetext(wPtr,[num2str(remainingTime) 's'],L_cenX, R_cenX,BoxcenY, 30,-25, [255 255 255],20);
            else
                Writetext(wPtr,'press down to start',L_cenX, R_cenX,BoxcenY, 70,-25, [255 255 255],15);  
                KbEventFlush();
                [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
                if secs(KbName(breakKey))
                    keepWaiting = FALSE;
                end 
            end
            
            %ESC pressed
            [keyIsDown, secs, keyCode] = KbQueueCheck(devInd);
            if secs(KbName(quitkey))
                Screen('CloseAll');
                return;
            end
            Screen('Flip',wPtr);
        end
        
    end
        
    
%===== Combine Result Files and Quit =====%
    CombindAllResultFile(subjID);
    Screen('CloseAll');
    return;

catch exception
    Screen('CloseAll');
    disp('*** ERROR ***');
    disp(getReport(exception));
    return;
end