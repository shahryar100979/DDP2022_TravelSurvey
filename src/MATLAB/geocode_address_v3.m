%% Initialization
% clear
close all
clc

%% Import data
has_header = true ;
workbookFile = 'Commuter Survey Data - Cleaned Addresses.xlsx';
RawSurveyData = string(readcell('Commuter Survey Data - Cleaned Addresses.xlsx'));

%% Configuration
date_of_travel_impacts = '12/27/2022' ;   % for example, 27th december 2022 on Tuesday
country = 'United States' ;
focus_loc = [39.7856,-104.9835] ;
APIKeys_Here360 = {'BobBEN86traX7ypRPtzbjxFdIyYVzGoPekxIKrqO564'} ;
APIKeys_GoogleMaps = {'AIzaSyBHg6s8MLOAwdkpNlUfiWfSDOYzmNQ1RiA'};
% set the weboption
timeout_val = 30 ; % time out option for weboptions in seconds

%% Instantiation
% geo_coded_addresses  = string() ;

%% Computations
if has_header
    start_index = 2 ;
else
    start_index = 1 ;
end

% randsample(1:size(RawSurveyData,1), 100, false)
for it_ad = 2892:size(RawSurveyData,1)

    % check if the row is not empty
    if isempty(RawSurveyData{it_ad,2}) || ...
            isempty(RawSurveyData{it_ad,4}) || ...
            any(strcmp(strtrim(RawSurveyData{it_ad,2}),{'.','-', '_', ' '})) || ...
            any(strcmp(strtrim(RawSurveyData{it_ad,4}),{'.','-', '_', ' '}))
        continue
    end

    if isempty(RawSurveyData{it_ad,3}) || ...
            strcmp(RawSurveyData{it_ad,3},'0') || ...
            isempty(RawSurveyData{it_ad,6}) || ...
            strcmp(RawSurveyData{it_ad,6},'0')
        continue
    end


    if isempty(RawSurveyData{it_ad,15}) || ...
            strcmp(RawSurveyData{it_ad,15},'0') || ...
            isempty(RawSurveyData{it_ad,16}) || ...
            strcmp(RawSurveyData{it_ad,16},'0')
        continue
    end



    % format the address
    txt_address_home = sprintf('%s, CO %s', ...
        RawSurveyData(it_ad,2), ...
        RawSurveyData(it_ad,3) ...
        );
    txt_address_home = lower(txt_address_home);
    txt_address_home = erase( txt_address_home ,'#');
    txt_address_home = strrep(txt_address_home,'&','and') ;
    txt_address_home = strrep(txt_address_home,'n.','north') ;


    txt_address_work = sprintf('%s, CO %s', ...
        RawSurveyData(it_ad,5), ...
        RawSurveyData(it_ad,6) ...
        );
    txt_address_work = lower(txt_address_work);
    txt_address_work = erase( txt_address_work , '#' );
    txt_address_work = strrep(txt_address_work,'&','and') ;
    txt_address_work = strrep(txt_address_work,'n.','north') ;

    api_str_home = sprintf('https://maps.googleapis.com/maps/api/place/textsearch/json?query=%s&key=%s', ...
        txt_address_home, ...
        APIKeys_GoogleMaps{1});
    api_str_work = sprintf('https://maps.googleapis.com/maps/api/place/textsearch/json?query=%s&key=%s', ...
        txt_address_work, ...
        APIKeys_GoogleMaps{1});

    % send api query
    options = weboptions('Timeout',timeout_val) ;
    try
        data_struct_home = webread(api_str_home,options) ;
        if strcmp(data_struct_home.status,'ZERO_RESULTS')
            txt_address_home = sprintf('CO %s',...
                RawSurveyData(it_ad,3));
            api_str_home = sprintf('https://maps.googleapis.com/maps/api/place/textsearch/json?query=%s&key=%s', ...
                txt_address_home, ...
                APIKeys_GoogleMaps{1});
            data_struct_home = webread(api_str_home,options) ;
        end
    catch ME
        pause('on')
        pause(2)
        data_struct_home = webread(api_str_home,options) ;
    end
    try
        data_struct_work = webread(api_str_work,options) ;
        if strcmp(data_struct_work.status,'ZERO_RESULTS')
            txt_address_work = sprintf('CO %s',...
                RawSurveyData(it_ad,6));
            api_str_work = sprintf('https://maps.googleapis.com/maps/api/place/textsearch/json?query=%s&key=%s', ...
                txt_address_work, ...
                APIKeys_GoogleMaps{1});
            data_struct_work = webread(api_str_work,options) ;
        end
    catch ME
        pause('on')
        pause(2)
        data_struct_work = webread(api_str_work,options) ;
    end

    if strcmp(data_struct_work.status,'ZERO_RESULTS') || ...
            strcmp(data_struct_home.status,'ZERO_RESULTS')
        continue
    end

    % generate output
    geo_coded_addresses(it_ad,1) = RawSurveyData(it_ad,2) ;
    geo_coded_addresses(it_ad,2) = RawSurveyData(it_ad,3) ;
    geo_coded_addresses(it_ad,6) = RawSurveyData(it_ad,4) ;
    geo_coded_addresses(it_ad,7) = RawSurveyData(it_ad,5) ;
    if ~iscell(data_struct_home.results)
        geo_coded_addresses(it_ad,3) = data_struct_home.results(1).formatted_address ;
        geo_coded_addresses(it_ad,4) = data_struct_home.results(1).geometry.location.lat ;
        geo_coded_addresses(it_ad,5) = data_struct_home.results(1).geometry.location.lng ;
    else
        geo_coded_addresses(it_ad,3) = data_struct_home.results{1}.formatted_address ;
        geo_coded_addresses(it_ad,4) = data_struct_home.results{1}.geometry.location.lat ;
        geo_coded_addresses(it_ad,5) = data_struct_home.results{1}.geometry.location.lng ;
    end

    if ~iscell(data_struct_work.results)
        geo_coded_addresses(it_ad,8) = data_struct_work.results(1).formatted_address ;
        geo_coded_addresses(it_ad,9) = data_struct_work.results(1).geometry.location.lat ;
        geo_coded_addresses(it_ad,10) = data_struct_work.results(1).geometry.location.lng ;
    else
        geo_coded_addresses(it_ad,8) = data_struct_work.results{1}.formatted_address ;
        geo_coded_addresses(it_ad,9) = data_struct_work.results{1}.geometry.location.lat ;
        geo_coded_addresses(it_ad,10) = data_struct_work.results{1}.geometry.location.lng ;
    end

    geo_coded_addresses(it_ad,11) = posixtime(datetime([date_of_travel_impacts, ' ' , datestr(str2double(RawSurveyData{it_ad,15}) - 30/60/24)])) ;
    geo_coded_addresses(it_ad,12) = posixtime(datetime([date_of_travel_impacts, ' ' , datestr(str2double(RawSurveyData{it_ad,16}))])) ;


end
header = string({'survey_home_add', 'survey_zip_code_home', 'r_home_add', 'home_lat', 'home_lng', ...
    'survey_work_add', 'survey_zip_code_work', 'r_work_add', 'work_lat', 'work_lng', 'departure_time_outgoing', 'departure_time_return'});
geo_coded_addresses = [header;geo_coded_addresses] ;
save("geocode_address.mat","geo_coded_addresses");
