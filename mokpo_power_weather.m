% 데이터 파일 경로 설정
preprocessedPowerDataFolder = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터\powerdata';
preprocessedWeatherDataFolder = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터\weaterdata';

% 전처리된 전력 데이터 파일 경로
preprocessedPowerFile = fullfile(preprocessedPowerDataFolder, 'combined_TS_3.yeosu_powerdata_aggregated.csv');

% 전처리된 날씨 데이터 파일 경로
preprocessedWeatherFile = fullfile(preprocessedWeatherDataFolder, 'preprocessed_TS_3.yeosu_weatherdata.csv');

% 데이터 읽기
powerData = readtable(preprocessedPowerFile);
weatherData = readtable(preprocessedWeatherFile);

% 전력 데이터와 날씨 데이터를 DateTime으로 결합
% 'mrdDt'와 'DateTime' 열 이름을 'DateTime'으로 통일하기
powerData.Properties.VariableNames{'mrdDt'} = 'DateTime';

% 데이터 타입 변환 (필요한 경우)
powerData.DateTime = datetime(powerData.DateTime, 'InputFormat', 'yyyy-MM-dd HH:mm');
weatherData.DateTime = datetime(weatherData.DateTime, 'InputFormat', 'yyyy-MM-dd HH:mm');

% 데이터 병합 (내부 조인: 공통된 'DateTime' 값만 포함)
mergedData = innerjoin(powerData, weatherData, 'Keys', 'DateTime');

% 결합된 데이터 확인
disp('결합된 데이터 - 상위 5개 행:');
dispTableHead(mergedData);

% 결합된 데이터 저장
combinedDataFolder = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터';
if ~exist(combinedDataFolder, 'dir')
    mkdir(combinedDataFolder);
end

combinedFile = fullfile(combinedDataFolder, 'combined_TS_3.yeosu_power_weather_data.csv');
writetable(mergedData, combinedFile);

% 테이블 상위 몇 개의 행을 표시하는 함수
function dispTableHead(tableData, numRows)
    if nargin < 2
        numRows = 5; % 기본값
    end
    disp(tableData(1:min(numRows, height(tableData)), :));
end