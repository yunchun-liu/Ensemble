clear all;
close all;

    % RESULT TEXT FILE
            %1 trial number
            %2 isExptrial 1 / isCatchTrial 0
            %3 condition
            %4 face used
            %5 judgement
            %6 break
            %7 staircase
            %8-13 contrast 

                     %conscious   unconscious
                     %frea happy  fear happy

%         con     = [ [ 3    1       2   0 ] -1 1
%                     [ 2    2       2   0 ] 0  0
%                     [ 1    3       2   0 ] 1   -1
%                     [ 3    1       1   1 ]
%                     [ 2    2       1   1 ]
%                     [ 1    3       1   1 ]
%                     [ 3    1       0   2 ]
%                     [ 2    2       0   2 ]
%                     [ 1    3       0   2 ]];

% break 0 no break 1 break 2~4 useless trials

thScore{1} = [-0.25 0 0.25 -0.25 0 0.25 -0.25 0 0.25]; %only doing the conscious face
thScore{2} = [-0.5 -0.333 -0.167  -0.167 0 0.167 0.167 0.333 0.5]; %all the faces
thScore{3} = [];

ID = '1703083';
targetfile = dir( ['Ensem2_result_' ID '.txt']);
files = dir( ['Ensem_result_*.txt']);
subjectnum = length(files);

% ======== Read in all data ====== %

[trial isExpTrial cond testFace judgement Break stairCase t1 t2 t3 t4 t5 t6 s1 s2 s3 s4 s5 s6]= textread(targetfile.name,'%d %d %d %d %d %d %d  %f %f %f %f %f %f %d %d %d %d %d %d');
    
    data = cell(9);
    for i = 1:length(trial)
        if Break(i) == 0 && isExpTrial(i) && testFace(i) == 1
            
            data{cond(i)}(end+1) = judgement(i);
        end
    end

for i = 1:9
    average(i) = mean(data{i});
end

fitting1 = fitlm(thScore{1},average)
fitting2 = fitlm(thScore{2},average)
figure
scatter(average,thScore{1});
lsline;