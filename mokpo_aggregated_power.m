% 데이터 파일 경로 설정
preprocessedDataFolder = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터\powerdata';
preprocessedPowerFile = fullfile(preprocessedDataFolder, 'preprocessed_TS_3.yeosu_powerdata.csv');

% 전처리된 데이터 읽기
preprocessedPowerData = readtable(preprocessedPowerFile);

% 날짜 및 시간별로 집계 (합계)
aggregatedDataSum = varfun(@sum, preprocessedPowerData, ...
    'InputVariables', 'pwrQrt', ...
    'GroupingVariables', 'mrdDt');

% 날짜 및 시간별로 집계 (평균)
aggregatedDataMean = varfun(@mean, preprocessedPowerData, ...
    'InputVariables', 'pwrQrt', ...
    'GroupingVariables', 'mrdDt');

% 합계와 평균 데이터를 병합
combinedAggregatedData = join(aggregatedDataSum, aggregatedDataMean, 'Keys', 'mrdDt', ...
    'RightVariables', {'mean_pwrQrt'});

% 열 이름 수정
combinedAggregatedData.Properties.VariableNames{'sum_pwrQrt'} = 'Total_Power';
combinedAggregatedData.Properties.VariableNames{'mean_pwrQrt'} = 'Average_Power';

% 집계된 데이터 저장
dataFolder_p_1 = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터\powerdata';

combinedAggregatedFile = fullfile(dataFolder_p_1, 'combined_TS_3.yeosu_powerdata_aggregated.csv');
writetable(combinedAggregatedData, combinedAggregatedFile);
