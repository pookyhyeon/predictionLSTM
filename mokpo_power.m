% 데이터 파일 경로 설정
dataFolder_p = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터';

% 데이터 파일 경로
powerDataFolder = fullfile(dataFolder_p, 'TS_3.yeosu'); % 예시로 'TS_2.mokpo' 폴더 사용

% 데이터 읽기
powerData = readAndCombineCSV(powerDataFolder); % 'TS_2.mokpo' 폴더 내 모든 CSV 파일을 읽어옴

% 데이터 전처리
preprocessedPowerData = preprocessPowerData(powerData);

% 전처리된 데이터 확인
disp('전처리된 전력 데이터 - 상위 5개 행:');
dispTableHead(preprocessedPowerData);

% 전처리된 데이터 저장
dataFolder_p_1 = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터\powerdata';

writetable(preprocessedPowerData, fullfile(dataFolder_p_1, 'preprocessed_TS_3.yeosu_powerdata.csv'));

% CSV 파일을 읽고 결합하는 함수
function combinedData = readAndCombineCSV(folderPath)
    csvFiles = dir(fullfile(folderPath, '*.csv'));
    combinedData = table(); 

    for i = 1:length(csvFiles)
        filePath = fullfile(folderPath, csvFiles(i).name);
        data = readtable(filePath);
        combinedData = [combinedData; data]; % 테이블 결합
    end
end

% 전력 데이터 전처리 함수
function processedData = preprocessPowerData(data)
    % 결측값을 평균값으로 대체
    if ismember('pwrQrt', data.Properties.VariableNames)
        data.pwrQrt = fillmissing(data.pwrQrt, 'linear'); % 선형 보간법을 사용한 결측값 대체
    end

    % 날짜 및 시간 형식 변환
    if ismember('mrdDt', data.Properties.VariableNames)
        data.mrdDt = datetime(data.mrdDt, 'InputFormat', 'yyyy-MM-dd HH');
    end

    % 데이터 스케일링 (정규화)
    if ismember('pwrQrt', data.Properties.VariableNames)
        data.pwrQrt = normalize(data.pwrQrt);
    end

    processedData = data;
end


% 테이블 상위 몇 개의 행을 표시하는 함수
function dispTableHead(tableData, numRows)
    if nargin < 2
        numRows = 5; % 기본값
    end
    disp(tableData(1:min(numRows, height(tableData)), :));
end
