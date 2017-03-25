clear all;
close all;

    % RESULT TEXT FILE
    %1 trialnumver 
    %2 condition
    %3 stimuli face
    %4 testface
    %5 result
    %6 isBreakTrials
    %7 which staircase is used
    %8-11 where does it break
    %12-15 threshold presented

singleOutlierStd= 2; 
overallOutlierStd = 2;

files = dir( 'Ensem_result_*.txt');
subjectNum = length(files);

data_raw = cell(subjectNum,5,6);
data_normed_byFace = cell(subjectNum,5,6);
data_normed_byIden = cell(subjectNum,5,6);

avg_raw = zeros(subjectNum,5,6);
avg_normed_byFace = zeros(subjectNum,5,6);
avg_normed_byIden = zeros(subjectNum,5,6);

%===== Read in data & Exclude Outlier======%

    % exclude outlier based on subject's own std
    raw_byFace_computeOutlier = cell(6);
    sub_low = zeros(subjectNum,6);
    sub_high = zeros(subjectNum,6);

    for sub = 1:subjectNum
        [isExp cond target judgement noBreak stairCase t1 t2 t3 t4 s1 s2 s3 s4 rep p1 p2 p3 p4]= textread(files(sub).name,'%d %d %d %d %d %d %f %f %f %f %d %d %d %d %d %d %d %d %d');
        temp_byFace = cell(6);

        for i=1:length(isExp)
            if noBreak(i) && isExp(i)
                temp_byFace{target(i)}(end+1) = judgement(i);
            end
        end
        
        for i = 1:6
            sub_low(sub,i) = mean(temp_byFace{i}) - singleOutlierStd * std(temp_byFace{i});
            sub_high(sub,i) = mean(temp_byFace{i}) + singleOutlierStd * std(temp_byFace{i});
        end
        
        for i=1:length(isExp)
            isOutlier_all = judgement(i)< sub_low(target(i)) && judgement(i) > sub_high(target(i));
            if noBreak(i) && isExp(i) && ~isOutlier_all
                raw_byFace_computeOutlier{target(i)}(end+1) = judgement(i);
            end
        end
        
    end
    
    % exclude outlier based on overall distribution
    all_high = [];
    all_low = [];
    for i=1:6
        all_high(i) = mean(raw_byFace_computeOutlier{i}) + overallOutlierStd *std(raw_byFace_computeOutlier{i});
        all_low(i) = mean(raw_byFace_computeOutlier{i}) - overallOutlierStd *std(raw_byFace_computeOutlier{i});
    end

    for sub = 1:subjectNum
         [isExp cond target judgement noBreak stairCase t1 t2 t3 t4 s1 s2 s3 s4 rep p1 p2 p3 p4]= textread(files(sub).name,'%d %d %d %d %d %d %f %f %f %f %d %d %d %d %d %d %d %d %d');
        for i=1:length(isExp)
            if isExp(i)
                isOutlier_sub = judgement(i)>sub_high(sub,target(i)) || judgement(i)<sub_low(sub,target(i));
                isOutlier_all = judgement(i)>all_high(target(i)) || judgement(i)<all_low(target(i));
                if ~noBreak(i) && ~isOutlier_all  && ~isOutlier_sub
                    data_raw{sub,cond(i),target(i)}(end+1) = judgement(i);
                end
            end
        end
    end
    
% ======== Draw Overall Distribution Chart==== %      

figure
        for j = 1:6
        x_dis = -10:10;
        y_dis = zeros(21);
        
        for i = 1:length(raw_byFace_computeOutlier{j})
            iden = raw_byFace_computeOutlier{j}(i) +11;
            y_dis(iden) = y_dis(iden)+1;
        end
        
        subplot(2,3,j)
            plot(x_dis,y_dis);
            axis([-10,10,0,70]);
            stat = {['mean:' num2str(mean(raw_byFace_computeOutlier{j})) '  std:' num2str(std(raw_byFace_computeOutlier{j}))]};
            text(-8,45,stat);
            text(all_high(j),5,'|');
            text(all_low(j),5,'|');
            ylabel('counts');
            xlabel('emotion score');
            title(['face No.' num2str(j) ]);

        end
    
%====== Normalized Data By Identity ========%

    % get average & std for each identity
    for identity = 1:4
        temp = [];
        for face = 4*identity-3 : 4*identity
            for sub = 1:subjectNum
                for ensum = 1:5
                    for i = 1:length(data_raw{sub,ensum,face})
                    temp(end+1) = data_raw{sub,ensum,face}(i); end
                end
            end
        end
        avg_iden(identity) = nanmean(temp);
        std_iden(identity) = nanstd(temp);
    end

    % nomalization
    for face = 1:16
        if face >= 1 && face <= 4 iden = 1; end
        if face >= 5 && face <= 8 iden = 2; end
        if face >= 9 && face <= 12 iden = 3; end
        if face >= 13 && face <= 16 iden = 4; end

            for sub = 1:subjectNum
                for ensum = 1:5
                    for i = 1:length(data_raw{sub,ensum,face})
                    data_normed_byIden{sub,ensum,face}(i) = (data_raw{sub,ensum,face}(i)-avg_iden(iden)) / std_iden(iden); end
                end
            end
    end

%======Normalized Data By Face ========%

% get average & std for each identity
    avg_face = [];
    std_face = [];
    for sub = 1:subjectNum
        for face = 1:16
            temp = [];
            for ensum = 1:5
                for i = 1:length(data_raw{sub,ensum,face})
                temp(end+1) = data_raw{sub,ensum,face}(i); end
            end
            avg_face(face) = nanmean(temp);
            std_face(face) = nanstd(temp);
        end
    end

    % nomalization
    for face = 1:16
        for sub = 1:subjectNum
            for ensum = 1:5
                for i = 1:length(data_raw{sub,ensum,face})
                data_normed_byFace{sub,ensum,face}(i) = (data_raw{sub,ensum,face}(i)-avg_face(face)) / std_face(face); end
            end
        end
    end
    
%==== Get Mean ====%    
    
  
if targetCon == 1 legitFaces = 1:8; end
if targetCon == 2 && exclude == 1 legitFaces = [9 11 12 13 14 16]; end
if targetCon == 2 && exclude == 2 legitFaces = 9:16; end
if targetCon == 3 && exclude == 1 legitFaces = [1 2 3 4 5 6 7 8 9 11 12 13 14 16]; end
if targetCon == 3 && exclude == 2 legitFaces = 1:16; end
faceNum = length(legitFaces);

    avg_raw = zeros(subjectNum,5,4);
    avg_normed_byIden = zeros(subjectNum,5,4);
    avg_normed_byFace = zeros(subjectNum,5,4);
    temp_raw = cell(subjectNum,5,4);
    temp_normed_byIden = cell(subjectNum,5,4);
    temp_normed_byFace = cell(subjectNum,5,4);
    
    for face = legitFaces
        for sub = 1:subjectNum
            for ensum = 1:5
                temp_raw{sub,ensum,mapping(sub,face)} (end+1) = nanmean(data_raw{sub,ensum,face});
                temp_normed_byIden{sub,ensum,mapping(sub,face)} (end+1) = nanmean(data_normed_byIden{sub,ensum,face});
                temp_normed_byFace{sub,ensum,mapping(sub,face)} (end+1) = nanmean(data_normed_byFace{sub,ensum,face});
            end
        end
    end
    
    for emotion = 1:4
        for sub = 1:subjectNum
            for ensum = 1:5 
                avg_raw(sub,ensum,emotion) = nanmean(temp_raw{sub,ensum,emotion});
                avg_normed_byIden(sub,ensum,emotion) = nanmean(temp_normed_byIden{sub,ensum,emotion});
                avg_normed_byFace(sub,ensum,emotion) = nanmean(temp_normed_byFace{sub,ensum,emotion});
            end
        end
    end
    
    %======detect and exclude NaN======%
    testNaN = isnan(avg_raw);
    for i = 1:subjectNum
        sum = 0;
        for j = 1:5
            for k = 1:4
                sum = sum+testNaN(i,j,k);
            end
        end
        hasNaN(i) = sum;
    end
    
    temp1 = avg_raw;
    temp2 = avg_normed_byIden;
    temp3 = avg_normed_byFace;
    avg_raw = zeros(0,5,4);
    avg_normed_byIden = zeros(0,5,4);
    avg_normed_byFace = zeros(0,5,4);
    for i = 1:subjectNum
        if ~hasNaN(i)
            avg_raw(end+1,:) = temp1(i,:);
            avg_normed_byIden(end+1,:) = temp2(i,:);
            avg_normed_byFace(end+1,:) = temp3(i,:);
        end
    end
    
    
