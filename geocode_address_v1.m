%% Initialization
clear
close all
clc

%% Import data
has_header = false ;
workbookFile = 'Commuter Survey Data - Cleaned Addresses.xlsx';
sheetName = 'Cleaned Addresses';
DowntownDenverCommuterSurveyOctober = importfile(workbookFile, sheetName);

%% Configuration

country = 'United States' ;
APIKeys_Here360 = {'BobBEN86traX7ypRPtzbjxFdIyYVzGoPekxIKrqO564'} ;
% set the weboption
timeout_val = 30 ; % time out option for weboptions in seconds

%% Instantiation
geo_coded_addresses  = string() ;

%% Computations
if has_header
    start_index = 2 ;
else
    start_index = 1 ;
end

% for every address
cnt = 0 ;
% randsample(1:size(DowntownDenverCommuterSurveyOctober,1), 100, false)
for it_ad = start_index:size(DowntownDenverCommuterSurveyOctober,1)

    % check if the row is not empty
    if isempty(DowntownDenverCommuterSurveyOctober{it_ad,2}) || ...
        isempty(DowntownDenverCommuterSurveyOctober{it_ad,4}) || ...
        any(strcmp(strtrim(DowntownDenverCommuterSurveyOctober{it_ad,2}),{'.','-', '_', ' '})) || ...
        any(strcmp(strtrim(DowntownDenverCommuterSurveyOctober{it_ad,4}),{'.','-', '_', ' '}))
        continue
    end
    cnt = cnt + 1 ;
    
    % format the address
    txt_address_home = sprintf('%s, %s', ...
        DowntownDenverCommuterSurveyOctober(it_ad,2), ...
        DowntownDenverCommuterSurveyOctober(it_ad,3) ...
        );
    txt_address_home = erase( txt_address_home , '#' );

    txt_address_work = sprintf('%s, %s', ...
        DowntownDenverCommuterSurveyOctober(it_ad,4), ...
        DowntownDenverCommuterSurveyOctober(it_ad,5) ...
        );
    txt_address_work = erase( txt_address_work , '#' );

    % create the api
    api_str_home = sprintf('https://autosuggest.search.hereapi.com/v1/autosuggest?apiKey=%s&limit=1&q=%s&in=countryCode:USA&at=39.7856,-104.9835', ...
        APIKeys_Here360{1}, ...
        txt_address_home) ;
    api_str_work = sprintf('https://autosuggest.search.hereapi.com/v1/autosuggest?apiKey=%s&limit=1&q=%s&in=countryCode:USA&at=39.7856,-104.9835', ...
        APIKeys_Here360{1}, ...
        txt_address_work) ;

    % send api query
    options = weboptions('Timeout',timeout_val) ;
    try
        data_struct_home = webread(api_str_home,options) ;
    catch ME
        pause(2)
        data_struct_home = webread(api_str_home,options) ;
    end
    try
        data_struct_work = webread(api_str_work,options) ;
    catch ME
        pause(2)
        data_struct_work = webread(api_str_work,options) ;
    end
    
    % generate output
    geo_coded_addresses(cnt,1) = DowntownDenverCommuterSurveyOctober(it_ad,2) ;
    geo_coded_addresses(cnt,2) = DowntownDenverCommuterSurveyOctober(it_ad,3) ;
    geo_coded_addresses(cnt,3) = data_struct_home.items.address.label ; 
    geo_coded_addresses(cnt,4) = data_struct_home.items.position.lat ;
    geo_coded_addresses(cnt,5) = data_struct_home.items.position.lng ;

    geo_coded_addresses(cnt,6) = DowntownDenverCommuterSurveyOctober(it_ad,4) ;
    geo_coded_addresses(cnt,7) = DowntownDenverCommuterSurveyOctober(it_ad,5) ;
    geo_coded_addresses(cnt,8) = data_struct_work.items.address.label ; 
    geo_coded_addresses(cnt,9) = data_struct_work.items.position.lat ;
    geo_coded_addresses(cnt,10) = data_struct_work.items.position.lng ;
    
end
header = string({'survey_home_add', 'survey_zip_code_home', 'r_home_add', 'home_lat', 'home_lng', ...
    'survey_work_add', 'survey_zip_code_work', 'r_work_add', 'work_lat', 'work_lng'});
geo_coded_addresses = [header;geo_coded_addresses] ;
save("geocode_address.mat","geo_coded_addresses");
