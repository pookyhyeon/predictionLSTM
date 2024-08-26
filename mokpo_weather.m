% CSV 파일 경로 설정
dataFolder_w = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터\weaterdata';

% 날씨 데이터 파일 경로
weatherDataFile = fullfile(dataFolder_w, '3.weather_info_yeosu.csv');

% 날씨 데이터 읽기
weatherData = readtable(weatherDataFile, 'VariableNamingRule', 'preserve');

% 전처리 함수 호출
preprocessedWeatherData = preprocessWeatherData(weatherData);

% 전처리된 데이터 확인
disp('전처리된 날씨 데이터 - 상위 5개 행:');
disp(preprocessedWeatherData(1:5, :));

% 전처리된 데이터 저장 경로
dataFolder_w_1 = 'C:\Users\jeonghyeon\Desktop\AI 경진대회\data\01-1.정식개방데이터\Training\01.원천데이터\weaterdata';
writetable(preprocessedWeatherData, fullfile(dataFolder_w_1, 'preprocessed_TS_3.yeosu_weatherdata.csv'));

% 날씨 데이터 전처리 함수
function processedData = preprocessWeatherData(data)
    % 결측값을 평균값으로 대체
    numVars = width(data);
    for i = 1:numVars
        if isnumeric(data{:,i})
            data{isnan(data{:,i}), i} = mean(data{:,i}, 'omitnan');
        end
    end
    
    % 날짜 및 시간 형식 변환
    if ismember({'year', 'month', 'day', 'hour'}, data.Properties.VariableNames)
        % hour 값을 적절하게 변환
        hours = floor(data.hour / 100);
        data.DateTime = datetime(data.year, data.month, data.day) + hours/24;
        % data = removevars(data, {'year', 'month', 'day', 'hour'});
    end
    
    % 시간 관련 변수 생성
    data.Hour = hour(data.DateTime); % 0부터 23까지의 시간 값
    data.DayOfWeek = weekday(data.DateTime); % 1: Sunday, 2: Monday, ..., 7: Saturday
    data.Month = month(data.DateTime); % 1부터 12까지의 월 값
    data.WeekOfYear = week(data.DateTime); % 1부터 53까지의 주 값
    
    % 공휴일 변수 추가 (주말을 공휴일로 간주)
    data.Holiday = ismember(data.DayOfWeek, [1, 7]); % 1: Sunday, 7: Saturday

    % Cyclical Encoding for Hour
    data.Sin_Time = sin(2 * pi * data.Hour / 24);
    data.Cos_Time = cos(2 * pi * data.Hour / 24);
    
    % 불쾌지수 (THI) 계산
    if ismember({'temperature', 'humidity'}, data.Properties.VariableNames)
        data.THI = 9/5 * data.temperature - 0.55 * (1 - data.humidity / 100) .* (9/5 * data.temperature - 26) + 32;
    end
    
    % 냉방도일 (CDH) 계산 함수
    function cdh_values = calculateCDH(temperature)
        cdh_values = zeros(size(temperature));
        for i = 1:length(temperature)
            if i <= 11
                cdh_values(i) = sum(temperature(1:i) - 26);
            else
                cdh_values(i) = sum(temperature(i-11:i) - 26);
            end
        end
    end
    
    % 냉방도일 (CDH) 계산
    if ismember('temperature', data.Properties.VariableNames)
        data.CDH = calculateCDH(data.temperature);
    end
    
    processedData = data;
end

