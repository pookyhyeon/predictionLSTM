% 데이터 파일 경로 설정
combinedDataFolder = 'C:\Users\kateb\Documents\Matlab_AI_경진대회\preprocessed_data\combined_data';
combinedFile = fullfile(combinedDataFolder, 'combined_TS_1.suncheon_power_weather_data.csv');

% 데이터 로드
data = readtable(combinedFile);

% 입력 변수와 타겟 변수 선택
features = data{:, {'precipitation', 'humidity', 'rainy', 'temperature','windDirection', 'windSpeed', 'Sin_Time', 'Cos_Time', 'THI', 'CDH', 'Average_Power', 'Total_Power'}};
target = data.Total_Power;

% 데이터 전처리
featureMin = min(features);
featureMax = max(features);
targetMin = min(target);
targetMax = max(target);

normalizedFeatures = (features - featureMin) ./ (featureMax - featureMin);
normalizedTarget = (target - targetMin) / (targetMax - targetMin);

% 학습 데이터와 테스트 데이터 분리
trainRatio = 0.8;
nTimeSteps = numel(normalizedTarget);
numTrain = floor(trainRatio * nTimeSteps);

XTrain = normalizedFeatures(1:numTrain, :);
YTrain = normalizedTarget(2:numTrain+1);
XTest = normalizedFeatures(numTrain+1:end-1, :);
YTest = normalizedTarget(numTrain+2:end);

% 데이터 크기 확인
disp(['Size of XTrain: ', num2str(size(XTrain))]);
disp(['Size of YTrain: ', num2str(size(YTrain))]);
disp(['Size of XTest: ', num2str(size(XTest))]);
disp(['Size of YTest: ', num2str(size(YTest))]);

XTrain = num2cell(XTrain', 1);
YTrain = num2cell(YTrain');
XTest = num2cell(XTest', 1);
YTest = num2cell(YTest');

% LSTM 네트워크 구성
numFeatures = size(XTrain{1}, 1);
numResponses = 1;
numHiddenUnits = 100;

layers = [ 
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits, 'OutputMode', 'sequence')
    fullyConnectedLayer(numResponses)
    regressionLayer];

maxEpochs = 10;
miniBatchSize = 20;

options = trainingOptions('adam', ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize, ...
    'InitialLearnRate', 0.01, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 125, ...
    'LearnRateDropFactor', 0.2, ...
    'Verbose', 1, ...
    'Plots', 'training-progress');

% 네트워크 학습
net = trainNetwork(XTrain, YTrain, layers, options);

% 예측 및 성능 평가
YPred = predict(net, XTest, 'MiniBatchSize', miniBatchSize);

%% 셀 배열을 행렬로 변환
YPred = cell2mat(YPred');
YTest = cell2mat(YTest');

%% 정규화된 상태에서 RMSE 계산
rmse_normalized = sqrt(mean((YPred(:) - YTest(:)).^2)); % Flatten the arrays before calculating RMSE
fprintf('Normalized Root Mean Squared Error: %f\n', rmse_normalized);

%YPred = cell2mat(YPred') * (targetMax - targetMin) + targetMin;
%YTest = cell2mat(YTest') * (targetMax - targetMin) + targetMin;

YPred = YPred * (targetMax - targetMin) + targetMin;
YTest = YTest * (targetMax - targetMin) + targetMin;

rmse = sqrt(mean((YPred(:) - YTest(:)).^2)); % Flatten the arrays before calculating RMSE
fprintf('Root Mean Squared Error: %f\n', rmse);

% 예측 결과 시각화
time = datetime(data.DateTime, 'InputFormat', 'yyyy-MM-dd HH:mm');
figure;
subplot(2,1,1);
plot(time(numTrain+2:15:end), YTest(1:15:end), 'g--', 'DisplayName', 'True Data');
hold on;
k=size(time(1:numTrain+2),1);
plot(time(1:15:numTrain+2),data.Total_Power(1:15:k),'b');
xlabel('Time');
ylabel('Power');
legend('show','Location','NorthWest');
legend('True Data','Previous Data');
title('Power');
legend;
subplot(2,1,2);
plot(time(1:15:numTrain+2),data.Total_Power(1:15:k),'b');
hold on
plot(time(numTrain+2:15:end), YPred(1:15:end), 'r--', 'DisplayName', 'Predicted Data');
xlabel('Time');
ylabel('Power');
legend('show','Location','NorthWest');
legend('Previous Data,','Predicted Data');
title('Power Prediction using LSTM_다중');