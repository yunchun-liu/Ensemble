%======================= INTRODUCTION ============================%
% This script set the standard for excluding subject
% There are 3 standard
% 1. Breaking rate in any quadrant below 10%
% 2. Accuracy in blank trials (false alarm < 20%)
% 3. Judgement on the face in catch trials is unstable (SD>5)
%=================================================================%

clear all;
close all;
addpath('./Function/');

singleOutlierStd= 2.5;
overallOutlierStd = 2.5;
 
files = dir( 'Ensem_result_*.txt');
subjectNum = length(files);
 
data_raw = cell(subjectNum,5,6);
data_blank = cell(subjectNum,10);
data_normed = cell(subjectNum,5,6);

avg_blank = zeros(subjectNum,10);
std_blank = zeros(subjectNum,10);

%===== Check if all data passed the standard ======%
disp('=========== Should Exclude ============');
for sub = 1:subjectNum checkAllStandard(files(sub).name); end

%===== Read in data & Exclude Outlier======%

    % readin data excluding outlier based on subject's own std
    raw_byFace_computeOutlier = cell(6);
    sub_low = zeros(subjectNum,6);
    sub_high = zeros(subjectNum,6);
    sub_mean = zeros(subjectNum,6);
    
    for sub = 1:subjectNum
        [isExp cond target judgement noBreak stairCase t1 t2 t3 t4 s1 s2 s3 s4 rep p1 p2 p3 p4]= textread(files(sub).name,'%d %d %d %d %d %d %f %f %f %f %d %d %d %d %d %d %d %d %d');
        temp_byFace = cell(6);
        temp_blank = cell(10);
        
        %compute outlier
        for i=1:length(isExp)
            if noBreak(i)
                if isExp(i) temp_byFace{target(i)}(end+1) = judgement(i); end
                if ~isExp(i) temp_blank{target(i)}(end+1) = judgement(i); end
            end
        end
         
        for i = 1:6
            sub_low(sub,i) = mean(temp_byFace{i}) - singleOutlierStd * std(temp_byFace{i});
            sub_high(sub,i) = mean(temp_byFace{i}) + singleOutlierStd * std(temp_byFace{i});
        end
        
        for i = 1:10
            sub_low_blank(sub,i) = mean(temp_blank{i}) - singleOutlierStd * std(temp_blank{i});
            sub_high_blank(sub,i) = mean(temp_blank{i}) + singleOutlierStd * std(temp_blank{i});
        end
        
        %read in data again and exclude outlier
        for i=1:length(isExp)
            if noBreak(i)
                if isExp(i)
                    isOutlier = judgement(i)< sub_low(sub,target(i)) || judgement(i) > sub_high(sub,target(i));
                    if ~isOutlier data_raw{sub,cond(i),target(i)}(end+1) = judgement(i);end
                end

                if ~isExp(i)
                    isOutlier = judgement(i)< sub_low_blank(sub,target(i)) || judgement(i) > sub_high_blank(sub,target(i));
                    if ~isOutlier data_blank{sub,target(i)}(end+1) = judgement(i);end
                end 
            end
        end
        
    end
    
    %excluding subjects base on group mean
    
    for sub = 1:subjectNum
        for face = 1:6
            temp = [];
            for ensum = 1:5
                for i = 1: length(data_raw{sub,ensum,face}) temp(end+1) = data_raw{sub,ensum,face}(i); end
            end
            sub_mean(sub,face) = mean(temp);
            sub_std(sub,face) = std(temp);
        end
    end
    
    num_deleted = 0;
    for sub = 1:subjectNum
        for face = 1:6
            z = ( sub_mean(sub,face) - mean(sub_mean(:,face)) ) / std(sub_mean(:,face));
            if z>overallOutlierStd || z< -overallOutlierStd
                disp(['subject' files(sub-num_deleted).name ' is excluded based on judgement on face ' num2str(face)]);
                data_raw(sub-num_deleted,:,:) = [];
                subjectNum = subjectNum - 1;
                num_deleted = num_deleted+1;
            end
        end
    end

%==== Get Blank Mean ====%     

    for face = 1:10
        for sub = 1:subjectNum
            avg_blank(sub,face) = mean(data_blank{sub,face});
            std_blank(sub,face) = std(data_blank{sub,face});
        end
    end
 
%====== Normalize Data ========%
 
    for sub = 1:subjectNum
        avg_face = [];
        std_face = [];
   
        for face = 1:6
            temp = [];
            for ensum = 1:5
                for i = 1:length(data_raw{sub,ensum,face})
                temp(end+1) = data_raw{sub,ensum,face}(i); end
            end
            avg_face(face) = nanmean(temp);
            std_face(face) = nanstd(temp);
        end
 
        for face = 1:6
            indexInBlank = [ 2 3 4 7 8 9];
            
            for ensum = 1:5
                for i = 1:length(data_raw{sub,ensum,face})
                    if std_face(face) ~= 0
                    data_normed{sub,ensum,face}(i) = (data_raw{sub,ensum,face}(i)-avg_face(face)) / std_face(face); end
                    if std_face(face) == 0
                    data_normed{sub,ensum,face}(i) = (data_raw{sub,ensum,face}(i)-avg_face(face)); end
                end
%                 
%                 for i = 1:length(data_raw{sub,ensum,face})
%                     data_normed{sub,ensum,face}(i) = (data_raw{sub,ensum,face}(i)-avg_blank(sub,indexInBlank(face)));
%                 end
            end
        end
    end
    
%==== Get Mean ====%    
 
    avg_rawData = zeros(subjectNum,5,6);
    std_rawData = zeros(subjectNum,5,6);
    avg_normed = zeros(subjectNum,5,6);
    std_normed = zeros(subjectNum,5,6);
     
    for face = 1:6
        for sub = 1:subjectNum
            for ensum = 1:5
                avg_rawData(sub,ensum,face) = mean(data_raw{sub,ensum,face});
                std_rawData(sub,ensum,face) = std(data_raw{sub,ensum,face});
                avg_normed(sub,ensum,face) = mean(data_normed{sub,ensum,face});
                std_normed(sub,ensum,face) = std(data_normed{sub,ensum,face});
            end
        end
    end
    
%======== Draw Overall Distribution Chart==== % 

        figure
        for face = 1:6
            x_dis = -10:10;
            y_dis = zeros(21);
            
            for sub = 1:subjectNum
                for ensum = 1:5
                    for i = 1:length(data_raw{sub,ensum,face})
                        iden = data_raw{sub,ensum,face}(i) +11;
                        y_dis(iden) = y_dis(iden)+1;
                    end
                end
            end
            
            subplot(2,3,face);
            plot(x_dis,y_dis);
            axis([-10,10,0,150]);
            ylabel('counts');
            xlabel('emotion score');
            title(files(sub).name);

        end

%======== Subject's judgement on faces==== %         
        
        figure
        for sub = 1:subjectNum
            x1 = 1:5;
            x2 = 6:10;
            y = [];
            error = [];
            
            subplot(5,6,sub);
            errorbar(x1,avg_blank(sub,1:5),std_blank(sub,1:5));
            hold on;
            errorbar(x2,avg_blank(sub,6:10),std_blank(sub,6:10));
            axis([0,11,-10,10]);
            ylabel('judgement score');
            xlabel('face No.');
            title(files(sub).name);
        end

    
%===== for each subject(all emotion) =====%
    
    overall = zeros(subjectNum,5);
    overallStd = zeros(subjectNum,5);
    
    for ensum = 1:5
        for sub = 1:subjectNum
            temp = [];
            for emotion  = 1:3
                temp(end+1) = avg_normed(sub,ensum,emotion);
                temp(end+1) = avg_normed(sub,ensum,3+emotion);
            end
            overall(sub,ensum) = mean(temp);
            overallStd(sub,ensum) = std(temp)/sqrt(30);
        end
    end
    
    figure
    
    x = 1:5;
    
    for sub = 1:subjectNum
        subplot(5,6,sub);
        %errorbar(y,overall(sub,:),overallStd(sub,:));
        scatter(x,overall(sub,:));
        lsline;
        set(gca,'XTickLabel', {'4F','3F1H','2F2H','1F3H','4H'});
        axis([1 5 -1 1]);
        rsqare = getr2(x,overall(sub,:));
        title(['R2 = ' num2str(rsqare)]);
    end
    
    
    %=====overall - ensumble effect=====%
    
    overall = [];
    overallStd = [];
    for ensum = 1:5
        temp = [];
        for sub = 1:subjectNum
            for emotion  = 1:3
                temp(end+1) = avg_normed(sub,ensum,emotion);
                temp(end+1) = avg_normed(sub,ensum,3+emotion);
            end
        end
        overall(ensum) = mean(temp);
        overallStd(ensum) = std(temp)/sqrt(6*subjectNum);
    end
    
    figure
    x = 1:5;
    errorbar(x,overall,overallStd);
    %axis([0 6 -0.3 0.3]);
    set(gca,'XTickLabel', {'','4F','3F1H','2F2H','1F3H','4H'});
    xlabel('Ensemble condition');
    ylabel('Emotion rating (nomalized)');
    title('Effect of Ensemble Condition');
    
    
    %=====overall (seperate two faces)=====%
    
    for ensum = 1:5
        temp1 = [];
        temp2 = [];
        for sub = 1:subjectNum
            for emotion  = 1:3
                temp1(end+1) = avg_normed(sub,ensum,emotion);
                temp2(end+1) = avg_normed(sub,ensum,3+emotion);
            end
        end
        overall1(ensum) = mean(temp1);
        overallStd1(ensum) = std(temp1)/sqrt(3*subjectNum);
        overall2(ensum) = mean(temp2);
        overallStd2(ensum) = std(temp2)/sqrt(3*subjectNum);
    end
    
    figure
    x = 1:5;
    subplot(1,2,1);
    errorbar(x,overall1,overallStd1);
    %axis([0 6 -0.3 0.3]);
    set(gca,'XTickLabel', {'','4F','3F1H','2F2H','1F3H','4H'});
    xlabel('Ensemble condition');
    ylabel('Emotion rating (nomalized)');
    title('Effect of Ensemble Contition(Person A)');
    
    subplot(1,2,2);
    errorbar(x,overall2,overallStd2);
    %axis([0 6 -0.3 0.3]);
    set(gca,'XTickLabel', {'','4F','3F1H','2F2H','1F3H','4H'});
    xlabel('Ensemble condition');
    ylabel('Emotion rating (nomalized)');
    title('Effect of Ensemble Contition(Person B)');
    
   %===== raw data (scatter plot )=====%
   
    x = cell(5);
    y = cell(5);
    figure
    for ensum = 1:5
        for emotion  = 1:3
            x{ensum}(end+1) = emotion;
            y{ensum}(end+1) = mean(avg_rawData(:,ensum,emotion));
        end
    end
    
        plot(x{1},y{1},'rx');
        hold on
        plot(x{2},y{2},'mo');
        plot(x{3},y{3},'b*');
        plot(x{4},y{4},'go');
        plot(x{5},y{5},'y*');
        lsline;
        set(gca,'XTickLabel', {'negative','','','','','neutral','','','','','positive'});
        xlabel('Emotin Presented');
        ylabel('Emotion rating ');
        axis([1 3 -6 6]);
        legend('4F','3F1H','2F2H','1F3H','4H');

%=== ANOVA overall normed ====%
    anova = zeros(0,4);
    
    for ensum = 1:5
        for sub = 1:subjectNum
            for emotion  = 1:3
                temp = [avg_normed(sub,ensum,emotion) ensum emotion sub];
                anova(end+1,:) = temp;
                temp = [avg_normed(sub,ensum,3+emotion) ensum emotion sub];
                anova(end+1,:) = temp;
            end
        end
    end
    
    disp('================== ANOVA on normalized data =====================')
    RMAOV2(anova);
    
%=== ANOVA overall raw data ====%
    anova = zeros(0,4);
    
    for ensum = 1:5
        for sub = 1:subjectNum
            for emotion  = 1:3
                temp = [avg_rawData(sub,ensum,emotion) ensum emotion sub];
                anova(end+1,:) = temp;
                temp = [avg_rawData(sub,ensum,3+emotion) ensum emotion sub];
                anova(end+1,:) = temp;
            end
        end
    end
    
    disp('================== ANOVA on raw data =====================')
    RMAOV2(anova);
    
%=== T-test between conditions ====%
    
    Ttest_p = zeros(5,5);
    Ttest_h = zeros(5,5);
    
    for con1 = 1:5
        for con2 = 1:5

            x = [];
            y = [];
            for ensum = 1:5
                for sub = 1:subjectNum
                    for face  = 1:6
                       if ensum == con1
                           x(end+1) = avg_normed(sub,ensum,face);
                       end
                       if ensum == con2
                           y(end+1) = avg_normed(sub,ensum,face);
                       end
                    end
                end
            end
            [h,p,ci,stats] = ttest(x,y);
            Ttest_p(con1,con2) = p;
            Ttest_h(con1,con2) = h;
        end
    end
    
    disp(Ttest_p);
    disp(Ttest_h);
    
    
    
    
    